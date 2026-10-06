#!/usr/bin/env python3
"""Build Armored Accounting for Decision Making: The Fail Fast Compendium (PDF + DOCX + cover).

One item source for the drill: items_a.py / items_b.py (the 81 armored items, option order
shuffled with the same fixed seed as the original drill, so every key matches it).
PA anchor data: pa_anchor.json (concept, rule, trap, tell, missed, per pre-assessment item).
OA data: the coaching report tables, transcribed below in OA_REPORT.
Usage: python3 build_compendium.py [out_dir]
"""
import os, sys, io, json, random, datetime, collections, re
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.enums import TA_CENTER
from reportlab.platypus import (BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, Table, TableStyle,
                                PageBreak, Image, Flowable)
from reportlab.platypus.tableofcontents import TableOfContents
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.fonts import addMapping
from xml.sax.saxutils import escape as e
from docx import Document
from docx.shared import Pt, Inches
from PIL import Image as PILImage, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "out")
os.makedirs(OUT, exist_ok=True)

SERIES = "Joshua Says"; AUTHOR = "Joshua"; TAG = "For people who already know the easy version."
TITLE = "Armored Accounting for Decision Making: The Fail Fast Compendium"
SHORT = "Armored Accounting for Decision Making"
SUB = "The drill at the centre. The Fail Fast PA method before it. The Fail Fast OA strategies after it."
SLUG = "Armored_Accounting_for_Decision_Making"
today = datetime.date.today().isoformat()

# fonts (DejaVu carries the arrows, minus, times, divide and bar glyphs that Helvetica does not)
FD = os.environ.get("DEJAVU_DIR", "/usr/share/fonts/truetype/dejavu/")
pdfmetrics.registerFont(TTFont("DV", FD + "DejaVuSans.ttf"))
pdfmetrics.registerFont(TTFont("DV-B", FD + "DejaVuSans-Bold.ttf"))
addMapping("DV", 0, 0, "DV"); addMapping("DV", 1, 0, "DV-B"); addMapping("DV", 0, 1, "DV"); addMapping("DV", 1, 1, "DV-B")

# the drill: same source, same seed, same shuffle as the original drill
from items_b import ITEMS
random.seed(213)
L = "ABCD"
MOLD = {"DROP": "dropped element", "STEM": "wrong stem number", "ADJ": "adjacent category", "INV": "inverted operation",
        "ABS": "absolute language", "CONF": "confusion set", "CAMO": "answers the camouflage"}
COMP = [(1, 15, "Competency 1 · The accounting environment and the statements"), (16, 21, "Competency 2 · Ratios and analysis"),
        (22, 29, "Competency 3 · Transactions and accrual"), (30, 35, "Competency 4 · The statement of cash flows"),
        (36, 42, "Competency 5 · Controls, fraud and oversight"), (43, 52, "Competency 6 · Management accounting and cost classification"),
        (53, 59, "Competency 7 · Activity-based costing"), (60, 65, "Competency 8 · Cost-volume-profit"), (66, 69, "Competency 9 · Credit and cash budgeting")]
def comp(q): return next(t for a, b, t in COMP if a <= q <= b)
prepared = []
for it in ITEMS:
    opts = it["opts"][:]; random.shuffle(opts); it2 = dict(it); it2["opts"] = opts
    it2["keys"] = [L[i] for i, o in enumerate(opts) if o[1] == "KEY"]; prepared.append(it2)
DIST = {k: sum(k in it["keys"] for it in prepared) for k in L}
MISSES = sorted({it["q"] for it in prepared if it.get("miss")})
MOLDCOUNT = collections.Counter(o[1] for it in prepared for o in it["opts"] if o[1] != "KEY")
assert len(prepared) == 81 and DIST == {"A": 20, "B": 24, "C": 27, "D": 27}, DIST
ITEMNO = collections.defaultdict(list)
for n, it in enumerate(prepared, 1): ITEMNO[it["q"]].append(n)

def cvp_png():
    W, H = 640, 400; im = PILImage.new("RGB", (W, H), "white"); d = ImageDraw.Draw(im)
    ox, oy = 70, 340; sx = (W - 100) / 400; sy = (oy - 30) / 10000
    def P(u, dol): return (ox + u * sx, oy - dol * sy)
    d.line([(ox, oy), (W - 20, oy)], fill="black", width=2); d.line([(ox, oy), (ox, 20)], fill="black", width=2)
    for u in range(0, 401, 100): x, _ = P(u, 0); d.line([(x, oy), (x, oy + 6)], fill="black"); d.text((x - 12, oy + 10), str(u), fill="black")
    for dol in range(0, 10001, 2500): _, y = P(0, dol); d.line([(ox - 6, y), (ox, y)], fill="black"); d.text((8, y - 6), f"${dol:,}", fill="black")
    d.text((W // 2 - 40, oy + 28), "units per month", fill="black")
    for u in range(0, 400, 8): d.line([P(u, 3000), P(u + 4, 3000)], fill="black", width=2)
    d.line([P(0, 3000), P(400, 7000)], fill="black", width=3)
    for u in range(0, 400, 16): d.line([P(u, 25 * u), P(u + 9, 25 * (u + 9))], fill="black", width=3)
    d.text((P(340, 6400)[0] - 20, P(340, 6400)[1] + 8), "total cost (solid)", fill="black")
    d.text((P(230, 25 * 230)[0] - 110, P(230, 25 * 230)[1] - 14), "revenue (dashed)", fill="black")
    d.text((P(20, 3000)[0], P(20, 3000)[1] + 6), "fixed (dotted)", fill="black")
    b = io.BytesIO(); im.save(b, "PNG"); return b.getvalue()
GRAPH = cvp_png()

# PA record
PA = json.load(open(os.path.join(HERE, "pa_anchor.json")))
PRIMARY = {it["q"]: it for it in ITEMS if not it.get("transfer")}
# Three anchor-row titles name a different concept than their own stem asks. The drill follows the stems.
FOLLOW_STEM = {16, 27, 60}
def pa_row(r):
    it = PRIMARY[r["q"]]
    if r["q"] in FOLLOW_STEM:
        return dict(q=r["q"], concept=it["concept"], rule=it["rule"], trap=it.get("why") or "—", tell=it["deciding"], miss=r["miss"])
    return dict(q=r["q"], concept=it["concept"], rule=r["rule"], trap=r["trap"], tell=r["tell"], miss=r["miss"])
PAROWS = [pa_row(r) for r in PA]
assert [r["q"] for r in PAROWS if r["miss"]] == MISSES

# OA record: the post-assessment coaching report, two attempts
OA_ATTEMPTS = ["May 20, 2025", "July 10, 2025"]
OA_REPORT = [  # area, weight, {attempt: status}, [(topic, {attempt: suggested study?})], drill competencies
 ("Financial Analysis", 51, {"May 20, 2025": "Approaching competence", "July 10, 2025": "Approaching competence"},
  [("Overview of Financial Statements", {"May 20, 2025": True, "July 10, 2025": False}),
   ("Introduction to Financial Statement Analysis", {"May 20, 2025": False, "July 10, 2025": True}),
   ("The Nature and Purpose of Accounting", {"May 20, 2025": False, "July 10, 2025": True}),
   ("The Income Statement", {"May 20, 2025": True, "July 10, 2025": True}),
   ("The Statement of Cash Flows", {"May 20, 2025": True, "July 10, 2025": True}),
   ("The Balance Sheet", {"May 20, 2025": True, "July 10, 2025": True})], [1, 2, 3, 4]),
 ("Controls and Regulations", 10, {"May 20, 2025": "Exemplary", "July 10, 2025": "Approaching competence"},
  [("Internal Controls", {"May 20, 2025": False, "July 10, 2025": True})], [5]),
 ("Cost Systems", 26, {"May 20, 2025": "Competent", "July 10, 2025": "Approaching competence"},
  [("Managerial Accounting and Cost Concepts", {"May 20, 2025": True, "July 10, 2025": False}),
   ("Activity-Based Costing", {"May 20, 2025": False, "July 10, 2025": True})], [6, 7]),
 ("Profit Planning", 7, {"May 20, 2025": "Approaching competence", "July 10, 2025": "Approaching competence"},
  [("Cost-Volume-Profit Analysis", {"May 20, 2025": True, "July 10, 2025": True})], [8]),
 ("Budgeting", 6, {"May 20, 2025": "Competent", "July 10, 2025": "Unsatisfactory"},
  [("Cash Budgeting", {"May 20, 2025": False, "July 10, 2025": True})], [9]),
]
def comp_range(c): a, b, _ = COMP[c - 1]; return a, b
def area_misses(cs): return [q for q in MISSES if any(comp_range(c)[0] <= q <= comp_range(c)[1] for c in cs)]
def area_items(cs): return [n for n, it in enumerate(prepared, 1) if any(comp_range(c)[0] <= it["q"] <= comp_range(c)[1] for c in cs)]

# the refresher rows (rule, trap, example -> answer), grouped by OA area
TAGS = {"G": "owned — bank it", "Y": "lock it — run the rule deliberately", "R": "survived rewording — say the rule aloud first"}
REFRESHER = [
 ("Financial Analysis — half the exam", [
  ("G", "Statements & purpose", "Balance sheet = a date. Income & cash flow = a period. Methods and policies live in the notes.", "Hunting a disclosure on the face of a statement.", "Position at a date; where is the depreciation method? → Balance sheet, in the notes"),
  ("Y", "Accounting equation", "E = A − L. Long-term = total − current. Read the target word before touching a number.", "Adding A and L; stopping at a subtotal.", "A 300k, L 220k, current assets 40k → equity = 80,000"),
  ("R", "Revenue & equity", "Revenue is earned, not collected. It raises assets and equity — never a liability.", "The word owes → liability. Will pay → waiting for cash.", "10k of services in June, paid in July → assets + equity up 10k in June"),
  ("R", "Matching & proration", "Expense only the months used: cost × months ÷ 12.", "Computing depreciation because equipment is in the stem.", "6,000 policy paid May 1, equipment 500k / 5 yrs, YE Dec 31 → 4,000 (×8/12)"),
  ("R", "Which statement?", "Revenue, expense, gain, loss → income statement. A, L, E → balance sheet.", "Over-inclusion — it \"sounds financial.\"", "Pick the IS items: Sales rev · AR · COGS · Retained earnings → Sales revenue + COGS"),
  ("Y", "Ratios by purpose", "Liquidity = current ÷ current. Solvency = D/E. Profitability = ROE. Valuation = P/E.", "A total where a current figure belongs; inverted fraction.", "CA 50k, CL 25k, total assets 200k → current ratio 2.0"),
  ("G", "Cash flows — what moved?", "Long-term asset moved → investing. Owners or lenders → financing. Everything else → operating.", "Selling equipment feels operating. Dividends paid are financing.", "Sells a delivery truck for 15k cash → investing"),
  ("Y", "Qualitative characteristics", "Losses early, gains late = conservatism. Verifiable → reliability · decision → relevance · size → materiality.", "Reading conservatism as conserving something.", "Books a probable loss, defers a possible gain → conservatism"),
  ("Y", "Decision process order", "Prepare and analyze → gather → decide → implement.", "Assuming you gather first.", "Step immediately before gathering → analyze the problem")]),
 ("Cost Systems — a quarter", [
  ("G", "Product vs period", "In the factory = product (DM, DL, MOH). Sold or office = period.", "Calling a cost product because it is large or says salary.", "Lumber · factory supervisor salary · sales commissions · factory utilities → period = sales commissions"),
  ("Y", "Cost of goods sold", "÷ units produced, × units sold. Unsold sits in inventory, an asset.", "Using the same unit count twice.", "60k total cost, 10,000 produced, 8,000 sold → 48,000"),
  ("Y", "Overhead applied", "Predetermined rate × actual activity.", "Applying to budgeted activity — the seductive word.", "$5/machine-hour set on budget 10,000, actual 12,000 → 60,000"),
  ("R", "Activity-based costing", "Classify by how often it happens: unit · batch · product line · facility.", "Machine pulling to unit-level; production pulling to product-level.", "Setup cost each time a run begins → batch-level")]),
 ("Profit Planning (CVP)", [
  ("G", "The CVP ladder", "CM = price − variable. Break-even units = fixed ÷ CM. Target = (fixed + profit) ÷ CM.", "Dividing fixed by price or by variable cost.", "80 / 50 / fixed 150k → 5,000 units (CM 30)"),
  ("R", "Reading the graph", "Left of the crossing = loss; the gap between the lines is the amount. Read tick marks, not slopes.", "Assuming the top line is revenue.", "Lines cross at 4,000; at 3,000 units the firm → incurs a loss")]),
 ("Budgeting", [
  ("Y", "Collections & payments", "This month × current rate + last month × lag rate.", "Flipping the rates; forgetting the lag.", "Jun 50k, Jul 80k, 60% / 40% → July collections 68,000"),
  ("Y", "The cash budget", "Begin + receipts − disbursements = cash before financing. Borrow up to the minimum, not to zero.", "Borrowing only the shortfall to zero. Minus a negative adds.", "10 + 60 − 75, minimum 8 → borrow 13,000"),
  ("R", "Pro-forma percentages", "Undo an increase: divide by (1 + rate). Apply one: multiply.", "Multiplying to reverse. Inverse pairs are always the bait.", "330k is +10% over this year → this year = 300,000"),
  ("Y", "Credit policy", "Bad debt is driven by credit limits and standards — who qualifies.", "Reaching for payment terms: discounts, net days.", "Which raises bad debt? 2% discount vs → extending credit to lower-rated customers")]),
 ("Controls & Regulations — definitional, no math", [
  ("G", "Who does what", "S → Standards → FASB. A → Audits auditors → PCAOB. Oversees/regulates = a body; governs/was passed = a law.", "FASB↔PCAOB and SEC↔SOX look-alikes.", "Who establishes GAAP? SEC oversees but delegates → FASB"),
  ("Y", "Which law", "Scandals → Sarbanes-Oxley (2002). Downturn → Dodd-Frank (2010).", "Swapping the two crises.", "Created the PCAOB after accounting scandals → Sarbanes-Oxley"),
  ("G", "Internal control", "Reasonable, never absolute assurance. Duties split: custody · recording · reconciliation.", "Anything with guarantee, eliminate, always, never.", "Who records ≠ who deposits → segregation of duties")]),
]
THROUGH = [
 ("Read the target word.", "Equity or long-term · product or period · produced or sold · this month or last. The word picks the operation."),
 ("Principle before arithmetic.", "Say the rule in a sentence, then compute. Backing into numbers fails under pressure."),
 ("Camouflage.", "Ask what single fact decides this, then ignore the rest — especially impressive numbers from another question."),
 ("Inverse pairs are the bait.", "× / ÷ and + / −. If one is an answer choice, the other is the trap."),
 ("Sure-and-wrong beats a lucky guess.", "Fix the model, not the pace. Clusters cascade: one miss, slow down for the next three."),
 ("Absolutes are wrong; recognition is not mastery.", "Guarantee, never, always, eliminate. Familiar still has to pass the rule.")]
TESTDAY = ["Calculator AOS, decimals floating — before question one.",
 "Read the last line of the stem first (the question), then the data.",
 "Say the rule → compute → name the trap you rejected.",
 "Mark sure / unsure and move. Pace check at halfway.",
 "Reflexes: Controls → body, law, absolute word. Cash flow → what moved. CVP → CM first."]
CALC = ["Turn on order-of-operations (AOS). By default the BA II Plus is in Chn (chain) mode, which goes strictly left-to-right — it will get \"a×b + c×d\" collections problems wrong. Set AOS: 2ND FORMAT ↓ ↓ ↓ ↓ then 2ND SET until the screen shows AOS, then 2ND QUIT.",
 "Set decimals to floating so nothing rounds mid-problem: 2ND FORMAT 9 ENTER 2ND QUIT.",
 "Clear between problems: press CE|C twice. To make a number negative, use the +/− key.",
 "You will not need the finance keys (N, I/Y, PV, PMT, FV, CF, NPV) — this course is plain arithmetic. Ignore them.",
 "Chn-safe fallback (if you ever forget to set AOS): for a×b + c×d, compute each product with = first, then add the two results."]
MOLD_DEF = [("dropped element", "Omits a required term — a cost, a step, a month."),
 ("wrong stem number", "A figure copied straight from the prompt that isn't the answer."),
 ("adjacent category", "The right idea applied to the wrong bucket — the classic near-miss."),
 ("inverted operation", "Added instead of subtracted, produced vs. sold, a rate or price direction flipped."),
 ("absolute language", "\"Guarantee\", \"never\", \"always\", \"ensure\" — usually wrong where the concept is reasonable assurance or judgment."),
 ("confusion set", "Every option is a real entity — a body, a law, a ratio, a method; the test is exact role-matching."),
 ("answers the camouflage", "The option that answers a fact in the stem that was never the question.")]
MOLD_KEY = {"dropped element": "DROP", "wrong stem number": "STEM", "adjacent category": "ADJ", "inverted operation": "INV",
            "absolute language": "ABS", "confusion set": "CONF", "answers the camouflage": "CAMO"}

# struck camouflage in each refresher example, exactly as in the source rows
STRUCK = {"Accounting equation": ["current assets 40k"], "Revenue & equity": ["paid in July"], "Matching & proration": ["equipment 500k / 5 yrs"],
 "Which statement?": ["Retained earnings"], "Ratios by purpose": ["total assets 200k"], "Cash flows — what moved?": ["delivery truck"],
 "Qualitative characteristics": ["defers a possible gain"], "Product vs period": ["factory supervisor salary"], "Cost of goods sold": ["10,000 produced"],
 "Overhead applied": ["budget 10,000"], "Activity-based costing": ["each time a run begins"], "Reading the graph": ["4,000"],
 "The cash budget": ["minimum 8"], "Pro-forma percentages": ["+10% over this year"], "Credit policy": ["2% discount"],
 "Who does what": ["SEC oversees but delegates"], "Which law": ["accounting scandals"], "Internal control": ["records", "deposits"]}

# shared prose (used by PDF and DOCX)
INTRO = [
 "This is a working book, built from one learner's real results in Accounting for Decision Making. It has one centrepiece and two wings.",
 "<b>The centrepiece is the drill</b> — 81 armored items: every concept the pre-assessment tested, re-asked with more camouflage than the original, plus a second, transfer item for each concept that was missed. Every distractor is labelled with the error it encodes.",
 "<b>Before it comes the Fail Fast PA method.</b> Take the pre-assessment early and let it fail you where you are weak. Narrate it, mark your confidence, pull the report, and sort every item. The misses and the sure-and-wrong answers are the study plan; nothing is ranked by topic weight alone.",
 "<b>After it come the Fail Fast OA strategies,</b> drawn from the post-assessment coaching report: what the objective assessment actually weighed, where it said <i>approaching</i> twice, where it swung from owned to lost, and the rules, traps and test-day reflexes that answer each area.",
 "<b>Around all three is the compendium:</b> a study plan that runs PA → drill → OA in order, a glossary of every concept with its rule, an index from concept to item number, an answer key at a glance, and a mold reference.",
 "The objective assessment is not harder than the pre-assessment in content. It is harder in disguise. Every item carries hand-waving and a trap. That is why this book drills the disguise.",
]
HOWTO = [
 ("1", "<b>Read the target word first.</b> Write it on the line before you read the options. Equity or long-term · product or period · produced or sold · this month or last · total or per unit."),
 ("2", "<b>Name the one fact that decides.</b> Everything else in the stem is camouflage. Write the fact; cross the rest out in your head."),
 ("3", "<b>Principle before arithmetic.</b> Say the rule in a sentence. Then compute."),
 ("4", "<b>Inverse pairs are the bait.</b> If × and ÷, or + and −, are both on offer, one is the trap. Absolutes — guarantee, never, always — are wrong."),
 ("5", "<b>Mark confidence honestly.</b> Sure-and-wrong is a concept inversion, and it is the only thing worth finding this week."),
 ("6", "<b>Grade in Part B.</b> Every distractor carries the error it encodes. Name the mold you fell for; naming it defeats it."),
 ("▌", "<b>Bars.</b> A heavy left bar marks a concept missed on attempt 3. Each has a second item tagged TRANSFER that asks it from the other side.")]
BELIEFS = [
 ("Recognition is not mastery.", "Passing a pre-assessment — especially after multiple attempts — often means recognising reused items, not owning the concept. The objective exam rewords everything, so recognition does not transfer. Test with novel items, never reused ones."),
 ("Teach principles, not lookups.", "The objective assessment tests the governing principle; the practice assessment often rewards surface recall — which is exactly why scores drop from one to the other. For every topic, surface the principle and the why."),
 ("Prove mastery with a transfer test.", "Confirm every fix with a reworded, reversed-stem, or solve-for-a-different-variable version — never the original phrasing. State why the trap answer is wrong; naming it defeats it."),
 ("Leverage ≠ weight.", "Study time follows leverage = topic weight × your gap × how fast the points come. Points already owned are not leverage; a small topic you are failing can outrank a big one you have nearly mastered."),
 ("Distractors are engineered, not random.", "Every wrong answer encodes a predictable error. Naming the error defeats the trap."),
 ("Verify everything.", "Compute every number; confirm the intended answer is an option; check the key is balanced across A–D.")]
THINK = [("Number", "“Question 7…” — so the reasoning lines up with the results later."),
 ("Concept", "“This is a ___ question.” — what topic or idea it tests."),
 ("Answer", "“I'll pick ___, because ___.”"),
 ("Confidence", "Say one: SURE / SHAKY / GUESS. SURE = I know it. SHAKY = leaning, could be wrong. GUESS = eliminating / coin-flip.")]
THINK_EX = "“Question 12. This is a cost-systems, product-vs-period question. I'll pick sales commissions as the period cost, because it's not in the factory. Confidence: sure.”"
THINK_AFTER = ["Open the pre-assessment results report (it shows your answer vs. the correct answer).",
 "Save or scan it to PDF, and keep it with your narration transcript (your Mac or phone can auto-transcribe the audio).",
 "If the report's order differs from how you narrated, your spoken question numbers (or a few key words per item) let you match them.",
 "Record only the unproctored pre-assessment. Never record the proctored objective assessment — it breaks the exam rules."]
READ_REPORT = [
 "<b>The report lists the correct answer first.</b> Reshuffle option order before you study from it, or the drill trains position instead of concept.",
 "<b>The marks are pictures, not text.</b> If the report shows your answer and the correct answer as icons, the text layer loses them. Read them by position: the column says which (your answer or correct), the row says which option.",
 "<b>Classify every miss by error type.</b> <i>Concept-inversion</i> — a wrong mental model; reword the question and it misses again; top priority. <i>Confusion-set</i> — right domain, wrong entity (the wrong ratio, the wrong body); fixable with a map grouped by purpose. <i>Compute slip</i> — knew the procedure, dropped or mis-plugged a term; fast to close.",
 "<b>Verify the label against the stem, not the stem against the label.</b> A mis-titled concept armors the wrong idea with full confidence. Three anchor titles here named a different concept than their own stems asked (Q16 is price-earnings, not current ratio; Q27 is prepaid insurance, not depreciation; Q60 is operating income with a price change). The rows below follow the stems; the current-ratio concept survives as Q16's transfer item.",
]
TRIAGE = [("", "Right", "Wrong"),
 ("Sure", "Owned. Bank it.", "Concept inversion. Top priority. Say the rule aloud; redo the transfer item tomorrow."),
 ("Unsure", "Recognition, not mastery. Redo from the rule, not the memory.", "Not learned. Read the rule, then the transfer item."),
 ("Guess", "Luck. Treat as not learned.", "Not learned.")]
ARMOR = [
 ("Armored items", "Every stem carries facts that do not decide it, in the working-accountant register. No stem from the source is reused."),
 ("A mold on every distractor", "All seven. Naming the trap defeats it; a tally of molds across your misses is the study plan."),
 ("A strategy strip under every item", "Target word · the one fact that decides · answer · sure / unsure / guess — written before the options are read, not remembered after."),
 ("Misses get two items", "The second is a transfer — reversed stem or a different variable. One re-ask proves recognition; the reversal proves the principle."),
 ("Keys balanced across positions by seed", f"An unbalanced key trains position. This drill's key: A {DIST['A']} · B {DIST['B']} · C {DIST['C']} · D {DIST['D']}."),
 ("Paper-first; no colour carries meaning", "Bars and tags survive a photocopy. A heavy left bar marks a missed concept; a tag marks the transfer item."),
 ("Sequence", "How to run it → items → a STOP page → key and dissection with the camouflage struck through → a four-way triage grid → the mold tally. The largest tally is the pattern to drill.")]
LENSES = [["Lens", "What it looks like here", "Areas"],
 ["OA → OA · durable gap", "The same area fails across real attempts. Stable and fixable — the model is wrong the same way twice.",
  "Financial Analysis (income statement, cash flows, balance sheet flagged both times) · Profit Planning (CVP flagged both times)"],
 ["Owned, then lost · shallow mastery", "Right on one attempt, wrong on the next under the same conditions. Recognition, not a model. Treat as not owned.",
  "Controls and Regulations (Exemplary → Approaching) · Cost Systems (Competent → Approaching) · Budgeting (Competent → Unsatisfactory)"],
 ["PA → OA · transfer failure", "Passed the practice, regressed on the real exam. Usually recognition of reused items.",
  "The pre-assessment was passed on attempt 3 while the objective assessment reads Approaching — the reason Part Two drills disguise, not content."]]
LEVERAGE = [
 ("1", "Financial Analysis", "Half the exam (51%). Approaching competence on both attempts, and three topics — the income statement, the statement of cash flows and the balance sheet — carried Suggested Study both times: the durable-gap signature. Foundational: the statements feed ratios, cash flows and budgeting. Four PA misses sit here."),
 ("2", "Profit Planning (CVP)", "7%, but Approaching on both attempts with Cost-Volume-Profit Analysis flagged both times — durable. Formula-driven, so the points come fast: one ladder (CM → break-even → target) and one graph rule. Two PA misses sit here, both with transfer items."),
 ("3", "Cost Systems", "A quarter of the exam (26%). Competent on May 20, Approaching on July 10 — owned, then lost: a recognition signature, not a durable model. The flagged topic moved (cost concepts first, activity-based costing second). Four PA misses sit here — the largest cluster after Financial Analysis."),
 ("4", "Budgeting", "6%. Competent, then Unsatisfactory — the steepest drop in the report. Pure arithmetic under stated terms, so highly tractable: collections, disbursements, the cash budget, the boundary month. No PA misses here; the risk is the swing, not the model."),
 ("5", "Controls and Regulations", "10%. Exemplary, then Approaching. Definitional, no math: who does what, which law, and the absolute word. One PA miss sits here. Fast to lock with the reflex: body, law, absolute word.")]
PLAN = [
 ("Take the pre-assessment early, out loud", "Run the think-aloud protocol: number, concept, answer, confidence for every item. Uncoached. Fail fast — the point is the result, not the score."),
 ("Pull the report and sort it", "Reshuffle the options, mark every miss, classify each by error type, and drop every item into the four-way triage. Sure-and-wrong goes to the top."),
 ("Read the anchor rows", "Part One, section 7: one row per concept — rule · trap · the tell. Read what you selected and work out why. Explanations are not the deliverable; your reasoning is."),
 ("Run the drill on paper", "Part Two, all 81 items, in one sitting if you can. Fill the strategy strip before reading the options. Mark confidence on every item."),
 ("Grade in Part B; triage in Part C", "Name the mold on every miss. Fill the triage grid and the mold tally. The largest tally is the pattern to drill."),
 ("Re-arm the dangerous ones", "Every sure-and-wrong: say the rule aloud, then redo its transfer item the next day. Every unsure-and-right: redo from the rule, not the memory."),
 ("Aim the rest by OA leverage", "Part Three, section 4: spend remaining time in leverage order, not weight order. Update the order the moment your drill results contradict it."),
 ("Last pass", "Part Three, section 5: the rule rows, top to bottom — read each row, name the trap, then stop. Set the calculator. Run the test-day protocol."),
 ("After the objective assessment", "Pull the new coaching report, add its column to the table in Part Three, section 1, and re-apply the gap lenses. Durable gaps first.")]
PART1_LEAD = "Fail fast: take the pre-assessment before you feel ready, let it show you exactly where you are weak, and build from the real result — never from topic weight alone. A result-based ranking is what moved the misses from 23 to 14 on the way to this drill; a weight-based focus guide was archived. Everything in this part is the method in the order you run it."
PART3_LEAD = "From the post-assessment coaching report for the objective assessment. Two attempts, both <b>Approaching Competency</b>; each 69 questions in 69 minutes, site proctored. The report names five competency areas, each with its weight, a status, and the topics it marked <i>Suggested Study</i>. That is enough to aim every remaining hour."
ARMOR_APPLIED = f"Applied here: 69 concepts → 69 armored items; the {len(MISSES)} misses each get a second, transfer item → 81. Every numeric key computed and confirmed to be an option. Two cost-volume-profit items carry a rendered graph with three line styles; the lines cross at 200 units / $5,000."
DRILL_LEAD = "Every pre-assessment concept, re-asked with more camouflage. 81 items: 69 concepts, plus a second transfer item for each of the 12 misses. No stem is reused."
MOLD_TALLY = "<b>Mold tally.</b> Count how many of your misses carry each label in Part B: dropped element ____ · wrong stem number ____ · adjacent category ____ · inverted operation ____ · absolute language ____ · confusion set ____ · camouflage ____ . The largest number is the pattern to drill."
SIGN = f"© {today[:4]} {AUTHOR}. From Joshua's mind — that is the signature."
def oa_rows(html=True):
    rows = [["Area", "Weight", OA_ATTEMPTS[0], OA_ATTEMPTS[1], "Topics marked Suggested Study"]]
    for area, w, stt, topics, _ in OA_REPORT:
        tl = []
        for tp, flags in topics:
            which = [a.split(",")[0] for a in OA_ATTEMPTS if flags[a]]
            lab = "both attempts" if len(which) == 2 else (which[0] if which else "neither")
            tl.append(f"{e(tp)} — <b>{lab}</b>" if html else f"{tp} — {lab}")
        rows.append([f"<b>{area}</b>" if html else area, f"{w}%", stt[OA_ATTEMPTS[0]], stt[OA_ATTEMPTS[1]], ("<br/>" if html else "; ").join(tl)])
    return rows
def map_rows(html=True):
    rows = [["OA area (weight)", "Drill competencies", "PA misses", "Drill items"]]
    for area, w, _, _, cs in OA_REPORT:
        its = area_items(cs)
        rows.append([(f"<b>{area}</b>" if html else area) + f" ({w}%)", ("<br/>" if html else "; ").join(e(COMP[c - 1][2]) if html else COMP[c - 1][2] for c in cs),
                     ", ".join(f"Q{q}" for q in area_misses(cs)) or "none", f"{its[0]}–{its[-1]} ({len(its)} items)"])
    return rows
GLOSS = sorted({(it["concept"], it["rule"]) for it in ITEMS if not it.get("transfer")}, key=lambda x: x[0].lower())
INDEX = sorted(((PRIMARY[q]["concept"], q, ITEMNO[q]) for q in PRIMARY), key=lambda x: x[0].lower())
KEYCELLS = [(n, "/".join(it["keys"]) + (" T" if it.get("transfer") else (" ▌" if it.get("miss") else ""))) for n, it in enumerate(prepared, 1)]
def strike_ex(topic, ex):
    h = e(ex)
    for s in STRUCK.get(topic, []): h = h.replace(e(s), f"<strike>{e(s)}</strike>", 1)
    return h

# PDF
def S(**k):
    d = dict(fontName="DV", fontSize=9.4, leading=12.2); d.update(k); return ParagraphStyle("x", **d)
st = S(); stB = S(fontName="DV-B"); small = S(fontSize=8.3, leading=10.6); tiny = S(fontSize=7.6, leading=9.6)
H0 = ParagraphStyle("H0", fontName="DV-B", fontSize=20, leading=25, spaceAfter=8)
H1 = ParagraphStyle("H1", fontName="DV-B", fontSize=13, leading=16, spaceBefore=10, spaceAfter=6)
H2 = ParagraphStyle("H2", fontName="DV-B", fontSize=11, leading=14, spaceBefore=8, spaceAfter=4)
stop = S(fontName="DV-B", fontSize=28, leading=34, alignment=TA_CENTER)

def foot(c, d):
    if d.page == 1: return
    c.setFont("DV", 7.5); c.drawRightString(letter[0] - 0.6 * inch, 0.4 * inch, f"{SERIES} · {SHORT} · V1 · {d.page}")
class Doc(BaseDocTemplate):
    def __init__(s, fn, **k):
        super().__init__(fn, **k)
        s.addPageTemplates([PageTemplate(id="p", frames=[Frame(s.leftMargin, s.bottomMargin, s.width, s.height, id="f")], onPage=foot)])
    def afterFlowable(s, f):
        if isinstance(f, Paragraph) and f.style.name in ("H0", "H1"):
            lvl = 0 if f.style.name == "H0" else 1
            txt = f.getPlainText(); key = "h" + re.sub(r"[^A-Za-z0-9]", "", txt)
            s.canv.bookmarkPage(key); s.canv.addOutlineEntry(txt, key, level=lvl, closed=lvl > 0)
            s.notify("TOCEntry", (lvl, txt, s.page, key))

class Rule(Flowable):
    def __init__(s, w=6.9 * inch): super().__init__(); s.w = w; s.height = 4
    def draw(s): c = s.canv; c.setLineWidth(0.6); c.setDash(2, 2); c.line(0, 2, s.w, 2)
def box(fl, miss=False):
    t = Table([[fl]], colWidths=[6.95 * inch])
    sty = [("BOX", (0, 0), (-1, -1), 0.8, colors.black), ("LEFTPADDING", (0, 0), (-1, -1), 7), ("RIGHTPADDING", (0, 0), (-1, -1), 7),
           ("TOPPADDING", (0, 0), (-1, -1), 5), ("BOTTOMPADDING", (0, 0), (-1, -1), 5)]
    if miss: sty.append(("LINEBEFORE", (0, 0), (0, -1), 6, colors.black))
    t.setStyle(TableStyle(sty)); return t
def grid(rows, widths, head=True, font=None, bars=()):
    font = font or small
    data = [[c if isinstance(c, Flowable) else Paragraph(c, font) for c in r] for r in rows]
    t = Table(data, colWidths=[w * inch for w in widths], repeatRows=1 if head else 0)
    sty = [("GRID", (0, 0), (-1, -1), 0.3, colors.grey), ("VALIGN", (0, 0), (-1, -1), "TOP"),
           ("TOPPADDING", (0, 0), (-1, -1), 2), ("BOTTOMPADDING", (0, 0), (-1, -1), 2)]
    if head: sty.append(("BACKGROUND", (0, 0), (-1, 0), colors.whitesmoke))
    sty += [("LINEBEFORE", (0, i), (0, i), 5, colors.black) for i in bars]
    t.setStyle(TableStyle(sty)); return t
bl = lambda w: "_" * w
def P(t, s=None): return Paragraph(t, s or st)
def paras(lst): return [x for p in lst for x in (P(p), Spacer(1, 5))]

def item_q(n, it):
    tag = " &nbsp;<b>[TRANSFER]</b>" if it.get("transfer") else (" &nbsp;<b>[RE-ARMED — missed on attempt 3]</b>" if it.get("miss") else "")
    ch = " <i>(choose 2)</i>" if it.get("choose") else ""
    fl = [P(f"<b>{n}.</b> <b>{e(it['concept'])}</b> <font size=7.5 color='#444444'>pre-assessment Q{it['q']}</font>{tag}"),
          Spacer(1, 2), P(e(it["stem"]) + ch), Spacer(1, 3)]
    if it.get("graph"): fl += [Image(io.BytesIO(GRAPH), width=4.4 * inch, height=2.75 * inch), Spacer(1, 3)]
    for i, (t, _) in enumerate(it["opts"]): fl.append(P(f"&nbsp;&nbsp;<b>{L[i]}.</b> {e(t)}"))
    fl += [Spacer(1, 4), Rule(), Spacer(1, 2),
           P(f"Target word: {bl(22)} &nbsp; The one fact that decides: {bl(40)}", small),
           P(f"Answer: {bl(8)} &nbsp;&nbsp; [&nbsp;&nbsp;&nbsp;] sure &nbsp;&nbsp; [&nbsp;&nbsp;&nbsp;] unsure &nbsp;&nbsp; [&nbsp;&nbsp;&nbsp;] guess", small)]
    return [box(fl, miss=it.get("miss")), Spacer(1, 6)]
def item_k(n, it):
    fl = [P(f"<b>{n}.</b> <b>{e(it['concept'])}</b> — <b>{' and '.join(it['keys'])}</b>"), Spacer(1, 2),
          P(f"<b>Rule.</b> {e(it['rule'])}"), P(f"<b>Target word.</b> {e(it['target'])} &nbsp;&nbsp; <b>Decides.</b> {e(it['deciding'])}")]
    camo = " · ".join(f"<strike>{e(c)}</strike>" for c in it.get("camo", [])) or "—"
    fl.append(P(f"<b>Camouflage, struck.</b> {camo}"))
    rows = [[P(f"<b>{L[i]}</b>" if m == "KEY" else L[i], small), P("<b>KEY</b>" if m == "KEY" else MOLD[m], small), P(e(t), small)]
            for i, (t, m) in enumerate(it["opts"])]
    tb = Table(rows, colWidths=[0.25 * inch, 1.2 * inch, 5.15 * inch])
    tb.setStyle(TableStyle([("GRID", (0, 0), (-1, -1), 0.3, colors.grey), ("VALIGN", (0, 0), (-1, -1), "TOP"),
                            ("TOPPADDING", (0, 0), (-1, -1), 1.5), ("BOTTOMPADDING", (0, 0), (-1, -1), 1.5)]))
    fl += [Spacer(1, 3), tb]
    if it.get("why"): fl += [Spacer(1, 2), P(e(it["why"]), small)]
    return [box(fl, miss=it.get("miss")), Spacer(1, 6)]
def triage_grid(tall=False):
    rows = [[P(f"<b>{c}</b>" if (r == 0 or j == 0) else c, small) for j, c in enumerate(row)] for r, row in enumerate(TRIAGE)]
    if tall: rows[1][2] = P("<b>Concept inversion. Top priority.</b> Say the rule aloud; redo the transfer item tomorrow.", small)
    tt = Table(rows, colWidths=[0.9 * inch, 3 * inch, 3 * inch], rowHeights=[0.3 * inch, 1.3 * inch, 1.3 * inch, 1.3 * inch] if tall else None)
    tt.setStyle(TableStyle([("GRID", (0, 0), (-1, -1), 0.8, colors.black), ("VALIGN", (0, 0), (-1, -1), "TOP")])); return tt

def build_pdf(path):
    s = []
    s += [Spacer(1, 1.2 * inch), P(e(SERIES), S(fontName="DV-B", fontSize=13, leading=16)), Spacer(1, 4),
          P("Armored Accounting for Decision Making", S(fontName="DV-B", fontSize=24, leading=29)), Spacer(1, 4),
          P("The Fail Fast Compendium", S(fontName="DV-B", fontSize=16, leading=20)), Spacer(1, 8),
          P(e(TAG), S(fontSize=12, leading=15)), Spacer(1, 10), P(e(SUB), S(fontSize=11, leading=14)), Spacer(1, 14),
          P(f"by {AUTHOR}", S(fontSize=11)), Spacer(1, 14), P(f"81 items · 69 concepts · 12 transfer items · V1 · {today}"), PageBreak()]
    toc = TableOfContents()
    toc.levelStyles = [ParagraphStyle("t0", fontName="DV-B", fontSize=10.5, leading=15, spaceBefore=5),
                       ParagraphStyle("t1", fontName="DV", fontSize=9.4, leading=12.5, leftIndent=16)]
    s += [P("Contents", S(fontName="DV-B", fontSize=18, leading=22)), Spacer(1, 8), toc, PageBreak()]
    s += [P("Introduction", H0)] + paras(INTRO)
    s += [P("How the book runs", H2), grid([["", "What it is", "Where"],
          ["Part One", "The Fail Fast PA method: run the pre-assessment, read the report, triage, anchor rows, armoring.", "before the drill"],
          ["Part Two", "The drill — 81 armored items, STOP page, key and dissection, triage and mold tally.", "the centrepiece"],
          ["Part Three", "The Fail Fast OA strategies from the post-assessment coaching report: weights, statuses, gap lenses, leverage order, rules, test day.", "after the drill"],
          ["Compendium", "Study plan · glossary · concept index · answer key at a glance · mold reference.", "all the way through"]], [1.0, 4.6, 1.3]), PageBreak()]
    # Part One
    s += [P("Part One — The Fail Fast PA Method", H0), P(PART1_LEAD), P("1 · Why fail fast — six beliefs", H1),
          grid([["Belief", "What it means"]] + [[f"<b>{a}</b>", b] for a, b in BELIEFS], [1.9, 5.0]),
          P("2 · Run the pre-assessment out loud", H1),
          P("Screen-record and narrate the pre-assessment. Two passes: talk live now, keep the results report after. For every question, say these four things:"), Spacer(1, 4),
          grid([["Say", "How"]] + [[f"<b>{a}</b>", b] for a, b in THINK], [1.2, 5.7]), Spacer(1, 5),
          P(f"<b>Example.</b> {THINK_EX}"), Spacer(1, 4), P("<b>After the test.</b>")]
    s += [P(f"{i}. {t}") for i, t in enumerate(THINK_AFTER, 1)]
    s += [P("3 · Read the report", H1)] + paras(READ_REPORT)
    s += [P("4 · The four-way triage", H1), P("Merge your reasoning, your confidence and right/wrong, and every item sorts itself:"), Spacer(1, 4), triage_grid(), Spacer(1, 4),
          P("A guess is <i>not learned</i> regardless of outcome. Sure-and-wrong is invisible until the item is scored — which is why the confidence mark is data, equal to the answer.")]
    s += [P("5 · The six through-lines", H1), P("Most misses are one of these."),
          grid([["", "Through-line", "How it shows up"]] + [[str(i), f"<b>{a}</b>", b] for i, (a, b) in enumerate(THROUGH, 1)], [0.3, 2.2, 4.4])]
    s += [P("6 · The seven molds", H1), P("Every distractor in the drill carries one of these labels. Naming the trap defeats it."),
          grid([["Mold", "The error it encodes", "Distractors in the drill"]] + [[f"<b>{a}</b>", b, str(MOLDCOUNT[MOLD_KEY[a]])] for a, b in MOLD_DEF], [1.5, 4.2, 1.2])]
    s += [PageBreak(), P("7 · Anchor rows — the 69 concepts of the pre-assessment", H1),
          P(f"One row per concept the pre-assessment tested, on attempt 3 (passed): concept · rule · trap · the tell. A heavy bar and <b>MISSED</b> mark the {len(MISSES)} items not fully correct — Q{', Q'.join(map(str, MISSES))}. The last column points to the drill items that re-ask the concept. Read what you selected and work out why."), Spacer(1, 5)]
    rows = [["Q", "Concept", "Rule", "Trap", "The tell", "Drill"]]; bars = []
    for i, r in enumerate(PAROWS, 1):
        rows.append([str(r["q"]) + ("<br/><b>MISSED</b>" if r["miss"] else ""), f"<b>{e(r['concept'])}</b>", e(r["rule"]), e(r["trap"]), e(r["tell"]), ", ".join(map(str, ITEMNO[r["q"]]))])
        if r["miss"]: bars.append(i)
    s += [grid(rows, [0.72, 1.2, 1.7, 1.45, 1.33, 0.5], font=tiny, bars=bars)]
    s += [P("8 · From result to drill — armoring", H1), P("The move: re-ask every concept with <i>more</i> camouflage than the original, never less, and label the disguise in the key."), Spacer(1, 4),
          grid([["Piece", "Why"]] + [[f"<b>{a}</b>", b] for a, b in ARMOR], [2.0, 4.9]), Spacer(1, 5), P(ARMOR_APPLIED), PageBreak()]
    # Part Two
    s += [P("Part Two — The Drill", H0), P(DRILL_LEAD), Spacer(1, 6), P("How to run it", H1)]
    t = Table([[P(a, stB), P(b)] for a, b in HOWTO], colWidths=[0.3 * inch, 6.6 * inch])
    t.setStyle(TableStyle([("BOX", (0, 0), (-1, -1), 0.8, colors.black), ("VALIGN", (0, 0), (-1, -1), "TOP"), ("TOPPADDING", (0, 0), (-1, -1), 2), ("BOTTOMPADDING", (0, 0), (-1, -1), 2)]))
    s += [t, Spacer(1, 8), P("Part A — Items", H1)]
    last = None
    for n, it in enumerate(prepared, 1):
        c = comp(it["q"])
        if c != last: s.append(P(e(c), H2)); last = c
        s += item_q(n, it)
    s += [PageBreak(), Spacer(1, 3 * inch), P("STOP", stop), Spacer(1, 8), P("Answers ahead. Finish Part A and mark every confidence box, then turn.", S(alignment=TA_CENTER, fontSize=11)), PageBreak(),
          P("Part B — Key and dissection", H1)]
    last = None
    for n, it in enumerate(prepared, 1):
        c = comp(it["q"])
        if c != last: s.append(P(e(c), H2)); last = c
        s += item_k(n, it)
    s += [PageBreak(), P("Part C — Triage", H1), P("Sort every item by the two marks you made. Write item numbers in the cells."), Spacer(1, 6), triage_grid(tall=True), Spacer(1, 10), P(MOLD_TALLY), PageBreak()]
    # Part Three
    s += [P("Part Three — The Fail Fast OA Strategies", H0), P(PART3_LEAD), P("1 · What the report says", H1),
          grid(oa_rows(), [1.3, 0.68, 1.0, 1.0, 2.92]), Spacer(1, 4),
          P("Overall, both attempts: Approaching Competency. Topics not marked Suggested Study on an attempt showed only <i>Review</i>.", small),
          P("2 · Read it with the gap lenses", H1), P("With results across attempts, every area falls under one of the lenses:"), Spacer(1, 3),
          grid([[f"<b>{c}</b>" if j == 0 and i else c for j, c in enumerate(r)] for i, r in enumerate(LENSES)], [1.7, 2.8, 2.4]),
          P("3 · Where the PA misses land on the OA map", H1), P("Each drill competency sits under one area of the report. The misses from the pre-assessment, and the drill items that re-arm them:"), Spacer(1, 3),
          grid(map_rows(), [1.6, 2.9, 1.2, 1.2]),
          P("4 · The leverage order", H1),
          P("Leverage = weight × gap × how fast the points come. Foundational topics get extra weight because fixing them pays across areas. The reasoning is shown so it can be challenged — and the order changes the moment your drill results contradict it."), Spacer(1, 3),
          grid([["", "Area", "Why here"]] + [[a, f"<b>{b}</b>", c] for a, b, c in LEVERAGE], [0.3, 1.5, 5.1]),
          P("5 · The rules by area", H1),
          P("Principles first. Read each row, name the trap, then stop. Status: <b>owned</b> — bank it · <b>lock it</b> — run the rule deliberately · <b>survived rewording</b> — say the rule aloud first. In the examples, the camouflage is struck.")]
    for sec, rows_ in REFRESHER:
        s += [P(e(sec), H2), grid([["Topic", "Rule", "Trap", "Example → answer"]] +
              [[f"<b>{e(tp)}</b><br/><i>{TAGS[tg].split(' — ')[0]}</i>", e(ru), e(tr), strike_ex(tp, ex)] for tg, tp, ru, tr, ex in rows_], [1.35, 2.2, 1.6, 1.75])]
    s += [P("6 · The six through-lines, on the day", H1)] + [P(f"{i}. <b>{a}</b> {b}") for i, (a, b) in enumerate(THROUGH, 1)]
    s += [P("7 · Test-day protocol", H1)] + [P(f"{i}. {t}") for i, t in enumerate(TESTDAY, 1)]
    s += [P("8 · The calculator, set once at the start", H1)] + [P(f"• {e(t)}") for t in CALC] + [PageBreak()]
    # Compendium
    s += [P("Compendium", H0), P("1 · Study plan — PA → drill → OA", H1),
          grid([["", "Stage", "What to do"]] + [[str(i), f"<b>{a}</b>", b] for i, (a, b) in enumerate(PLAN, 1)], [0.3, 1.9, 4.7]),
          P("2 · Glossary — every concept and its rule", H1), P("Alphabetical. The rule is the one the drill's key uses."),
          grid([["Term", "Rule"]] + [[f"<b>{e(a)}</b>", e(b)] for a, b in GLOSS], [2.0, 4.9]),
          P("3 · Concept index", H1), P("Concept → pre-assessment question → drill item numbers (transfer items included).")]
    half = (len(INDEX) + 1) // 2
    def idxt(sub): return grid([["Concept", "PA", "Items"]] + [[e(c), f"Q{q}", ", ".join(map(str, ns))] for c, q, ns in sub], [2.0, 0.45, 0.55], font=tiny)
    t = Table([[idxt(INDEX[:half]), idxt(INDEX[half:])]], colWidths=[3.45 * inch, 3.45 * inch]); t.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "TOP")]))
    s += [t, P("4 · Answer key at a glance", H1), P("For a fast re-grade. The full dissection is in Part Two, Part B. ▌ = a concept missed on attempt 3; T = transfer item.")]
    cells = [f"<b>{n}</b> {k}" for n, k in KEYCELLS]; cols = 9
    s += [grid([cells[i:i + cols] + [""] * (cols - len(cells[i:i + cols])) for i in range(0, len(cells), cols)], [6.9 / cols] * cols, head=False),
          Spacer(1, 4), P(f"Key distribution: A {DIST['A']} · B {DIST['B']} · C {DIST['C']} · D {DIST['D']} (17 items are choose-2).", small),
          P("5 · Mold reference", H1),
          grid([["Mold", "The error it encodes", "In the drill"]] + [[f"<b>{a}</b>", b, str(MOLDCOUNT[MOLD_KEY[a]])] for a, b in MOLD_DEF], [1.5, 4.4, 1.0]),
          Spacer(1, 16), P(SIGN, small)]
    Doc(path, pagesize=letter, leftMargin=0.6 * inch, rightMargin=0.6 * inch, topMargin=0.6 * inch, bottomMargin=0.6 * inch,
        title=TITLE, author=AUTHOR, subject="Accounting for Decision Making").multiBuild(s)

# DOCX (KDP manuscript)
def strip(t): return re.sub(r"<[^>]+>", "", t.replace("<br/>", "; ")).replace("&nbsp;", " ").replace("&amp;", "&")
def build_docx(path):
    d = Document(); d.styles["Normal"].font.name = "Calibri"; d.styles["Normal"].font.size = Pt(10.5)
    def table(rows, head=True):
        t = d.add_table(rows=len(rows), cols=len(rows[0])); t.style = "Table Grid"
        for r, row in enumerate(rows):
            for c, cell in enumerate(row):
                t.cell(r, c).text = strip(str(cell))
                if head and r == 0:
                    for p in t.cell(r, c).paragraphs:
                        for run in p.runs: run.bold = True
        d.add_paragraph()
    H = lambda t, l: d.add_heading(t, l)
    def para(t): d.add_paragraph(strip(t))
    d.add_paragraph(SERIES); H("Armored Accounting for Decision Making", 0); H("The Fail Fast Compendium", 1)
    for t in [TAG, SUB, f"by {AUTHOR}", f"81 items · 69 concepts · 12 transfer items · V1 · {today}"]: d.add_paragraph(t)
    d.add_page_break(); H("Contents", 1)
    for t in ["Introduction", "Part One — The Fail Fast PA Method", "Part Two — The Drill", "Part Three — The Fail Fast OA Strategies", "Compendium"]:
        d.add_paragraph(t, style="List Bullet")
    d.add_page_break(); H("Introduction", 1)
    for p in INTRO: para(p)
    d.add_page_break(); H("Part One — The Fail Fast PA Method", 1); para(PART1_LEAD)
    H("1 · Why fail fast — six beliefs", 2); table([["Belief", "What it means"]] + [list(x) for x in BELIEFS])
    H("2 · Run the pre-assessment out loud", 2)
    para("Screen-record and narrate the pre-assessment. Two passes: talk live now, keep the results report after. For every question, say these four things:")
    table([["Say", "How"]] + [list(x) for x in THINK]); para("Example. " + THINK_EX); para("After the test.")
    for t in THINK_AFTER: d.add_paragraph(t, style="List Number")
    H("3 · Read the report", 2)
    for p in READ_REPORT: para(p)
    H("4 · The four-way triage", 2); table([list(r) for r in TRIAGE])
    para("A guess is not learned regardless of outcome. Sure-and-wrong is invisible until the item is scored — which is why the confidence mark is data, equal to the answer.")
    H("5 · The six through-lines", 2); table([["", "Through-line", "How it shows up"]] + [[str(i), a, b] for i, (a, b) in enumerate(THROUGH, 1)])
    H("6 · The seven molds", 2); table([["Mold", "The error it encodes", "Distractors in the drill"]] + [[a, b, str(MOLDCOUNT[MOLD_KEY[a]])] for a, b in MOLD_DEF])
    H("7 · Anchor rows — the 69 concepts of the pre-assessment", 2)
    para(f"One row per concept the pre-assessment tested, on attempt 3 (passed): concept · rule · trap · the tell. MISSED marks the {len(MISSES)} items not fully correct — Q{', Q'.join(map(str, MISSES))}. The last column points to the drill items that re-ask the concept. Read what you selected and work out why.")
    table([["Q", "Concept", "Rule", "Trap", "The tell", "Drill"]] + [[str(r["q"]) + (" MISSED" if r["miss"] else ""), r["concept"], r["rule"], r["trap"], r["tell"], ", ".join(map(str, ITEMNO[r["q"]]))] for r in PAROWS])
    H("8 · From result to drill — armoring", 2)
    para("The move: re-ask every concept with more camouflage than the original, never less, and label the disguise in the key.")
    table([["Piece", "Why"]] + [list(x) for x in ARMOR]); para(ARMOR_APPLIED)
    # Part Two
    d.add_page_break(); H("Part Two — The Drill", 1); para(DRILL_LEAD); H("How to run it", 2)
    for a, b in HOWTO: para(("" if a == "▌" else f"{a}. ") + b)
    H("Part A — Items", 2); last = None
    for n, it in enumerate(prepared, 1):
        c = comp(it["q"])
        if c != last: H(c, 3); last = c
        tag = " [TRANSFER]" if it.get("transfer") else (" [RE-ARMED — missed on attempt 3]" if it.get("miss") else "")
        p = d.add_paragraph(); p.add_run(f"{n}. {it['concept']}").bold = True; p.add_run(f"   pre-assessment Q{it['q']}{tag}")
        d.add_paragraph(it["stem"] + (" (choose 2)" if it.get("choose") else ""))
        if it.get("graph"): d.add_picture(io.BytesIO(GRAPH), width=Inches(4.4))
        for i, (t, _) in enumerate(it["opts"]): d.add_paragraph(f"{L[i]}. {t}")
        d.add_paragraph("Target word: ____________   The one fact that decides: ______________________________")
        d.add_paragraph("Answer: ____   [ ] sure  [ ] unsure  [ ] guess")
    d.add_page_break(); H("STOP — answers ahead", 2); para("Finish Part A and mark every confidence box, then turn.")
    d.add_page_break(); H("Part B — Key and dissection", 2); last = None
    for n, it in enumerate(prepared, 1):
        c = comp(it["q"])
        if c != last: H(c, 3); last = c
        d.add_paragraph().add_run(f"{n}. {it['concept']} — {' and '.join(it['keys'])}").bold = True
        d.add_paragraph(f"Rule. {it['rule']}"); d.add_paragraph(f"Target word. {it['target']}   Decides. {it['deciding']}")
        p = d.add_paragraph("Camouflage, struck: ")
        for j, cm in enumerate(it.get("camo", [])):
            if j: p.add_run(" · ")
            p.add_run(cm).font.strike = True
        if not it.get("camo"): p.add_run("—")
        for i, (t, m) in enumerate(it["opts"]): d.add_paragraph(f"{L[i]}  {'KEY' if m == 'KEY' else MOLD[m]}  —  {t}")
        if it.get("why"): d.add_paragraph(it["why"])
    d.add_page_break(); H("Part C — Triage", 2); para("Sort every item by the two marks you made. Write item numbers in the cells.")
    table([list(r) for r in TRIAGE]); para(MOLD_TALLY)
    # Part Three
    d.add_page_break(); H("Part Three — The Fail Fast OA Strategies", 1); para(PART3_LEAD)
    H("1 · What the report says", 2); table(oa_rows(html=False))
    para("Overall, both attempts: Approaching Competency. Topics not marked Suggested Study on an attempt showed only Review.")
    H("2 · Read it with the gap lenses", 2); table(LENSES)
    H("3 · Where the PA misses land on the OA map", 2); table(map_rows(html=False))
    H("4 · The leverage order", 2)
    para("Leverage = weight × gap × how fast the points come. Foundational topics get extra weight because fixing them pays across areas. The reasoning is shown so it can be challenged — and the order changes the moment your drill results contradict it.")
    table([["", "Area", "Why here"]] + [list(x) for x in LEVERAGE])
    H("5 · The rules by area", 2)
    para("Principles first. Read each row, name the trap, then stop. Status: owned — bank it · lock it — run the rule deliberately · survived rewording — say the rule aloud first.")
    for sec, rows_ in REFRESHER:
        H(sec, 3); table([["Topic", "Rule", "Trap", "Example → answer"]] + [[f"{tp} ({TAGS[tg].split(' — ')[0]})", ru, tr, ex] for tg, tp, ru, tr, ex in rows_])
    H("6 · The six through-lines, on the day", 2)
    for a, b in THROUGH: d.add_paragraph(f"{a} {b}", style="List Number")
    H("7 · Test-day protocol", 2)
    for t in TESTDAY: d.add_paragraph(t, style="List Number")
    H("8 · The calculator, set once at the start", 2)
    for t in CALC: d.add_paragraph(t, style="List Bullet")
    # Compendium
    d.add_page_break(); H("Compendium", 1)
    H("1 · Study plan — PA → drill → OA", 2); table([["", "Stage", "What to do"]] + [[str(i), a, b] for i, (a, b) in enumerate(PLAN, 1)])
    H("2 · Glossary — every concept and its rule", 2); table([["Term", "Rule"]] + [list(x) for x in GLOSS])
    H("3 · Concept index", 2); table([["Concept", "PA", "Drill items"]] + [[c, f"Q{q}", ", ".join(map(str, ns))] for c, q, ns in INDEX])
    H("4 · Answer key at a glance", 2)
    cells = [f"{n} {k}" for n, k in KEYCELLS]; cols = 9
    table([cells[i:i + cols] + [""] * (cols - len(cells[i:i + cols])) for i in range(0, len(cells), cols)], head=False)
    para(f"Key distribution: A {DIST['A']} · B {DIST['B']} · C {DIST['C']} · D {DIST['D']} (17 items are choose-2). ▌ = a concept missed on attempt 3; T = transfer item.")
    H("5 · Mold reference", 2); table([["Mold", "The error it encodes", "In the drill"]] + [[a, b, str(MOLDCOUNT[MOLD_KEY[a]])] for a, b in MOLD_DEF])
    para(SIGN)
    d.core_properties.title = TITLE; d.core_properties.author = AUTHOR
    d.save(path)

# Cover: same pattern as the series covers (1600x2560, flat palette, inset rule, title (no series line since 2026-09-25), tagline, by-line, V1).
# Palette follows the listing sheet's red / blue / yellow rotation: the seventh title comes round to red.
def build_cover(path, bg="#8C4A4A", ink="#F3E3E0"):
    W, H = 1600, 2560; im = PILImage.new("RGB", (W, H), bg); dr = ImageDraw.Draw(im)
    dr.rectangle([120, 120, W - 120, H - 120], outline=ink, width=5)
    fb = lambda z: ImageFont.truetype(FD + "DejaVuSans-Bold.ttf", z); fr = lambda z: ImageFont.truetype(FD + "DejaVuSans.ttf", z)
    y = 500
    for line in ["Armored", "Accounting for", "Decision Making"]: dr.text((160, y), line, font=fb(118), fill=ink); y += 142
    y += 40; dr.text((160, y), "The Fail Fast Compendium", font=fb(76), fill=ink); y += 130
    for line in ["For people who already know the", "easy version."]: dr.text((160, y), line, font=fr(62), fill=ink); y += 82
    dr.text((160, H - 390), "by Joshua", font=fr(76), fill=ink); dr.text((160, H - 280), "V1", font=fr(56), fill=ink)
    im.save(path, "JPEG", quality=92)

if __name__ == "__main__":
    pdf = os.path.join(OUT, SLUG + ".pdf"); docx = os.path.join(OUT, SLUG + ".docx"); cover = os.path.join(OUT, SLUG + "_cover.jpg")
    build_pdf(pdf); build_docx(docx); build_cover(cover)
    # same forbidden-term scan the series book builder runs
    import zipfile
    from pypdf import PdfReader
    txt = (zipfile.ZipFile(docx).read("word/document.xml").decode("utf-8") + " ".join(p.extract_text() for p in PdfReader(pdf).pages)).lower()
    hits = [w for w in ["w" + "gu", "western " + "governors", "lind" + "quist", "c" + "213"] if w in txt]
    if re.search(r"[a-z0-9._%+-]+@[a-z0-9-]+\.[a-z]{2,}", txt): hits.append("email")
    print(f"{TITLE}: {len(prepared)} items · keys {DIST} · misses {MISSES} · scan {hits or 'clean'}")
    print(pdf); print(docx); print(cover)
