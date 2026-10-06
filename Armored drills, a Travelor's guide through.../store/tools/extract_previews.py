#!/usr/bin/env python3
"""Extract each book's preview section into priv/PREVIEWS.json (standard library only).

For every product (priv/KDP_LISTINGS.json, then priv/STORE_ADDITIONS.json) the book's own .docx is found in the
Armored drills folder by its manuscript file name. The preview is the book's foreword: the first top-level section
titled Foreword, Forward, Preface or Introduction — or, in The Traveler's Guide, "A word before you go", its
note to the reader before the guide begins. A book with none of these previews its opening section (the first
top-level section after the title page). Text is copied exactly; the book files are only read.

A book whose manuscript is a .pdf (the Armored business drills, products 8-13) is read the same way from its PDF
text: `pdftotext -layout` when poppler is installed, otherwise macOS PDFKit (through osascript). In those books
every section starts on a new page with its heading as the page's first line, page 1 is the title page, and the
running footer (the same line on every page, ending in the page number) is not part of any section. The section is
the rest of its page. Lines are joined back into paragraphs: a numbered line ("1. ") starts a list item (its number
is left to the page's numbered list, as with the .docx lists), a line that follows one ending in . ? ! or : starts a
new paragraph, and any other line continues the one before. Blank form lines (underscores) are dropped.

An Armored Fail Fast book (folder "Armored Fail Fast - <Title> (book, V1)") previews its title page's "What this
is" paragraph and the five-book table under it, word for word: the paragraph (its lines joined), then the table as
rows of kind "row" (header first), each row's cells split at the set's book titles, and each row's text its cells
joined by single spaces, which is how the row reads in the PDF.

Run from store/:  python3 tools/extract_previews.py
"""
import json, os, re, shutil, subprocess, sys, zipfile
from html import unescape

STORE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BOOKS = os.path.dirname(STORE)
FOREWORD = re.compile(r"^(foreword|forward|preface|introduction|a word before you go)\b", re.I)

def slugify(s): return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")
def slug(entry):
    m = entry.get("manuscript") or ""
    return slugify(os.path.splitext(os.path.basename(m))[0]) if m else slugify(entry["title"])

def find_docx(manuscript):
    name = os.path.basename(manuscript)
    hits = [os.path.join(d, name) for d in sorted(os.listdir(BOOKS))
            if d.endswith("(book, V1)") or d.endswith("(public edition, V1)")
            if os.path.isfile(os.path.join(BOOKS, d, name))]
    if len(hits) != 1: sys.exit(f"expected one book file named {name}, found {hits}")
    return hits[0]

def paragraphs(path):
    xml = zipfile.ZipFile(os.path.join(BOOKS, path)).read("word/document.xml").decode("utf-8")
    out = []
    for p in re.findall(r"<w:p[ >].*?</w:p>", xml, re.S):
        style = re.search(r'<w:pStyle w:val="([^"]+)"', p)
        text = unescape("".join(re.findall(r"<w:t(?: [^>]*)?>([^<]*)</w:t>", p)))
        out.append((style.group(1) if style else "Normal", text))
    return out

def section(paras):
    heads = [i for i, (s, t) in enumerate(paras) if s == "Heading1"]
    pick = next((i for i in heads if FOREWORD.match(paras[i][1].strip())), None)
    kind = "foreword" if pick is not None else "opening section"
    if pick is None:
        pick = next(i for i in heads if paras[i][1].strip() and paras[i][1].strip().lower() != "contents")
    end = next((i for i in heads if i > pick), len(paras))
    body = [{"kind": "li" if s.startswith("List") else "p", "text": t} for s, t in paras[pick + 1:end] if t.strip()]
    return paras[pick][1], kind, body

# --- PDF books -------------------------------------------------------------------------------------------------
PDFKIT_JS = """function run(argv) {
  ObjC.import("Quartz");
  var d = $.PDFDocument.alloc.initWithURL($.NSURL.fileURLWithPath(argv[0])), out = [];
  for (var i = 0; i < d.pageCount; i++) out.push(d.pageAtIndex(i).string.js);
  return out.join("\\f");
}"""

def pdf_pages(path):
    full = os.path.join(BOOKS, path)
    if shutil.which("pdftotext"):
        text = subprocess.run(["pdftotext", "-layout", "-enc", "UTF-8", full, "-"], check=True, capture_output=True).stdout.decode("utf-8")
    elif sys.platform == "darwin":
        text = subprocess.run(["osascript", "-l", "JavaScript", "-e", PDFKIT_JS, full], check=True, capture_output=True).stdout.decode("utf-8")
    else:
        sys.exit(f"{path}: reading a PDF needs pdftotext (poppler) or macOS")
    pages = text.split("\f")
    if pages and not pages[-1].strip(): pages = pages[:-1]
    return [[re.sub(r"\s+", " ", re.sub(r"_{3,}", " ", l)).strip() for l in pg.splitlines()] for pg in pages]

def pdf_section(pages):
    # the running footer: the same text on at least half the pages, followed by that page's number
    stems = {}
    for n, lines in enumerate(pages, 1):
        for l in lines:
            m = re.match(r"^(.*\S)\s+(\d+)$", l)
            if m and int(m.group(2)) == n: stems.setdefault(m.group(1), set()).add(n)
    footers = {s for s, ns in stems.items() if len(ns) >= max(2, len(pages) // 2)}
    def body_lines(lines):
        return [l for l in lines if l and not any(re.fullmatch(re.escape(f) + r"\s+\d+", l) for f in footers)]
    heads = [(i, body_lines(pg)) for i, pg in enumerate(pages) if i > 0 and body_lines(pg)]
    pick = next((h for h in heads if FOREWORD.match(h[1][0])), None)
    kind = "foreword" if pick is not None else "opening section"
    if pick is None: pick = next(h for h in heads if h[1][0].lower() != "contents")
    heading, lines = pick[1][0], pick[1][1:]
    body = []
    for l in lines:
        m = re.match(r"^\d+\.\s+(.*)$", l)
        if m: body.append({"kind": "li", "text": m.group(1)})
        elif body and not re.search(r"[.?!:]$", body[-1]["text"]): body[-1]["text"] += " " + l
        else: body.append({"kind": "p", "text": l})
    return heading, kind, body

FAIL_FAST = "Armored Fail Fast - "

def fail_fast_section(pages, titles):
    lines = [l for l in pages[0] if l]
    start = next(i for i, l in enumerate(lines) if l.startswith("What this is. "))
    head = next(i for i, l in enumerate(lines) if i > start and l == "Book Title What it does")
    end = next(i for i, l in enumerate(lines) if i > head and l.startswith("Domain-free."))
    body = [{"kind": "p", "text": " ".join(lines[start:head])[len("What this is. "):]}]
    body.append({"kind": "row", "cells": ["Book", "Title", "What it does"]})
    for l in lines[head + 1:end]:
        m = re.match(r"^(\d) (.*)$", l)
        if m:
            n, rest = int(m.group(1)), m.group(2)
            t = titles[n - 1]
            if not rest.startswith(t + " "): sys.exit(f"row {n} does not start with its title {t!r}: {l!r}")
            body.append({"kind": "row", "cells": [str(n), t, rest[len(t) + 1:]]})
        else:
            body[-1]["cells"][-1] += " " + l
    for b in body:
        if b["kind"] == "row": b["text"] = " ".join(b["cells"])
    if len(body) != 7: sys.exit(f"expected the paragraph, a header and five rows, got {len(body)} blocks")
    return "What this is", "what this is", body

def main():
    entries = json.load(open(os.path.join(STORE, "priv", "KDP_LISTINGS.json"))) + json.load(open(os.path.join(STORE, "priv", "STORE_ADDITIONS.json")))
    # the Fail Fast set's book titles, in book order (store titles "Armored Fail Fast: <Title>")
    ff_titles = [e["title"].split(": ", 1)[1] for e in entries if e["manuscript"].startswith(FAIL_FAST)]
    out = {}
    for entry in entries:
        src = find_docx(entry["manuscript"])
        if src.startswith(FAIL_FAST): heading, kind, body = fail_fast_section(pdf_pages(src), ff_titles)
        else: heading, kind, body = pdf_section(pdf_pages(src)) if src.lower().endswith(".pdf") else section(paragraphs(src))
        out[slug(entry)] = {"title": entry["title"], "source": src, "section": heading, "kind": kind, "paragraphs": body}
        print(f"{slug(entry)}: {kind} · \"{heading}\" · {len(body)} paragraphs · {src}")
    with open(os.path.join(STORE, "priv", "PREVIEWS.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=1); f.write("\n")

if __name__ == "__main__":
    main()
