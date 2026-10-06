# PROGRAMS.json — School > Program > Course

The store's navigation data: for each school, its programs, and for each program its courses in program-guide order,
each course naming the store books (product slugs) that drill it.

| | |
|---|---|
| Source | Western Governors University, *Institutional Catalog*, 2026 University Catalog, Volume MMXXVI, No. 9, September 2026 (pages dated August 25, 2026) — the public PDF at https://www.wgu.edu/content/dam/wgu-65-assets/western-governors/documents/institutional-catalog/2026/catalog-september-2026.pdf (the newest month published; the October 2026 file was not yet available) |
| Retrieved | 2026-09-25 |
| What was read | "Academic Programs": every degree and endorsement program's standard-path table (courses listed by term, in the catalog's order), in the catalog's four schools. The standalone "Certificates - Standard Paths" at the end of the catalog are not programs and were not used. Every program's course credits add up to the catalog's stated total. |
| Programs | 115: Business 22, Technology 25, Health 22, Education 46 (program names as in the catalog's table of contents; schools listed in the store's order: Business, Technology, Health, Education) |
| Matching | Each catalog course was matched to Erik's library catalog (`WGU_Armored_Drills/_source/catalog_2026-09.json`, 857 courses) by its course number, and each library course to its store book by the book file's SHA-256. All 857 library courses sit in at least one program, and every course in the catalog's programs is in the library. Course numbers were used only for this matching; none is stored here or shown anywhere in the store. Course names are the library catalog's titles. |
| Duplicates | A course in several programs is listed in every one of them (431 courses are in two or more programs). |
| Other courses | A school's courses that are in no current program would go in an entry named "Other courses" with `"other": true` (school = the library catalog's school field). With this catalog there are none, so there is no such entry. |
| Accounting for Decision Making | Store #7 (The Fail Fast Compendium) is a book for the course Accounting for Decision Makers, so it is listed with that course, after the course's Armored drill, wherever the course sits (the three MBA programs); it also stays in Originals. |
| Not in programs | The Armored Fail Fast set (domain-free) and the Originals #1–#6 are home-page sections, not programs. |

Format: a list of `{"school", "program", "slug", "courses": [{"course", "books": [product slug, ...]}]}`, schools in
store order and programs in catalog order. `lib/armored_store/programs.ex` reads it when the app compiles.
