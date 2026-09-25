#!/usr/bin/env python3
"""
build_cartridge.py — turn a course definition (JSON) into an IMS Common Cartridge
(.imscc) that Canvas can import as Modules, Pages, and Quizzes.

Authored in Zone P. Standard library only: no dependencies, no network calls,
no install step, no binaries. Readable end to end so it can be reviewed before
it enters any institutional environment.

    python3 build_cartridge.py courses/c211.json
    python3 build_cartridge.py courses/*.json --out dist/

Status, stated honestly:
  * Modules + Pages  -> believed correct; the shape Canvas documents for CC 1.1.
  * Quizzes (QTI 1.2) -> correct-shaped but NOT yet validated against a real
    Canvas import. Treat as a starting point, not a finished feature.
"""

from __future__ import annotations

import argparse
import html
import json
import pathlib
import re
import sys
import uuid
import zipfile

CC = "http://www.imsglobal.org/xsd/imsccv1p1/imscp_v1p1"
LOM = "http://ltsc.ieee.org/xsd/imsccv1p1/LOM/manifest"
XSI = "http://www.w3.org/2001/XMLSchema-instance"
QTI_TYPE = "imsqti_xmlv1p2/imscc_xmlv1p1/assessment"


def ident(prefix: str = "i") -> str:
    """Cartridge identifiers must start with a letter and stay stable-ish."""
    return f"{prefix}{uuid.uuid4().hex}"


def slug(text: str) -> str:
    s = re.sub(r"[^a-zA-Z0-9]+", "-", text).strip("-").lower()
    return s or "untitled"


def esc(text: str) -> str:
    return html.escape(text or "", quote=True)


# --------------------------------------------------------------------------
# page + quiz bodies
# --------------------------------------------------------------------------

PAGE_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{title}</title>
<meta name="identifier" content="{ident}">
</head>
<body>
{body}
</body>
</html>
"""

TODO_BODY = """<p><em>Content not authored yet.</em></p>
<!-- Only the generic layer belongs here: the rule/trap/example grid, the
     through-lines, the drill formats, and his own written answers.
     Never study-guide questions, assessment items, coaching reports,
     course text, or anything carrying a student identifier. -->
"""


def page_html(item: dict, course_dir: pathlib.Path) -> str:
    body = item.get("body", "")
    src = item.get("body_file")
    if src:
        p = course_dir / src
        if p.exists():
            body = p.read_text(encoding="utf-8")
        else:
            body = f"<!-- body_file not found: {esc(src)} -->\n" + TODO_BODY
    if not body:
        body = TODO_BODY
    return PAGE_TEMPLATE.format(title=esc(item["title"]), ident=ident("p"), body=body)


def quiz_xml(item: dict, res_id: str) -> str:
    """Minimal QTI 1.2 multiple-choice assessment. Shape is right; unvalidated."""
    out = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<questestinterop xmlns="http://www.imsglobal.org/xsd/ims_qtiasiv1p2">',
        f'  <assessment ident="{res_id}" title="{esc(item["title"])}">',
        '    <section ident="root_section">',
    ]
    for q in item.get("questions", []):
        qid = ident("q")
        out += [
            f'      <item ident="{qid}" title="{esc(q.get("title", "Question"))}">',
            '        <itemmetadata><qtimetadata>',
            '          <qtimetadatafield><fieldlabel>question_type</fieldlabel>'
            '<fieldentry>multiple_choice_question</fieldentry></qtimetadatafield>',
            f'          <qtimetadatafield><fieldlabel>points_possible</fieldlabel>'
            f'<fieldentry>{q.get("points", 1)}</fieldentry></qtimetadatafield>',
            '        </qtimetadata></itemmetadata>',
            '        <presentation>',
            f'          <material><mattext texttype="text/html">{esc(q["stem"])}</mattext></material>',
            f'          <response_lid ident="response1" rcardinality="Single">',
            '            <render_choice>',
        ]
        answer_ids = []
        for choice in q.get("choices", []):
            cid = ident("c")
            answer_ids.append((cid, choice))
            out += [
                f'              <response_label ident="{cid}">',
                f'                <material><mattext texttype="text/html">{esc(choice["text"])}</mattext></material>',
                '              </response_label>',
            ]
        out += ['            </render_choice>', '          </response_lid>', '        </presentation>']
        correct = next((cid for cid, c in answer_ids if c.get("correct")), None)
        out += [
            '        <resprocessing>',
            '          <outcomes><decvar maxvalue="100" minvalue="0" varname="SCORE" vartype="Decimal"/></outcomes>',
            '          <respcondition continue="No">',
            '            <conditionvar>',
            f'              <varequal respident="response1">{correct}</varequal>' if correct else
            '              <other/>',
            '            </conditionvar>',
            '            <setvar action="Set" varname="SCORE">100</setvar>',
            '          </respcondition>',
            '        </resprocessing>',
            '      </item>',
        ]
    out += ['    </section>', '  </assessment>', '</questestinterop>']
    return "\n".join(out)


# --------------------------------------------------------------------------
# manifest
# --------------------------------------------------------------------------

def build_manifest(course: dict, entries: list[dict]) -> str:
    man_id = ident("man")
    org_id = ident("org")
    root_id = ident("root")

    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<manifest identifier="{man_id}" xmlns="{CC}" xmlns:lomimscc="{LOM}" xmlns:xsi="{XSI}">',
        '  <metadata>',
        '    <schema>IMS Common Cartridge</schema>',
        '    <schemaversion>1.1.0</schemaversion>',
        '    <lomimscc:lom><lomimscc:general>',
        f'      <lomimscc:title><lomimscc:string>{esc(course["title"])}</lomimscc:string></lomimscc:title>',
        f'      <lomimscc:description><lomimscc:string>{esc(course.get("description", ""))}'
        '</lomimscc:string></lomimscc:description>',
        '    </lomimscc:general></lomimscc:lom>',
        '  </metadata>',
        '  <organizations>',
        f'    <organization identifier="{org_id}" structure="rooted-hierarchy">',
        f'      <item identifier="{root_id}">',
    ]

    by_module: dict[str, list[dict]] = {}
    for e in entries:
        by_module.setdefault(e["module"], []).append(e)

    for module_title, items in by_module.items():
        lines.append(f'        <item identifier="{ident("mod")}">')
        lines.append(f'          <title>{esc(module_title)}</title>')
        for e in items:
            lines.append(
                f'          <item identifier="{ident("it")}" identifierref="{e["res_id"]}">'
                f'<title>{esc(e["title"])}</title></item>'
            )
        lines.append('        </item>')

    lines += ['      </item>', '    </organization>', '  </organizations>', '  <resources>']

    for e in entries:
        if e["kind"] == "quiz":
            lines += [
                f'    <resource identifier="{e["res_id"]}" type="{QTI_TYPE}">',
                f'      <file href="{e["path"]}"/>',
                '    </resource>',
            ]
        else:
            lines += [
                f'    <resource identifier="{e["res_id"]}" type="webcontent" href="{e["path"]}">',
                f'      <file href="{e["path"]}"/>',
                '    </resource>',
            ]

    lines += ['  </resources>', '</manifest>']
    return "\n".join(lines)


# --------------------------------------------------------------------------
# driver
# --------------------------------------------------------------------------

def build(course_path: pathlib.Path, out_dir: pathlib.Path) -> pathlib.Path:
    course = json.loads(course_path.read_text(encoding="utf-8"))
    course_dir = course_path.parent
    entries: list[dict] = []
    files: dict[str, str] = {}

    for module in course.get("modules", []):
        for item in module.get("items", []):
            res_id = ident("res")
            kind = item.get("type", "page")
            if kind == "quiz":
                path = f"quizzes/{slug(item['title'])}/assessment_qti.xml"
                files[path] = quiz_xml(item, res_id)
            else:
                path = f"pages/{slug(item['title'])}.html"
                files[path] = page_html(item, course_dir)
            entries.append({
                "module": module["title"], "title": item["title"],
                "res_id": res_id, "path": path, "kind": kind,
            })

    files["imsmanifest.xml"] = build_manifest(course, entries)

    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"{course['code']}_{slug(course['title'])}.imscc"
    with zipfile.ZipFile(out_path, "w", zipfile.ZIP_DEFLATED) as z:
        for name, text in files.items():
            z.writestr(name, text)

    pages = sum(1 for e in entries if e["kind"] != "quiz")
    quizzes = sum(1 for e in entries if e["kind"] == "quiz")
    print(f"built {out_path}  ({len(set(e['module'] for e in entries))} modules, "
          f"{pages} pages, {quizzes} quizzes)")
    return out_path


def main() -> int:
    ap = argparse.ArgumentParser(description="Build .imscc cartridges from course JSON.")
    ap.add_argument("courses", nargs="+", type=pathlib.Path)
    ap.add_argument("--out", type=pathlib.Path, default=pathlib.Path("dist"))
    args = ap.parse_args()
    for c in args.courses:
        build(c, args.out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
