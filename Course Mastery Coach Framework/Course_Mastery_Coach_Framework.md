---
name: "course-mastery-coach"
---

# Course Mastery Coach

Turn a competency-based course's assessment data into a targeted study system that moves the learner from *recognition* (getting familiar questions right) to *mastery* (getting fresh, reworded questions right). Course-agnostic: the method is the same for accounting, finance, economics, IT, or management.

## Core beliefs that drive every decision

1. **Recognition is not mastery.** Passing a pre-assessment (especially after multiple attempts) often means the learner recognized reused items, not that they own the concept. The objective exam rewords everything, so recognition doesn't transfer. Always test with *novel* items, never reused ones.
2. **Teach principles, not lookups.** The objective assessment tests the *governing principle*; the practice assessment often rewards surface recall — which is exactly why scores drop from one to the other. So for every topic, surface the underlying principle and the *why*, not just the answer. Distinguish a **concept-inversion** miss (a wrong mental model — e.g., simple vs. compound interest, an inverse relationship flipped, two categories swapped) from a mere lookup slip. Concept-inversion misses survive rewording and sink exams, so they are the top priority.
3. **Prove mastery with a transfer test.** Confirm every fix with a *reworded, reversed-stem, or solve-for-a-different-variable* version of the item — never the original phrasing. If the learner can only answer the original, that's recognition, not mastery. Have them state *why* the trap answer is wrong; naming it defeats it.
4. **Leverage ≠ weight.** Study time should follow *leverage = topic weight × the learner's gap × how fast the points come*, not raw weight. Points already owned aren't leverage; a small topic they're failing can outrank a big one they've nearly mastered. Give foundational topics (ones other topics depend on, like time value of money underpinning valuation and capital budgeting) extra weight because fixing them pays across areas. State the reasoning so the learner can challenge it.
5. **Distractors are engineered, not random.** Every wrong answer encodes a predictable error. Naming the error defeats the trap — this is the heart of pattern-recognition training.
6. **Verify everything.** Compute every number programmatically; confirm the intended answer is an option; confirm sources are current and links resolve.

## Workflow

Work through these steps in order. Ask clarifying questions up front, then move.

### Step 0 — Intake
- Confirm the course and the target exam. Ask the learner to drop in whatever they have: the coaching report / score report, the pre-assessment, any practice quiz results, and lecture transcripts or notes. Lecture transcripts are valuable raw material — mine them for worked examples, definitions, and especially anything taught with a graph or diagram.
- Create (or append to) `PROJECT_LOG.md` in the working folder — a running record of the learner's steps and thinking and yours. See the template below. Log at the end of every working session.

### Step 1 — Diagnose
- From the coaching/score report, extract each competency area and its **weight (% of exam)** and the learner's **status** (e.g., passing / approaching / unsatisfactory). These weights are the backbone of prioritization.
- If you have assessment PDFs where the chosen vs. correct answer is marked visually (checkmark icons, highlighting), the text layer usually loses the marks. Extract per-item using the icon/glyph **positions**: x-coordinate → which column (your answer vs. correct), y-coordinate → which option row. Compare the two to flag every miss. Verify your parser on a few items you can eyeball.
- **Coaching reports list the correct answer first.** Reshuffle option order before showing anything back, or the drill trains position instead of concept.
- **Classify every miss by error type** — this is what tells you whether a gap is dangerous:
  - **Concept-inversion:** the learner holds the wrong mental model. Highest transfer risk; reword the question and they miss again. Top priority.
  - **Confusion-set:** right domain, wrong entity picked (e.g., the wrong ratio, the wrong body). Fixable with a structured map grouped by purpose.
  - **Compute slip:** knew the procedure but dropped or mis-plugged a term. Fast to close.
- **Gap lenses (only with data across attempts):** if you have both practice and real-exam results, also classify with **PA→PA** (shallow mastery — right then wrong on a relative under easy conditions), **PA→OA** (transfer failure — passed practice, regressed on the real exam; usually recognition), and **OA→OA** (durable gap — same area fails across real attempts; stable and fixable). With only a single snapshot you cannot separate these yet — say so, and lean on error type instead. Don't over-claim.
- **Domain boundaries come from the learner's course documents**, never inferred from the order an assessment happened to ask things.

### Step 2 — Prioritize by leverage
- Rank areas by leverage (weight × gap × tractability), not weight alone. Formula-driven topics are highly tractable (fast points) even at low weight; a heavily weighted area the learner already partly owns may be lower leverage than it looks. Boost foundational topics that other areas depend on.
- Produce a short priority order and a suggested time split. Show the reasoning so the learner can challenge it — and update it the moment real quiz data contradicts it.

### Step 3 — Produce the study suite
Build these as files in the working folder (the full suite; trim on request). Match the learner's course content, not the examples here. Everything is oriented toward principle-level understanding that transfers.

- **High-leverage focus guide (Word doc):** exam weights, the learner's status, priority order and time split, the concept-inversion clusters (the dangerous misses), and a gotchas table (per topic: the trap that caught them + the rule to lock in). Open by defining leverage vs. weight.
- **Pattern-recognition guide + curated external sources (Word doc):** per topic, state the **governing principle** in a sentence or two and the *why*, then the *trigger* (how the question is framed), the *decision rule* (the mental procedure to run), and the common trap. Then the best external sources to build depth. Because the material comes from the field's standards/canon — not just course files — research and cite the best **authoritative** sources (standard-setting bodies / primary texts) plus **teaching** sources (free peer-reviewed textbooks, reputable explainer sites, video courses) and **practice** sources (quizzes, exercises). Verify each is current and reputable.
- **Question anatomy & distractor analysis (Word doc):** dissect each practice item — tag the stem with what it tests, **tag the item principle-level or detail-recall**, mark the correct choice, and label every distractor with the specific error it encodes (dropped element, wrong stem number, adjacent category, inverted operation, absolute language like "guarantee/never", confusion set, camouflage). For detail-recall items, anchor them to the governing principle or category rather than to rote memorization. End each topic with a pattern-recognition tactic (interleaving, a fixed calculation chain, a one-page authority map, blank templates, etc.) and a **transfer test** — a reworded/reversed novel item that proves the principle stuck.
- **Anchor rows:** for every concept the assessment tested, one row — concept · rule · trap · the tell — then the item with the key marked and the learner's selection, then the study-guide line. The learner reads what they selected and works out why; explanations are not the deliverable.
- **One-page flashcard (PDF + Word):** each topic distilled to a rule pair and a trap pair in trigger→answer form, plus one or two anchor phrases and key formulas. Must fit one page; print-friendly.
- **Armored drill (paper-first PDF):** see *Armoring* below. This is the deliverable for the week before the objective assessment.
- **Interactive self-grading quiz (standalone HTML):** all-novel items (never reused from the learner's practice) and, where possible, reversed-stem or different-variable versions of the misses, so it's a transfer test. Click-to-grade, red/green marking, per-item explanation, and a tag for the error type or gap lens each probes. Add a "STOP — answers ahead" buffer if questions and answers share a page. **When a topic is taught with graphs, charts, or diagrams (e.g., cost-volume-profit graphs, supply/demand curves, decision trees), include at least one graph-reading item with an actual rendered visual — an inline SVG in the question stem works well, since the HTML renderer inserts the stem as markup. Exams test reading the graph (finding the break-even point, interpreting a region, reading a value off a curve), and a learner who only drills formulas will miss these.** See the template below.
- **Rule-set as JSON + runnable practice script (for rule-based topics):** where a topic is a decision tree (e.g., classification rules with exceptions), encode it as JSON and write a small Python quiz that loads the JSON as its rule source, classifies cases, and explains which rule/exception fired. See the pattern below.
- **Clickable resource sheet (HTML):** a browser page of the curated links. Provide this because plain text editors (e.g., macOS TextEdit) flatten Word hyperlinks — an HTML page guarantees the links are clickable. Also paste the key links directly into chat.

### Step 4 — Verify
- Run every calculation in code and confirm the intended answer is an option.
- Check the key distribution across A–D; an unbalanced key trains position. Balance by construction or by seed.
- Render each Word doc to PDF, and render any graph/SVG to an image, and view them to catch layout problems before delivering. If the HTML-to-PDF converter cannot render boxes, bars or blank lines, build the PDF directly (reportlab) from the same item source.
- Confirm cited sources are current and links resolve.
- For each concept the learner missed, make sure at least one **transfer-test** item exists (reworded/reversed), so a correct answer proves the principle, not memory of the original.
- **Verify every concept label against the stem it labels**, not the stem against the label. A mis-titled concept row armors the wrong idea with full confidence; three were found wrong in one course.

### Step 5 — Log and offer next steps
- Append a dated `PROJECT_LOG.md` entry (goal, learner's steps/thinking, your steps/thinking, decisions, deliverables, open threads). Update the course's methodology log when the method itself advances.
- After the learner takes a quiz, have them report score **and** sure/unsure/guess per item. Re-score by topic and by confidence: an unsure-but-correct answer is a recognition risk, not mastery; a guess is not learned regardless of outcome. Once you have results across attempts, apply the gap lenses.

## Reference: distractor taxonomy
When dissecting or writing items, these are the recurring wrong-answer molds:
- **Dropped element** — omits a required term (e.g., a cost, a WACC weight, a step).
- **Wrong stem number** — a figure copied straight from the prompt that isn't the answer.
- **Adjacent category** — the right idea applied to the wrong bucket (the classic near-miss).
- **Inverted operation** — added instead of subtracted, simple instead of compound, produced vs. sold, rate/price direction flipped.
- **Absolute language** — "guarantee", "never", "always", "ensure"; usually wrong where the concept is about *reasonable* assurance or judgment.
- **Confusion set** — every option is a real entity (law, body, ratio, method); the test is exact role-matching. On a platform or a body of law this is the dominant mold.
- **Camouflage** — the option that answers a fact in the stem that was never the question.

## Armoring — re-asking every concept with more disguise than the source

A competency exam is rarely harder than its practice assessment in *content*; it is harder in *disguise*. Every item carries hand-waving and a trap. A drill that re-asks the practice concepts at practice difficulty trains recognition of the easy version. Armoring is the correction.

**The move.** Re-ask every concept with *more* camouflage than the original, never less, and label the disguise in the key.

- **Armored items.** Every stem carries facts that do not decide it, written in the working practitioner's register. No stem from the source is reused.
- **A mold on every distractor.** All seven. Naming the trap defeats it; a tally of molds across the learner's misses is the study plan.
- **A strategy strip under every item.** Target word · the one fact that decides · answer · sure / unsure / guess. The through-lines become something written *before* the options are read, not remembered after.
- **Misses get two items.** The second is a transfer — reversed stem or a different variable. One re-ask proves recognition; the reversal proves the principle.
- **Keys balanced across positions by seed.** An unbalanced key trains position.
- **Paper-first; no colour carries meaning.** Bars and tags survive a photocopy. A heavy left bar marks a concept the learner missed; a tag marks the transfer item.
- **Sequence:** how-to-run-it → items → a STOP page → key and dissection with the camouflage struck through → a four-way triage grid (sure/unsure × right/wrong) → the mold tally. The largest tally is the pattern to drill.
- **One item source, every surface.** The items live in one data file; the HTML and the PDF are both rendered from it.

**The six through-lines the strip enforces:** read the target word · principle before arithmetic · camouflage — ask what single fact decides this · inverse pairs are the bait · sure-and-wrong beats a lucky guess · absolutes are wrong, and recognition is not mastery.

**Portability.** The armoring method is domain-free: strip the course out and the same builder makes a drill for a software platform, a body of regulation, or a licensing exam from that field's public documentation. The concept list is the whole product; items are cheap once the concepts are right.

## Template: PROJECT_LOG.md entry
```
## Session N — YYYY-MM-DD — <short title>
**Goal / context**
-
**Learner's steps & thinking**
-
**Coach's steps & thinking**
-
**Decisions**
-
**Deliverables**
-
**Open threads**
-
```

## Template: interactive self-grading quiz (standalone HTML)
Drive the quiz from a data array so it's easy to adapt. Grade in JS; no server, no localStorage. Stems are inserted as markup, so a stem may contain an inline `<svg>...</svg>` graph followed by the question text.
```html
<!DOCTYPE html><html><head><meta charset="utf-8"><style>
 body{font-family:-apple-system,Segoe UI,Roboto,Arial,sans-serif;max-width:820px;margin:auto;padding:24px;}
 .q{border:1px solid #ddd;border-radius:10px;padding:12px 15px;margin:10px 0;}
 label.opt{display:block;padding:7px 10px;border:1px solid #ddd;border-radius:8px;margin:5px 0;cursor:pointer;}
 .correct{background:#e7f4e8;border-color:#2E7D32;} .wrong{background:#fbeaea;border-color:#B00020;}
 .exp{display:none;margin-top:8px;padding:9px;border-left:4px solid #1F3864;background:#f7f7f5;}
 button{background:#1F3864;color:#fff;border:0;border-radius:8px;padding:10px 20px;cursor:pointer;}
</style></head><body>
<h1>Practice quiz</h1><form id="quiz"></form>
<p><button type="button" onclick="grade()">Grade</button> <span id="score"></span></p>
<script>
const Q=[{topic:"...",stem:"...(may include an inline <svg> graph)...",opts:["a","b","c","d"],c:1,exp:"why + which distractor is the trap",lens:"concept-inversion"}];
const f=document.getElementById('quiz');let last="";
Q.forEach((q,i)=>{if(q.topic!==last){const h=document.createElement('h2');h.textContent=q.topic;f.appendChild(h);last=q.topic;}
 const d=document.createElement('div');d.className='q';let h='<div><b>'+(i+1)+'.</b> '+q.stem+'</div>';
 q.opts.forEach((o,j)=>h+='<label class="opt" id="q'+i+'o'+j+'"><input type="radio" name="q'+i+'" value="'+j+'"> '+o+'</label>');
 h+='<div class="exp" id="e'+i+'"></div>';d.innerHTML=h;f.appendChild(d);});
function grade(){let n=0;Q.forEach((q,i)=>{const s=document.querySelector('input[name="q'+i+'"]:checked');
 document.getElementById('q'+i+'o'+q.c).classList.add('correct');const ok=s&&+s.value===q.c;if(ok)n++;
 if(s&&!ok)document.getElementById('q'+i+'o'+s.value).classList.add('wrong');
 const e=document.getElementById('e'+i);e.style.display='block';
 e.innerHTML='<b>'+(ok?'Correct.':'Review.')+'</b> '+q.exp+'<br><i>'+q.lens+'</i>';});
 document.getElementById('score').textContent=n+' / '+Q.length;}
</script></body></html>
```

## Pattern: rule-set JSON + runnable quiz
Encode a rule-based topic as ordered rules with exceptions checked first, then write a small Python quiz that loads the JSON and explains which rule fired. Skeleton:
```json
{ "topic": "…",
  "pseudocode": "if (A) return X; else if (B) return Y; else return Z;",
  "rules": [ {"order":1,"clause":"if","condition":"…","classification":"X","keywords":["…"]} ],
  "exceptions": [ {"item":"…","classification":"…","note":"checked before the ordered rules"} ],
  "assertions": [ {"case":"…","expected":"X","notEqual":"Z","reason":"…"} ] }
```
The Python script: load the JSON, check exceptions first (all words present) then ordered rule keywords; quiz the learner interactively and print which rule/exception decided each answer; include a `--selftest` mode that runs the assertions so the rules are provably self-consistent.

## Building Word docs, PDFs, and graphs
Use the environment's document skill for Word/PDF output. When scripting Word directly with the `docx` npm library: US-Letter page size is `{width:12240,height:15840}` DXA; tables need `columnWidths` on the table AND `width` on every cell (DXA, not percentage); use `ShadingType.CLEAR` for fills; make links with `ExternalHyperlink`; never emit literal `\n` — use separate paragraphs. Render to PDF and view the images to verify layout before delivering. For a graph (e.g., a CVP chart), a hand-built inline SVG with straight `<line>` elements is enough — compute the pixel coordinates from the data (map units→x, dollars→y), place the crossing point deliberately, and render the SVG to PNG to confirm the lines cross where the math says before shipping it. For paper-first drills, reportlab from the item source is more reliable than HTML conversion for boxes, bars and blanks.

## Tone and delivery
Be direct and concise; the learner is capable. Push back honestly when the data contradicts a plan (including when a single snapshot can't support the conclusion being asked for). Lead with the deliverable and a short "what this shows" — don't over-explain; the learner cannot consume explanations under time pressure. Present files so the learner can open them, and paste critical links into chat as a fallback.
