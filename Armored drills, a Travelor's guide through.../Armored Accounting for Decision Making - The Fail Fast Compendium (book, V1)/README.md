# Armored Accounting for Decision Making: The Fail Fast Compendium (book, V1)

| | |
|---|---|
| Series | the seventh title in the Armored drills set |
| Status | V1 · built 2026-09-25 · not yet in the IP register or the KDP listing sheet |
| Structure | Introduction · Part One: the Fail Fast PA method · Part Two: the drill (81 items, key and dissection, triage) · Part Three: the Fail Fast OA strategies from the post-assessment coaching report · Compendium: study plan, glossary, concept index, answer key at a glance, mold reference |
| Copied here | Armored_Accounting_for_Decision_Making.docx, Armored_Accounting_for_Decision_Making.pdf (64 pp) |
| Built by | `_build/build_compendium.py` (reportlab + python-docx, same pattern as the series book builder); item source `_build/items_a.py`, `_build/items_b.py`; PA anchor data `_build/pa_anchor.json` |
| Built from | the Accounting course folder in the vault (`40_Courses`): the armored item source in `OA_Prep/_armored`, the pre-assessment anchor rows and the objective-assessment coaching report in `Diagnostic/`, the mastery refresher and calculator keystroke playbook in `Study/`, the think-aloud protocol in `OA_Prep/`; and the Course Mastery Coach Framework |
| Cover | `../Cover — Accounting for Decision Making/Armored_Accounting_for_Decision_Making_cover.jpg` |

Rebuild: `python3 _build/build_compendium.py <out_dir>` (needs reportlab, python-docx, Pillow, pypdf and the DejaVu Sans fonts; set `DEJAVU_DIR` if they are not in `/usr/share/fonts/truetype/dejavu/`). The drill keeps the original seed, so every key matches the original drill (A 20 · B 24 · C 27 · D 27).
