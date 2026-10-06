# WGU I.P. — Gifted to WGU

Date: 2026-09-29

## What I said (my words)

> "1! with the caveat I need WGU to claim their I.P.  Recursively update WGU I.P.  I gift it to them."

## What this means

Some of my work was built from Western Governors University (WGU) material: its public course catalog, its program guides, its course names and codes, and my own WGU course work. I give that work to WGU. I want WGU to claim it.

Status: gift stated by Erik; WGU has not claimed or accepted it yet.

## Register: every WGU-derived item I found

I found these by reading my files, not by guessing. "Vault" means `/Users/eriklindquist/Desktop/WGU/MBA, IT Management/`. "Drills folder" means `/Users/eriklindquist/Desktop/Workspace/JOSHUA/Armored drills, a Travelor's guide through.../`. "Store" means `<Drills folder>/store/`.

| # | Path | What it is | Why it is WGU-derived |
|---|---|---|---|
| 1 | Vault `40_Courses/WGU_Armored_Drills/` (Business, Technology, Health, Education folders) | The WGU Armored Drill Library: 857 drill e-books, one per WGU course | One book per course in WGU's September 2026 catalog. Each book's scope comes from WGU's course description, and each PDF prints that description word for word plus the WGU course code (IP register V1.1, A6). |
| 2 | Vault `40_Courses/WGU_Armored_Drills/_source/catalog_2026-09.json` | The library's course list (857 courses) | WGU's catalog: course codes, course names and schools. |
| 3 | Vault `40_Courses/WGU_Armored_Drills/_source/` (`items/` 857 files, `build_ebooks.py`, `AUTHORING.md`, `batches/`) | The item files, the book builder and the writing brief | Each item file is keyed to a WGU course code and scoped from WGU's course description. The builder prints WGU's catalog text into each book. |
| 4 | Vault `40_Courses/WGU_Armored_Drills/00 INDEX.md` and `00 INDEX.pdf` | The library index | Lists all 857 WGU course codes and course names. |
| 5 | `/Users/eriklindquist/Desktop/Workspace/JOSHUA/WGU Armored Drill Library (857 ebooks) — HELD/` | Pointer folder for the library | Points to item 1; marked HELD for the WGU IP clause. |
| 6 | Drills folder, the 857 `Armored <course name> (book, V1)/` folders (store #8–#864) | Byte-for-byte copies of the 857 library books, one folder each | Same files as item 1 (each README gives the matching SHA-256). |
| 7 | Drills folder, the 857 matching `Cover — <course name>/` folders, and the cover builders in `Cover — Managing Organizations and Leading People/_build/` (`covers_*_plan.json`, `build_covers*.py`) | Covers for the 857 library books | Each cover prints a WGU course name; the plan files list them. |
| 8 | Drills folder `Armored Accounting for Decision Making - The Fail Fast Compendium (book, V1)/` (store #7) | The Fail Fast Compendium book (docx, pdf, `_build/`) | Built from the WGU C213 course folder, including the pre-assessment anchor rows and the objective-assessment coaching report, which are WGU assessment content (register A6: "EXCLUDED as built"). |
| 9 | Drills folder `Cover — Accounting for Decision Making/` | Cover for the Compendium | Cover of item 8; prints the WGU course name. |
| 10 | Drills folder `C213 Armored Drill/` | C213 study drill (copy) | Course drill for WGU course C213 (register A4: derived from the university's content). |
| 11 | `/Users/eriklindquist/Desktop/Workspace/JOSHUA/Next steps — 2026-09-15 set/2026-09-15/06_C213_Armored_Drill/` | The source copy of the C213 drill | Same drill as item 10. |
| 12 | Vault `40_Courses/C211_Global_Economics/` | My C211 course folder (Diagnostic, OA_Prep, Study, logs) | WGU course C211 work and drills (register A4). |
| 13 | Vault `40_Courses/C213_Accounting/` | My C213 course folder (Diagnostic, OA_Prep, Study, logs) | WGU course C213 work, drills, assessment anchor rows and coaching report (register A4, A6). |
| 14 | Vault `40_Courses/C214_Financial_Management/` | My C214 course folder (Diagnostic, OA_Prep, Study, logs) | WGU course C214 work and drills (register A4). |
| 15 | Store `priv/PROGRAMS.json` | The store's School > Program > Course map: 115 programs in 4 schools | Built from WGU's 2026 Institutional Catalog (September 2026): every program's standard path, courses in WGU's order. |
| 16 | Store `priv/PROGRAMS_README.md` | How item 15 was made | Names WGU's catalog as the source and explains the matching. |
| 17 | Store `lib/armored_store/programs.ex`, `lib/armored_store_web/controllers/store_html/school.html.heex`, `program.html.heex` | The code and pages that show School > Program > Course | They show WGU's school, program and course structure from item 15. |
| 18 | Store `lib/armored_store/bundles.ex` | The course bundles (#7 and #8–#864) | A bundle is a WGU course: that course's drill plus the Fail Fast set. |
| 19 | Store `priv/STORE_ADDITIONS.json` | The store records for #7–#864 (858 of its 863 rows) | Titles and shelves are WGU course names and WGU schools. (The last 5 rows, the Armored Fail Fast set, are not WGU-derived.) |
| 20 | Store `priv/PREVIEWS.json` | Preview text for the course books | Copied from items 6 and 8. |
| 21 | Store `priv/static/images/covers/` (the 858 course covers) | Cover copies the store serves | Copies of items 7 and 9. |
| 22 | Store `test/support/concept_names.json` | Concept names for the 857 library books | Taken from the library books (item 1). |

Items in the register: 22 (they cover 857 library books, 857 store copies and 858 course covers).

## Checked, but not WGU-derived (not part of the gift unless I say so)

| Path | Why it is not on the list |
|---|---|
| `/Users/eriklindquist/Desktop/Workspace/JOSHUA/INDEX.md` | An index of my register. It points to items above but is not WGU material. |
| Store (the rest): checkout, orders, webhook, listings code, `priv/KDP_LISTINGS.json` | The store engine and my six original books' listings. |
| The five Armored books (ServiceNow ITSM, Customer Service Management, Now Assist Skill Kit, Genesys Cloud CX, Integration: Whisper, Warm, Hot), their covers, the KDP listing sheet, *The Traveler's Guide* (public edition) | Mine; not built from WGU material (register A2). |
| Armored Fail Fast five-book set (store #865–#869) | My method, domain-free, invented example. It is behind the WGU IP clause check ("gate 2") because it sits in WGU's field, but it is not built from WGU material. |
| Guided Mastery Framework, Course Mastery Coach Framework, Guided Mastery Case Study (packets 5–7) | My methods. Also behind gate 2. The case study tells about my own C213 study as a student. |
| Vault `60_Canvas/` | A plan only; nothing built. Its own rule keeps WGU content out. |
| Vault `00_MIND/Fail Forward/Fail Forward - WGU.md` | My notes about WGU's history, from public news. It is about WGU, not WGU's material. |
| Vault `00_MIND/Day 0 - Read this first.md` | My letter to myself; it only mentions my WGU MBA. |
| `/Users/eriklindquist/Desktop/Workspace/JOSHUA/US Trade Force/` (concept v1–v3) | My U.S. Trade Force concept; no WGU content. |
| Vault `40_Courses/Orientation/` | Records (orientation, re-admit notes, mentor messages), not a work. |
| The vault folder name "WGU" | Only a folder name. Most of what sits in it is mine, not WGU's. |

## Note

A gift of I.P. usually becomes final only when I sign a written assignment and WGU accepts it. A lawyer can confirm. The draft letter is in `WGU IP - Gift letter DRAFT.md`, next to this file. I have not sent it.
