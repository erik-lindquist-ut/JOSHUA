# Accounting for Decision Making — armored items, part B (Q36–Q69)
from items_a import ITEMS, add

# ── 5 · Controls, fraud, SOX ───────────────────────────────────────────────────
add(q=36, concept="Errors vs fraud", miss=False, choose=2,
 stem="Four findings from a year-end review. Which two are errors rather than fraud? Choose 2.",
 opts=[("A clerk posted a customer deposit as revenue, not realising the service was scheduled for next quarter","KEY"),("A purchasing manager approved inflated invoices from a vendor who paid him a kickback","ADJ"),("Payroll tax was computed on the prior year's rate table, understating the liability","KEY"),("The CFO instructed staff to hold December returns until January to protect the bonus pool","ADJ")],
 target="not realising · prior year's table", deciding="Intent is the dividing line.",
 rule="An error is unintentional; fraud is deliberate.", camo=["dollar size — irrelevant to the classification"])
add(q=37, concept="Internal control — receiving", miss=False,
 stem="A company pays for goods only after accounts payable matches the vendor invoice to the purchase order and to a receiving report signed by the warehouse. Which risk is this three-way match designed to prevent?",
 opts=[("Paying for goods that were ordered but never received","KEY"),("Ordering more inventory than the budget allows","ADJ"),("Recording sales before delivery","CONF"),("Overstating ending inventory at year-end","ADJ")],
 target="pay · receiving report", deciding="The receiving report proves the goods arrived.",
 rule="Three-way match prevents paying for goods not received.", camo=[])
add(q=38, concept="Earnings manipulation", miss=True, choose=2,
 stem="A CEO's bonus vests if annual earnings exceed $50 million; the company is also negotiating a credit line whose covenant requires positive net income; its auditor has requested more detail on reserves; and SOX 404 testing is due. Which two are common motives to manipulate reported earnings? Choose 2.",
 opts=[("Qualifying for the credit line","KEY"),("Satisfying the auditor's request for detail","INV"),("Hitting the bonus threshold","KEY"),("Passing SOX 404 testing","INV")],
 target="motive · pressure to overstate", deciding="A motive is a pressure to make earnings look better. Auditors and SOX are pressures the other way.",
 rule="Manipulation motives: bonus targets, loan covenants, internal goals, analyst forecasts.", camo=["auditor request","SOX testing"],
 why="Auditor detail and SOX compliance are reasons not to manipulate; picking them is a concept inversion.")
add(q=38, concept="Earnings manipulation — transfer", miss=True, transfer=True,
 stem="Which of the following is NOT a typical reason managers manipulate earnings?",
 opts=[("Meeting analysts' consensus forecast","ADJ"),("Complying with Sarbanes-Oxley internal-control requirements","KEY"),("Staying within a debt covenant","ADJ"),("Earning a bonus tied to net income","ADJ")],
 target="NOT", deciding="Reverse the question: the one that is a constraint, not a pressure.",
 rule="SOX is a control against manipulation, not a motive for it.", camo=[])
add(q=39, concept="SOX — audit firms", miss=False, choose=2,
 stem="Under Sarbanes-Oxley, which two requirements apply to the firm auditing a public company? Choose 2.",
 opts=[("Rotate the lead audit partner periodically","KEY"),("Certify the accuracy of the client's financial statements personally","ADJ"),("Refrain from providing certain non-audit services to the audit client","KEY"),("Prepare the client's internal control report","ADJ")],
 target="AUDIT FIRM", deciding="What SOX restricts the auditor from doing, not what management must sign.",
 rule="SOX for auditors: partner rotation, banned consulting services, PCAOB registration.", camo=["certification — that's management"])
add(q=40, concept="SOX — management", miss=False, choose=2,
 stem="Under Sarbanes-Oxley, which two requirements fall on the management of a public company? Choose 2.",
 opts=[("The CEO and CFO certify the financial statements","KEY"),("Rotate the audit partner every five years","ADJ"),("Assess and report on internal control over financial reporting","KEY"),("Register with the PCAOB","ADJ")],
 target="MANAGEMENT", deciding="Certification and the internal-control report are management's.",
 rule="SOX for management: certify the statements (302), report on internal controls (404).", camo=["partner rotation","PCAOB registration — auditor duties"])
add(q=41, concept="Internal auditors", miss=False, choose=2,
 stem="Which two actions do internal auditors take to protect the integrity of financial reporting? Choose 2.",
 opts=[("Test whether internal controls are operating as designed","KEY"),("Issue the opinion on the annual financial statements","ADJ"),("Evaluate compliance with company policies and procedures","KEY"),("Set the accounting standards the company follows","CONF")],
 target="INTERNAL auditors", deciding="Inside the company: controls and compliance. The opinion is external.",
 rule="Internal audit tests controls and compliance; external audit issues the opinion; FASB sets standards.", camo=[])
add(q=42, concept="SEC", miss=False,
 stem="A public company files its 10-K late and with a material misstatement. Which body has the authority to require the filing, review it, and bring an enforcement action?",
 opts=[("The FASB","CONF"),("The SEC","KEY"),("The PCAOB","ADJ"),("The AICPA","CONF")],
 target="require the filing · enforcement", deciding="The SEC regulates the public markets and their disclosures.",
 rule="SEC = regulates public-company reporting and enforces securities law.", camo=[])

# ── 6 · Management accounting and cost classification ──────────────────────────
add(q=43, concept="Management accounting", miss=False, choose=2,
 stem="Which two describe what management accounting provides? Choose 2.",
 opts=[("Information for internal planning and control","KEY"),("Audited statements for external investors","ADJ"),("Both financial and non-financial measures, such as defect rates","KEY"),("Reports that must follow GAAP","ADJ")],
 target="management", deciding="Inside, forward-looking, not GAAP-bound.",
 rule="Management accounting serves internal decisions with financial and non-financial data.", camo=[])
add(q=44, concept="Management vs financial accounting", miss=True,
 stem="A plant controller prepares a monthly scrap-rate report by machine, a quarterly product-line profitability analysis using estimated future demand, and the 10-Q. Which statement correctly separates the first two from the third?",
 opts=[("The first two are unbiased; the 10-Q reflects management judgement","INV"),("The first two are for internal planning, control and evaluation; the 10-Q is for external users under GAAP","KEY"),("The first two are restricted to financial data; the 10-Q includes non-financial data","INV"),("The first two cannot be used to gain competitive advantage; the 10-Q can","INV")],
 target="who reads it", deciding="Audience decides the classification.",
 rule="Management accounting: internal, future-oriented, unaudited, includes non-financial. Financial accounting: external, historical, GAAP.", camo=["scrap-rate report — non-financial, and still management accounting"],
 why="Every distractor swaps a financial-accounting trait onto management accounting.")
add(q=44, concept="Management vs financial — transfer", miss=True, transfer=True,
 stem="Which statement describes FINANCIAL accounting?",
 opts=[("Emphasises future projections","INV"),("Reports historical results to external users under GAAP","KEY"),("Is tailored to individual managers' decisions","INV"),("Includes non-financial performance measures","INV")],
 target="FINANCIAL", deciding="External, historical, GAAP.",
 rule="Same table, other column.", camo=[])
add(q=45, concept="Manufacturing balance sheet", miss=False,
 stem="Which account appears on a manufacturer's balance sheet but not on a merchandiser's?",
 opts=[("Merchandise inventory","ADJ"),("Work-in-process inventory","KEY"),("Accounts receivable","CONF"),("Accumulated depreciation","CONF")],
 target="manufacturer but NOT merchandiser", deciding="Only a maker has goods partly made.",
 rule="Manufacturers carry raw materials, work in process and finished goods; merchandisers carry merchandise inventory.", camo=[])
add(q=46, concept="Differential cost", miss=False,
 stem="A firm deciding whether to keep or replace a delivery van considers: the van's original price $38,000 · its book value $9,000 · the new van's price $45,000 · fuel savings of $3,000 a year · the depot rent $24,000 a year either way. Which cost is differential?",
 opts=[("The $38,000 original price","ADJ"),("The $3,000 annual fuel savings","KEY"),("The $9,000 book value","ADJ"),("The $24,000 depot rent","ADJ")],
 target="changes with the decision", deciding="Only a future cost that differs between options is differential.",
 rule="Differential = future and different. Sunk and unchanged costs are ignored.", camo=["original price and book value — sunk","rent — same either way"])
add(q=47, concept="Period costs", miss=False, choose=2,
 stem="A candle maker incurs: paraffin wax · wages of the pourers · the showroom lease · factory electricity · a trade-show booth. Which two are period costs? Choose 2.",
 opts=[("Paraffin wax","ADJ"),("The showroom lease","KEY"),("Factory electricity","ADJ"),("The trade-show booth","KEY")],
 target="PERIOD", deciding="Does it touch the product or the factory? If not, period.",
 rule="Period costs = selling and administrative; product costs = materials, labour, factory overhead.", camo=["factory electricity — overhead, so product"])
add(q=48, concept="Period vs product cost", miss=True, choose=2,
 stem="A custom guitar workshop incurs: spruce and mahogany · the luthier's wages · the showroom rent · Instagram advertising · the shop foreman's salary · varnish. Which two are PRODUCT costs? Choose 2.",
 opts=[("The showroom rent","ADJ"),("The luthier's wages","KEY"),("Instagram advertising","ADJ"),("Spruce and mahogany","KEY")],
 target="PRODUCT — reversed from the original", deciding="Anything that touches the guitar.",
 rule="Direct material + direct labour + factory overhead = product. Selling and admin = period.", camo=["foreman and varnish are also product — overhead — but only two are asked"],
 why="The original asked for period costs; this asks for product. Read the target word.")
add(q=48, concept="Period vs product — transfer", miss=True, transfer=True, choose=2,
 stem="Same workshop. Which two are PERIOD costs? Choose 2: the shop foreman's salary · delivery of finished guitars to customers · factory utilities · the CFO's salary.",
 opts=[("The shop foreman's salary","ADJ"),("Delivery to customers","KEY"),("Factory utilities","ADJ"),("The CFO's salary","KEY")],
 target="PERIOD", deciding="Foreman and utilities are in the factory — overhead. Delivery and the CFO are not.",
 rule="Factory supervision and factory utilities are manufacturing overhead, therefore product.", camo=[])
add(q=49, concept="Ethical standards", miss=False,
 stem="A management accountant is asked to shift a period cost into overhead so a product looks profitable in a board deck. Which best describes the role of ethical standards here?",
 opts=[("They apply only to external reporting under GAAP","INV"),("They require competence, confidentiality, integrity and credibility in internal reporting as well","KEY"),("They are optional because the report is internal","ABS"),("They guarantee that no misstatement will occur","ABS")],
 target="internal · board deck", deciding="Ethics bind management accounting as fully as financial.",
 rule="Ethical standards govern internal reporting too: competence, confidentiality, integrity, credibility.", camo=[])
add(q=50, concept="Product cost total", miss=False,
 stem="First month of operations: direct materials $12,000 · indirect materials $3,500 · direct labour $28,000 · indirect labour $6,000 · factory rent $9,000 · factory depreciation $5,000 · sales commissions $7,000 · office rent $4,000 · advertising $2,500. Total product costs?",
 opts=[("$77,000","DROP"),("$63,500","KEY"),("$40,000","DROP"),("$70,500","ADJ")],
 target="PRODUCT · in the factory", deciding="DM + DL + all factory overhead; nothing from the office.",
 rule="Product cost = direct materials + direct labour + manufacturing overhead.", camo=["commissions","office rent","advertising"],
 why="$77,000 adds everything. $40,000 is DM + DL only. $70,500 adds commissions.")
add(q=51, concept="Cost of goods sold from production", miss=True,
 stem="First month: direct materials $24,000 · direct labour $36,000 · manufacturing overhead $30,000 · selling expenses $8,000 · administrative $5,000. The company produced 6,000 units and sold 4,500. What is cost of goods sold?",
 opts=[("$90,000","ADJ"),("$67,500","KEY"),("$77,250","DROP"),("$45,000","DROP")],
 target="PRODUCED 6,000 · SOLD 4,500", deciding="Cost per unit produced × units sold: $15 × 4,500.",
 rule="COGS = (total product cost ÷ units produced) × units sold.", camo=["selling","administrative"],
 why="$90,000 expenses everything produced. $77,250 adds period costs to the unit cost. $45,000 drops overhead.")
add(q=51, concept="Ending inventory — transfer", miss=True, transfer=True,
 stem="Same data. What is the value of finished-goods inventory at month-end?",
 opts=[("$27,000","ADJ"),("$22,500","KEY"),("$67,500","INV"),("$20,000","DROP")],
 target="INVENTORY · unsold", deciding="1,500 unsold × $15.",
 rule="Ending inventory = unsold units × product cost per unit.", camo=[],
 why="$27,000 uses $18/unit (adds period costs). $67,500 is COGS. $20,000 drops overhead.")
add(q=52, concept="Inventory cost", miss=False, choose=2,
 stem="Which two costs are included in the cost of a manufacturer's inventory? Choose 2.",
 opts=[("Factory supervisor's salary","KEY"),("Sales manager's salary","ADJ"),("Depreciation on production machinery","KEY"),("Depreciation on the sales fleet","ADJ")],
 target="INVENTORY cost", deciding="Factory-side overhead attaches to inventory; selling-side does not.",
 rule="Inventoriable cost = product cost.", camo=["parallel wording between each pair"])

# ── 7 · Activity-based costing ─────────────────────────────────────────────────
add(q=53, concept="When ABC fits", miss=False,
 stem="In which scenario would activity-based costing most improve product costing over a single plant-wide rate?",
 opts=[("One product, one process, overhead mostly machine depreciation","ADJ"),("Many products with different batch sizes, setups and inspection needs sharing one factory","KEY"),("A service firm with no overhead","CONF"),("A firm whose overhead is under 2% of total cost","ADJ")],
 target="most improve", deciding="Diversity of products and of the activities they consume.",
 rule="ABC pays off when products consume overhead activities in different proportions.", camo=[])
add(q=54, concept="ABC hierarchy", miss=False,
 stem="Machine setup and material movement between work centres are classified at which level of the ABC hierarchy?",
 opts=[("Unit-level","ADJ"),("Batch-level","KEY"),("Product-level","ADJ"),("Facility-level","ADJ")],
 target="setup · movement", deciding="Done once per batch, regardless of units in it.",
 rule="Unit (each item) · batch (each run) · product (each line) · facility (the plant).", camo=[])
add(q=55, concept="Cost driver", miss=True,
 stem="A hospital wants to assign laundry-department cost to its nursing units. Candidate bases: the laundry manager's hours · the price per gallon of detergent · pounds of linen processed per unit · the number of nurses on each unit. Which is the appropriate cost driver?",
 opts=[("The laundry manager's hours","ADJ"),("The price of detergent","CONF"),("Pounds of linen processed per unit","KEY"),("The number of nurses on each unit","ADJ")],
 target="DRIVER · assign to units", deciding="What makes laundry cost rise, and varies by unit? Linen volume.",
 rule="A cost driver is the activity that causes the cost and varies with the cost object.", camo=["detergent price — a cost input, not a driver"],
 why="Manager hours don't vary by unit. Detergent price is a cost. Nurse count is a headcount, not laundry activity.")
add(q=55, concept="Cost driver — transfer", miss=True, transfer=True,
 stem="Which of the following is a COST rather than a cost driver: number of purchase orders · pounds of material handled · the purchasing clerk's salary · number of machine setups?",
 opts=[("Number of purchase orders","ADJ"),("The purchasing clerk's salary","KEY"),("Pounds of material handled","ADJ"),("Number of machine setups","ADJ")],
 target="COST rather than driver", deciding="Reverse the question: the dollar amount is the cost; the counts are drivers.",
 rule="Drivers are measured in activity units; costs are measured in dollars.", camo=[])
add(q=56, concept="ABC allocation", miss=False,
 stem="Pools: machining $240,000 / 16,000 hours · setups $36,000 / 300 setups · inspection $12,000 / 400 inspections. Product X uses 5,000 hours, 60 setups, 100 inspections. Overhead applied to X?",
 opts=[("$90,000","ADJ"),("$85,200","KEY"),("$75,000","DROP"),("$82,200","DROP")],
 target="each pool its own rate", deciding="$15/hr × 5,000 + $120/setup × 60 + $30/insp × 100.",
 rule="Rate per pool × that product's consumption of that pool, summed.", camo=[],
 why="$90,000 uses a single plant-wide rate ($18/hr). $75,000 is machining only. $82,200 drops inspection.")
add(q=57, concept="ABC allocation", miss=False,
 stem="Same pools. Product Z uses 2,000 hours, 140 setups, 250 inspections. Overhead applied to Z?",
 opts=[("$36,000","ADJ"),("$54,300","KEY"),("$30,000","DROP"),("$46,800","DROP")],
 target="which product · which pool", deciding="$30,000 + $16,800 + $7,500.",
 rule="Same method; track the row.", camo=[],
 why="$36,000 is the plant-wide rate. $30,000 is machining only. $46,800 drops inspection.")
add(q=58, concept="Overhead application", miss=False,
 stem="Predetermined overhead rate $1.20 per machine hour · budgeted machine hours 400,000 · actual machine hours 460,000 · budgeted overhead $480,000 · actual overhead $540,000. What is applied overhead?",
 opts=[("$480,000","STEM"),("$552,000","KEY"),("$540,000","STEM"),("$12,000","ADJ")],
 target="APPLIED", deciding="Rate × actual base: $1.20 × 460,000.",
 rule="Applied overhead = predetermined rate × actual activity.", camo=["budgeted overhead","actual overhead"],
 why="$480,000 and $540,000 are stem numbers. $12,000 is the over-applied amount (552,000 applied − 540,000 actual), not applied overhead.")
add(q=59, concept="Using ABC results", miss=False,
 stem="Traditional costing put Product B's unit cost at $40; ABC puts it at $58. B sells for $50. Which conclusion follows?",
 opts=[("Cut B's price to regain volume","INV"),("B is losing money at $50; raise its price or reconsider the line","KEY"),("Return to traditional costing, which shows a profit","INV"),("Increase B's batch count to spread setup cost","INV")],
 target="ABC shows a higher cost", deciding="ABC revealed an under-costed product.",
 rule="When ABC raises a product's cost above its price, the price or the product has to change.", camo=[])

# ── 8 · Cost-volume-profit ─────────────────────────────────────────────────────
add(q=60, concept="Contribution margin and operating income", miss=True,
 stem="A refinery sells 400,000 gallons at $2.40. Variable cost is $1.70 per gallon; fixed costs are $180,000. Overhead was applied at $0.45 per gallon, $600 per batch and $1,200 per ingredient. If the selling price rises by $0.10 and volume holds, what is operating income?",
 opts=[("$320,000","DROP"),("$140,000","KEY"),("$100,000","ADJ"),("$40,000","DROP")],
 target="OPERATING income · after the increase", deciding="New CM $0.80 × 400,000 = $320,000, less fixed $180,000.",
 rule="Sales − variable = contribution margin; − fixed = operating income.", camo=["overhead rates — already inside the $1.70"],
 why="$320,000 stops at contribution margin. $100,000 is income before the increase. $40,000 is only the increase.")
add(q=60, concept="Contribution margin — transfer", miss=True, transfer=True,
 stem="Same refinery, original price. What price increase per gallon is needed to reach operating income of $200,000 at 400,000 gallons?",
 opts=[("$0.05","DROP"),("$0.25","KEY"),("$0.50","INV"),("$0.20","ADJ")],
 target="solve for the price", deciding="Need CM $380,000 → $0.95/gal → +$0.25.",
 rule="Work the equation backwards from the target income.", camo=[])
add(q=61, concept="Cost-volume-profit", miss=False, choose=2,
 stem="Which two concepts does cost-volume-profit analysis study? Choose 2.",
 opts=[("How fixed and variable costs behave as volume changes","KEY"),("How to allocate overhead across products","ADJ"),("The volume at which revenue covers all costs","KEY"),("How to value ending inventory under GAAP","CONF")],
 target="C-V-P", deciding="Cost behaviour and break-even are the two ideas.",
 rule="CVP studies cost behaviour and the volume-profit relationship, including break-even.", camo=[])
add(q=62, concept="Fixed cost behaviour", miss=False, choose=2,
 stem="As sales volume increases within the relevant range, which two are true? Choose 2.",
 opts=[("Total fixed costs stay the same","KEY"),("Fixed cost per unit falls","KEY"),("Variable cost per unit falls","INV"),("Total variable costs stay the same","INV")],
 target="TOTAL vs PER UNIT", deciding="Fixed: total constant, per-unit falls. Variable: per-unit constant, total rises.",
 rule="The word 'total' or 'per unit' decides every cost-behaviour question.", camo=[])
add(q=63, concept="Break-even in units", miss=False,
 stem="Price $45 · variable cost $27 per unit · fixed costs $216,000 · last year's volume 15,000 units · target profit $54,000. Break-even in units?",
 opts=[("4,800","INV"),("12,000","KEY"),("8,000","INV"),("15,000","STEM")],
 target="BREAK-EVEN units", deciding="Fixed ÷ CM per unit: 216,000 ÷ 18.",
 rule="BE units = fixed costs ÷ (price − variable cost).", camo=["last year's volume","target profit"],
 why="4,800 divides by price. 8,000 divides by variable cost. 15,000 is a stem number.")
add(q=64, concept="Break-even in revenue", miss=False,
 stem="At the break-even point, total revenue equals what?",
 opts=[("Total fixed costs","DROP"),("Total variable costs","DROP"),("Total fixed plus total variable costs","KEY"),("Contribution margin","ADJ")],
 target="break-even · revenue equals", deciding="Zero profit means revenue covers every cost.",
 rule="At break-even, revenue = total costs, and contribution margin = fixed costs.", camo=[])
add(q=65, concept="Reading a CVP graph", miss=True, graph=True,
 stem="Fixed costs $3,000 · variable cost $10 per unit · price $25 per unit. Using the graph, which statement is true at 300 units?",
 opts=[("Total costs equal $6,000","KEY"),("Sales revenue equals $6,000","ADJ"),("Fixed costs equal $6,000","ADJ"),("Profit equals $4,500","DROP")],
 target="which LINE · 300 units", deciding="Total-cost line at 300: 3,000 + 10 × 300.",
 rule="Identify the line before reading the number. Fixed is flat; total cost starts at fixed; revenue starts at zero.", camo=[],
 why="$6,000 is on the total-cost line, not revenue ($7,500). Fixed is $3,000 everywhere. $4,500 is revenue minus fixed only; profit is $1,500.")
add(q=65, concept="CVP graph — transfer", miss=True, transfer=True, graph=True,
 stem="Same graph. What is the break-even point?",
 opts=[("120 units","INV"),("200 units","KEY"),("300 units","INV"),("$5,000","ADJ")],
 target="break-even · units", deciding="Where the lines cross: 3,000 ÷ (25 − 10).",
 rule="Break-even is the crossing of total revenue and total cost.", camo=[],
 why="120 divides by price. 300 divides by variable cost. $5,000 is the revenue at break-even — right point, wrong unit.")

# ── 9 · Budgeting and credit ───────────────────────────────────────────────────
add(q=66, concept="Credit policy and bad debt", miss=False,
 stem="Bad-debt expense has doubled. Which credit-policy change would cause that?",
 opts=[("Shortening terms from net 60 to net 30","INV"),("Offering 2/10, n/30 on all credit sales","ADJ"),("Raising credit limits for every customer","KEY"),("Requiring a credit check before opening an account","INV")],
 target="cause an INCREASE", deciding="Which change lets weaker customers borrow more?",
 rule="Looser credit → more bad debt; tighter credit and discounts do not raise it.", camo=[])
add(q=67, concept="Cash collections budget", miss=False,
 stem="Sales: April $180,000 · May $240,000 · June $300,000. 55% of sales are cash; credit sales are collected 50% in the month of sale, 35% the next month, 15% the second month. Forecast June cash collections.",
 opts=[("$300,000","STEM"),("$282,450","KEY"),("$232,500","DROP"),("$270,300","DROP")],
 target="JUNE collections", deciding="165,000 + 67,500 + 37,800 + 12,150.",
 rule="Build the schedule: cash sales + this month's credit × 50% + last month's × 35% + two months ago × 15%.", camo=[],
 why="$232,500 drops both prior months. $270,300 drops April. $300,000 is June sales.")
add(q=68, concept="Purchases payment budget", miss=False,
 stem="Raw-material purchases: Jan $12,000 · Feb $18,000 · Mar $26,000 · Apr $21,000 · May $29,000 · Jun $33,000. Payment: 45% in the month of purchase, 30% the next, 25% the second. Budgeted cash disbursements for May?",
 opts=[("$29,000","STEM"),("$25,850","KEY"),("$28,800","ADJ"),("$19,350","DROP")],
 target="MAY disbursements", deciding="13,050 + 6,300 + 6,500.",
 rule="Which month is being paid, and for which purchases.", camo=[],
 why="$28,800 is June's disbursement. $19,350 drops March. $29,000 is May purchases.")
add(q=69, concept="Cash disbursements in a window", miss=False,
 stem="Inventory purchases: Jul $90,000 · Aug $60,000 · Sep $200,000 · Oct $110,000 · Nov $240,000 · Dec $40,000. Paid 50% in the month, 35% the next, 15% the second. Total 2014 cash payments for these purchases?",
 opts=[("$740,000","STEM"),("$684,000","KEY"),("$720,000","DROP"),("$664,000","DROP")],
 target="in 2014", deciding="Total $740,000 minus what falls in 2015: Dec 50% ($20,000) + Nov 15% ($36,000).",
 rule="Check the boundary months: what slips past the window.", camo=[],
 why="$740,000 ignores the window. $720,000 defers only December. $664,000 over-defers.")
