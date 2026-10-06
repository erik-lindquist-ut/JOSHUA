# Accounting for Decision Making — armored items, part A (Q1–Q35). One novel item per pre-assessment concept; misses carry a second transfer item.
# Molds: DROP dropped element · STEM wrong stem number · ADJ adjacent category · INV inverted operation · ABS absolute language · CONF confusion set · CAMO answers a camouflage fact
ITEMS = []
def add(**k): ITEMS.append(k)

# ── 1 · Environment and statements ─────────────────────────────────────────────
add(q=1, concept="Purpose of accounting", miss=False,
 stem="A regional grocer's annual report runs 140 pages: an ESG section on refrigerant leakage, a community-giving summary, a customer-satisfaction index, and audited statements. A lender reading it for a covenant review is using the accounting system to learn which one thing?",
 opts=[("How well the grocer is regarded by its customers","CAMO"),("The grocer's financial performance and position","KEY"),("Whether the grocer's environmental targets were met","CAMO"),("How much the grocer gave to community causes","CAMO")],
 target="lender · covenant", deciding="Accounting measures financial performance; everything else in the report is real but is not accounting.",
 rule="Accounting reports the financial performance and position of a business.", camo=["ESG section","community giving","satisfaction index","140 pages"])
add(q=2, concept="Statement of cash flows", miss=False,
 stem="A controller is asked for the one statement that shows, for the quarter just ended, cash received from customers, cash paid to acquire a warehouse, and cash paid to retire bonds — each in its own section. The CFO also wants to see the quarter-end cash balance reconciled. Which statement answers the request?",
 opts=[("Statement of cash flows","KEY"),("Statement of financial position","ADJ"),("Cash budget","CONF"),("Statement of stockholders' equity","CONF")],
 target="quarter just ended · three sections", deciding="Three activity categories over a period name one statement.",
 rule="The statement of cash flows summarises cash by operating, investing and financing activity over a period.", camo=["reconciled ending balance — it does, but the sections are the tell","CFO"])
add(q=3, concept="Users of financial statements", miss=False,
 stem="A manufacturer announces a pension freeze. Its statements are read that week by a bond rating agency, a union pension trustee, a competitor's strategy team, and the state tax authority. Which reader's primary concern is the firm's ability to keep funding retirement and health benefits?",
 opts=[("The bond rating agency","ADJ"),("The union pension trustee, on behalf of employees","KEY"),("The competitor's strategy team","CAMO"),("The state tax authority","CONF")],
 target="fund benefits", deciding="Whose benefit is at stake? Employees'.",
 rule="Employees and their representatives care about the firm's ability to fund pay and benefits.", camo=["pension freeze","rating agency","tax authority"])
add(q=4, concept="GAAP", miss=False,
 stem="A privately held firm preparing for an IPO switches from a home-grown reporting format to full GAAP. Its CFO notes that reported income will fall because some revenue must now be deferred. Which benefit is the actual reason for the switch?",
 opts=[("Lower income tax, because reported income falls","INV"),("Comparability with other public companies for investors","KEY"),("A larger reported asset base to support the offering","INV"),("Exemption from external audit once GAAP is adopted","ABS")],
 target="benefit · reason for the switch", deciding="GAAP exists so statements can be compared across companies.",
 rule="Following GAAP makes a company comparable to others; it does not lower tax or raise assets.", camo=["income will fall","revenue deferred","IPO"])
add(q=5, concept="PCAOB", miss=False,
 stem="A Big Four firm audits a NYSE-listed retailer and, separately, a family-owned hardware chain. A deficiency is found in the retailer's audit workpapers. Which body has authority to inspect and discipline the firm for that engagement?",
 opts=[("The Financial Accounting Standards Board","CONF"),("The Public Company Accounting Oversight Board","KEY"),("The Internal Revenue Service","CONF"),("The state board that licenses the family-chain engagement","ADJ")],
 target="NYSE-listed · audit workpapers", deciding="Public-company audit oversight is one body: PCAOB.",
 rule="The PCAOB regulates audits of public companies; FASB sets standards; the IRS collects tax.", camo=["family-owned chain","Big Four"])
add(q=6, concept="Drivers of change", miss=False,
 stem="Between 1995 and today an accounting department went from ledgers closed by hand to real-time dashboards, continuous auditing, and outsourced payroll. Of the forces below, which has had the most significant impact on accounting practice?",
 opts=[("The growth of professional certification","ADJ"),("Information technology","KEY"),("Outsourcing of routine functions","STEM"),("Cloud-hosted payroll services","ADJ")],
 target="most significant", deciding="The broadest technological cause, not one of its products.",
 rule="Information technology has changed accounting practice more than any other force.", camo=["outsourced payroll","continuous auditing — both are IT's children"])
add(q=7, concept="Balance sheet", miss=False, choose=2,
 stem="An analyst has only one page from a company's 10-K: the statement dated December 31. Which two things can she read directly from it? Choose 2.",
 opts=[("What the company owes","KEY"),("What the company earned during the year","ADJ"),("Who owns the residual and how much","KEY"),("How much cash operations generated","ADJ")],
 target="dated December 31", deciding="A date means position: liabilities and equity.",
 rule="The balance sheet shows debt (liabilities) and ownership (equity) at a date.", camo=["10-K","one page"])
add(q=8, concept="Owners' equity", miss=False,
 stem="After paying every creditor in full from the proceeds of its assets, whatever a company has left belongs to one group. In the statements, what is that residual called?",
 opts=[("Working capital","CONF"),("Owners' equity","KEY"),("Retained earnings","ADJ"),("Net income","ADJ")],
 target="residual · after every creditor", deciding="Net assets minus liabilities is equity by definition.",
 rule="Owners' equity is the residual interest in net assets after liabilities.", camo=["proceeds of its assets"])
add(q=9, concept="Accounting equation", miss=True,
 stem="A corporation reports total assets of $840 million, current liabilities of $190 million, total liabilities of $510 million, current assets of $260 million, retained earnings of $95 million, and a market capitalisation of $1.2 billion. What is the value of its long-term assets?",
 opts=[("$330 million","ADJ"),("$580 million","KEY"),("$320 million","ADJ"),("$650 million","INV")],
 target="long-term ASSETS", deciding="Total assets minus current assets. Nothing else in the stem is needed.",
 rule="Long-term = total − current, on the same side of the equation.", camo=["total liabilities","retained earnings","market cap","current liabilities"],
 why="$330M is equity (840−510). $320M is long-term liabilities (510−190). $650M subtracts current liabilities from assets — mixed sides.")
add(q=9, concept="Accounting equation — transfer", miss=True, transfer=True,
 stem="A firm's owners' equity is $330 million and its total liabilities are $510 million. Current assets are $260 million and current liabilities are $190 million. What are total assets?",
 opts=[("$180 million","INV"),("$840 million","KEY"),("$510 million","STEM"),("$1,020 million","ADJ")],
 target="TOTAL assets", deciding="A = L + E. Add.",
 rule="Assets = liabilities + equity.", camo=["current assets","current liabilities"],
 why="$180M subtracts. $510M is a stem number. $1,020M doubles liabilities.")
add(q=10, concept="Revenue recognition", miss=False,
 stem="A consulting firm on accrual accounting has four events in December 2015: (1) it collects $40,000 for work delivered in October; (2) it signs a $90,000 engagement letter for work starting in March; (3) it delivers a $25,000 project and invoices 60-day terms; (4) a client prepays $15,000 for January work. Which event puts revenue on the 2015 income statement?",
 opts=[("Event 1 — the $40,000 collection","INV"),("Event 2 — the $90,000 signed engagement","CONF"),("Event 3 — the $25,000 project delivered on terms","KEY"),("Event 4 — the $15,000 prepayment","INV")],
 target="delivered", deciding="Find the event where the work was done in the year.",
 rule="Revenue is recognised when earned, not when cash moves or a contract is signed.", camo=["$40,000 collection","$90,000 letter","$15,000 prepayment"])
add(q=11, concept="Financing activities", miss=False,
 stem="During the year a company issued preferred stock, paid a cash dividend, repurchased common shares, paid interest on its bonds, and repaid the principal of a term loan. On the statement of cash flows, which category collects the flows between the company and its owners and lenders — all of them except one?",
 opts=[("Operating activities","ADJ"),("Financing activities","KEY"),("Investing activities","ADJ"),("Non-cash disclosures","CONF")],
 target="owners and lenders", deciding="Owners and creditors define financing. (The exception is interest paid — operating under US GAAP.)",
 rule="Financing = cash to and from owners and lenders: stock, dividends, buybacks, principal.", camo=["interest on bonds — operating, the one exception"])
add(q=12, concept="Notes to the statements", miss=False,
 stem="An investor wants to know whether a company depreciates its fleet straight-line or by units of activity, and how it values inventory. She has the balance sheet, income statement, cash flow statement, auditor's opinion and the notes. Where is the answer?",
 opts=[("On the face of the balance sheet, beside the asset","ADJ"),("In the summary of significant accounting policies in the notes","KEY"),("In the auditor's opinion paragraph","CONF"),("In the income statement's depreciation line","ADJ")],
 target="how · method", deciding="Methods and policies live in the notes.",
 rule="Significant accounting policies are disclosed in the notes.", camo=["auditor's opinion","five documents listed"])
add(q=13, concept="External audit", miss=False,
 stem="A bank's credit memo says: \"Statements audited by a national firm; unqualified opinion.\" Which assurance does that opinion actually give the bank?",
 opts=[("The statements are guaranteed free of all error","ABS"),("Reasonable assurance the statements are fairly presented under GAAP","KEY"),("Certainty that no fraud occurred during the year","ABS"),("Assurance that the company will remain solvent","ADJ")],
 target="assurance", deciding="Reasonable, not absolute.",
 rule="An audit gives reasonable assurance of fair presentation — never a guarantee.", camo=["national firm","credit memo"])
add(q=14, concept="Qualitative characteristics", miss=False,
 stem="A controller writes off a $600 obsolete part without a memo, records a probable lawsuit loss but not a probable lawsuit gain, and insists that two independent accountants would compute the same inventory value. Which characteristic does the lawsuit treatment illustrate?",
 opts=[("Materiality","ADJ"),("Conservatism","KEY"),("Verifiability","ADJ"),("Relevance","CONF")],
 target="loss recorded, gain not", deciding="Recognise losses when probable, gains when realised — that asymmetry is conservatism.",
 rule="Materiality = too small to matter · Conservatism = losses early, gains late · Verifiability = independent agreement · Relevance = changes a decision.", camo=["$600 write-off — materiality","two accountants — verifiability"])
add(q=15, concept="Decision cycle", miss=True,
 stem="In the course's five-step decision cycle, a manager has just finished analysing the financial statements. Which step comes next?",
 opts=[("Prepare the financial statements","INV"),("Gather additional information","KEY"),("Make the decision","DROP"),("Implement the decision","DROP")],
 target="just finished analysing · next", deciding="The scored order: prepare → analyse → gather → decide → implement.",
 rule="Statements are the starting input, not the output. Gathering comes after analysis in this cycle.", camo=[],
 why="Prepare is step 1, already done. Decide and implement skip the gathering step.")
add(q=15, concept="Decision cycle — transfer", miss=True, transfer=True,
 stem="In the same five-step cycle, which step is last?",
 opts=[("Gather additional information","INV"),("Implement the decision","KEY"),("Analyse the statements","INV"),("Make the decision","ADJ")],
 target="last", deciding="Implement closes the cycle.",
 rule="prepare → analyse → gather → decide → implement.", camo=[])

# ── 2 · Ratios ─────────────────────────────────────────────────────────────────
add(q=16, concept="Price-earnings ratio", miss=True,
 stem="Net income $4,200 · shares outstanding 1,500 · share price $28 · sales $52,000 · total assets $61,000 · book equity $12,000 · dividends $900. What is the price-earnings ratio?",
 opts=[("3.5","ADJ"),("10.0","KEY"),("12.4","STEM"),("0.81","ADJ")],
 target="price-EARNINGS", deciding="Price ÷ EPS, or market cap ÷ net income. Same answer.",
 rule="PE = price per share ÷ earnings per share.", camo=["sales","total assets","dividends","book equity"],
 why="3.5 is price-to-book (42,000/12,000). 12.4 is sales ÷ net income. 0.81 is market cap ÷ sales.")
add(q=16, concept="Current ratio — transfer", miss=True, transfer=True,
 stem="Current assets $36,543 · total assets $58,719 · current liabilities $24,824 · total liabilities $48,561 · equity $10,158 · net income $3,761. What is the current ratio?",
 opts=[("1.21","ADJ"),("1.47","KEY"),("0.75","ADJ"),("0.68","INV")],
 target="CURRENT over CURRENT", deciding="Both words must match.",
 rule="Current ratio = current assets ÷ current liabilities.", camo=["total assets","total liabilities","equity","net income"],
 why="1.21 is total ÷ total. 0.75 is current assets ÷ total liabilities. 0.68 is inverted.")
add(q=17, concept="Debt ratio", miss=False,
 stem="A distributor reports a debt ratio of 92%, a current ratio of 0.8, and sales of three times total assets. What does the 92% tell you?",
 opts=[("Liabilities are 92% of sales","ADJ"),("Liabilities are 92% of total assets, so equity is 8%","KEY"),("Current liabilities are 92% of current assets","CAMO"),("Interest consumes 92% of operating cash","CONF")],
 target="debt ratio", deciding="Debt ratio is total liabilities ÷ total assets.",
 rule="Debt ratio = total liabilities ÷ total assets; the remainder is equity's share.", camo=["current ratio 0.8","sales × 3"])
add(q=18, concept="Gross profit", miss=False,
 stem="Over six quarters a retailer's cost of goods sold has held at $1.8 million while gross profit has fallen every quarter. Interest expense rose, salaries fell, and the tax rate changed twice. What explains the falling gross profit?",
 opts=[("Rising interest expense","CAMO"),("Falling sales revenue","KEY"),("Falling salaries","CAMO"),("The changing tax rate","CAMO")],
 target="GROSS profit · COGS constant", deciding="Gross profit is only sales minus COGS, so with COGS fixed, sales fell.",
 rule="Gross profit = sales − cost of goods sold. Nothing below that line touches it.", camo=["interest","salaries","tax rate"])
add(q=19, concept="Cash flow adequacy", miss=False, choose=2,
 stem="Four divisions report operating cash flow over required commitments (debt service, capex, dividends). Which two are cash cows? Choose 2.",
 opts=[("$7,420 / $5,300","KEY"),("$6,150 / $2,050","KEY"),("$8,900 / $9,100","ADJ"),("$4,400 / $4,350","ADJ")],
 target="cash cow · comfortably above 1", deciding="Divide before comparing: 1.40 · 3.00 · 0.98 · 1.01.",
 rule="Adequacy above 1 means operating cash covers commitments; a cow is well above 1.", camo=["the largest numerator ($8,900) is below 1"])
add(q=20, concept="Cash times interest earned", miss=False,
 stem="Cash from operations before interest and taxes $96,000 · cash paid for interest $8,000 · cash paid for income taxes $12,000 · cash from operations $40,000 · cash paid for acquisitions $30,000. What is cash times interest earned?",
 opts=[("8.0","ADJ"),("12.0","KEY"),("2.4","ADJ"),("4.8","DROP")],
 target="INTEREST earned", deciding="Interest in the denominator: 96,000 ÷ 8,000.",
 rule="Cash times interest earned = cash before interest and taxes ÷ cash paid for interest.", camo=["taxes","cash from operations","acquisitions"],
 why="8.0 divides by taxes. 2.4 divides by cash from operations. 4.8 divides by interest plus taxes.")
add(q=21, concept="Long-term liabilities", miss=False,
 stem="At year-end a company owes: trade payables $210,000 · accrued wages $38,000 · the current portion of a mortgage $60,000 · the remaining mortgage principal due over eight years $540,000 · a customer deposit refundable in 90 days $12,000. Which item is a long-term liability?",
 opts=[("The trade payables","ADJ"),("The $540,000 mortgage principal due beyond one year","KEY"),("The $60,000 current portion of the mortgage","ADJ"),("The refundable customer deposit","ADJ")],
 target="due beyond one year", deciding="One year is the line; the same mortgage is split across it.",
 rule="Long-term = due after one year (or the operating cycle). The current portion of long-term debt is current.", camo=["same mortgage appears twice"])

# ── 3 · Transactions and accrual ───────────────────────────────────────────────
add(q=22, concept="Transaction analysis", miss=False,
 stem="On March 8 a start-up buys inventory costing $200,000, paying $120,000 in cash and putting the rest on supplier credit. Earlier in the month it raised $1,000,000 in stock and borrowed $250,000 at 12%. What is the March 8 effect on the balance sheet?",
 opts=[("Inventory +$120,000 · cash −$120,000","DROP"),("Inventory +$200,000 · cash −$120,000 · accounts payable +$80,000","KEY"),("Inventory +$200,000 · cash −$200,000","STEM"),("Inventory +$200,000 · retained earnings −$80,000","ADJ")],
 target="the rest on credit", deciding="Three accounts move; equity does not.",
 rule="Assets acquired = cash given + liability created. Equity is untouched by a purchase.", camo=["stock issue","12% loan"])
add(q=23, concept="Prepaid expense", miss=False,
 stem="On January 30 a company pays $9,600 cash for a twelve-month insurance policy that begins February 1. What does the January 31 balance sheet show for this transaction?",
 opts=[("Prepaid insurance +$9,600 · cash −$9,600","KEY"),("Prepaid insurance +$8,800 · insurance expense $800 · cash −$9,600","INV"),("Cash −$9,600 · accounts payable −$9,600","CONF"),("Insurance expense $9,600 · cash −$9,600","INV")],
 target="begins February 1 · January 31", deciding="Coverage hasn't started; nothing is expensed yet.",
 rule="Paid in advance = an asset until the benefit is consumed.", camo=["twelve-month"])
add(q=24, concept="Net income", miss=False, choose=2,
 stem="During the year a company: paid $50,000 in dividends · recorded $410,000 of operating expenses · received $200,000 from a new investor · recognised a $30,000 loss on a lawsuit settlement · repurchased $75,000 of its own stock. Which two affect net income? Choose 2.",
 opts=[("The dividends","ADJ"),("The operating expenses","KEY"),("The new investor's $200,000","ADJ"),("The lawsuit loss","KEY")],
 target="net INCOME", deciding="Owners' transactions never touch net income.",
 rule="Expenses and ordinary gains/losses affect income; dividends, contributions and buybacks are equity transactions.", camo=["stock repurchase"])
add(q=25, concept="Multi-step income statement", miss=False, choose=2,
 stem="A CFO wants the two subtotals that a multi-step income statement reports and a single-step one does not. Which two? Choose 2.",
 opts=[("Gross profit","KEY"),("Total current liabilities","ADJ"),("Income from operations","KEY"),("Net increase in cash","ADJ")],
 target="income statement subtotals", deciding="Subtotals of performance, not position or cash.",
 rule="Multi-step shows gross profit and operating income as subtotals.", camo=["single-step comparison"])
add(q=26, concept="Accrual — expense timing", miss=False,
 stem="A dealer on accrual accounting buys 30 e-bikes in October, sells 12 in November on 60-day terms, pays sales commissions on November sales in December, and ran a $4,500 radio campaign in October that it paid for in November. In which month are the commissions expensed?",
 opts=[("October","CAMO"),("November","KEY"),("December","INV"),("January","DROP")],
 target="commissions · sales in November", deciding="Match the expense to the sale that caused it, not the payment.",
 rule="Under accrual, expense follows the event, not the cash.", camo=["e-bike purchase","radio campaign","60-day terms"])
add(q=27, concept="Prepaid expense over time", miss=False,
 stem="On November 1, 2011 a company pays $14,400 for a 24-month equipment insurance policy and the same day buys the equipment for $720,000 with a five-year life. How much insurance expense belongs in 2011?",
 opts=[("$14,400","STEM"),("$1,200","KEY"),("$7,200","INV"),("$600","DROP")],
 target="24-month · November 1", deciding="Two months of 24: 14,400 ÷ 24 × 2.",
 rule="Expense the months actually covered in the period.", camo=["$720,000 equipment","five-year life"],
 why="$7,200 is a full year. $600 is one month. $14,400 is the whole policy.")
add(q=28, concept="Revenue on account", miss=True, choose=2,
 stem="In February a services firm delivers $18,000 of technology consulting. Clients pay $5,000 in cash on delivery and promise the balance in March. The same week a client prepays $3,000 for April work. Apart from the $5,000 cash increase, what is the total balance-sheet impact of the services delivered? Choose 2.",
 opts=[("Accounts receivable +$13,000","KEY"),("Retained earnings +$5,000","INV"),("Retained earnings +$18,000","KEY"),("Unearned revenue +$18,000","CONF")],
 target="services DELIVERED · apart from cash", deciding="Revenue earned drives equity; cash timing doesn't.",
 rule="Delivered on credit: receivable up by the unpaid part, equity up by the whole revenue.", camo=["$3,000 prepayment — a liability, not this question"],
 why="Retained earnings +$5,000 uses the cash amount. Unearned revenue is the prepayment's account, not the delivery's.")
add(q=28, concept="Revenue on account — transfer", miss=True, transfer=True,
 stem="A client prepays $9,000 in June for services the firm will perform in August. What is the June balance-sheet effect other than cash +$9,000?",
 opts=[("Retained earnings +$9,000","INV"),("Unearned revenue +$9,000","KEY"),("Accounts receivable +$9,000","CONF"),("Revenue +$9,000","INV")],
 target="prepays · will perform", deciding="Cash before work = an obligation, not income.",
 rule="Cash received before the work is a liability until earned.", camo=[])
add(q=29, concept="Pro-forma growth", miss=False,
 stem="A 2016 pro-forma net profit of $228,800 was built on a 30% increase over 2015, after a 12% increase the year before. What was 2015 net profit?",
 opts=[("$297,440","INV"),("$176,000","KEY"),("$160,160","INV"),("$198,800","DROP")],
 target="WAS · base year", deciding="Divide by 1.30. Work backwards.",
 rule="Base = projection ÷ (1 + growth).", camo=["12% the year before"],
 why="$297,440 multiplies by 1.3. $160,160 multiplies by 0.7. $198,800 subtracts 30,000.")

# ── 4 · Cash flows ─────────────────────────────────────────────────────────────
add(q=30, concept="Cash flow categories", miss=False,
 stem="A junior analyst rebuilds a cash flow statement with these headings: Operating · Capital · Investing · Shareholder · Financing · Discretionary. Which three should survive?",
 opts=[("Operating, Capital, Shareholder","CONF"),("Operating, Investing, Financing","KEY"),("Capital, Investing, Discretionary","CONF"),("Operating, Financing, Shareholder","ADJ")],
 target="headings", deciding="Three categories, fixed by the standard.",
 rule="Operating · investing · financing. Nothing else.", camo=["plausible extra headings"])
add(q=31, concept="Financing — investors", miss=False,
 stem="\"Cash received from investors in exchange for common stock\" and \"cash received from customers for gift cards\" both arrive the same day. Which category takes the investor cash?",
 opts=[("Operating","ADJ"),("Investing","CONF"),("Financing","KEY"),("Both amounts are financing","ADJ")],
 target="from INVESTORS", deciding="Owners = financing. The word 'investing' is the bait.",
 rule="Cash from owners is financing, whatever the word 'investor' suggests.", camo=["gift cards — operating"])
add(q=32, concept="Investing activities", miss=False,
 stem="Which item is an investing activity: purchase of a delivery truck · payment of a supplier · issuance of bonds · payment of a dividend?",
 opts=[("Payment of a supplier","ADJ"),("Purchase of a delivery truck","KEY"),("Issuance of bonds","ADJ"),("Payment of a dividend","ADJ")],
 target="long-lived asset", deciding="Buying or selling productive assets is investing.",
 rule="Investing = long-term assets bought or sold.", camo=[])
add(q=33, concept="Sale of equipment", miss=True,
 stem="A company sells a machine with a book value of $40,000 for $52,000 cash, recognising a $12,000 gain. Under the indirect method, how does this appear on the statement of cash flows?",
 opts=[("Operating +$52,000","ADJ"),("Investing +$52,000, and the $12,000 gain subtracted in operating","KEY"),("Investing +$12,000","STEM"),("Financing +$52,000","CONF")],
 target="sells a MACHINE · proceeds", deciding="The asset sold sets the category; the gain is only an operating adjustment.",
 rule="Proceeds from selling equipment are investing inflows; the gain is removed from operating so it isn't counted twice.", camo=["book value","gain"],
 why="Operating +$52,000 puts proceeds in the wrong section. Investing +$12,000 reports the gain, not the cash.")
add(q=33, concept="Sale of equipment — transfer", miss=True, transfer=True,
 stem="The same company sells a second machine for $20,000 cash at a $5,000 loss. What is the investing-section effect?",
 opts=[("+$15,000","INV"),("+$20,000","KEY"),("+$25,000","INV"),("−$5,000","ADJ")],
 target="investing effect · cash received", deciding="Cash received is the investing number; the loss is an operating add-back.",
 rule="Investing shows the cash, not the accounting result.", camo=["loss"])
add(q=34, concept="Direct vs indirect method", miss=False,
 stem="Which statement about the direct and indirect methods is true?",
 opts=[("They produce different totals for operating cash flow","INV"),("They produce the same operating total; only the presentation of the operating section differs","KEY"),("The indirect method is prohibited under US GAAP","ABS"),("The direct method starts from net income","INV")],
 target="direct vs indirect", deciding="Same total, different route; investing and financing identical.",
 rule="Direct lists receipts and payments; indirect starts from net income. Same operating total.", camo=[])
add(q=35, concept="Operating cash flow", miss=False,
 stem="Cash transactions for the year: from customers $980,000 · inventory purchases −$520,000 · wages −$210,000 · rent −$36,000 · interest paid −$18,000 · income taxes −$44,000 · equipment purchase −$150,000 · dividends −$25,000 · new long-term borrowing +$100,000 · treasury stock −$30,000. Under US GAAP, what is cash flow from operating activities?",
 opts=[("$170,000","DROP"),("$152,000","KEY"),("$47,000","ADJ"),("$127,000","ADJ")],
 target="OPERATING · US GAAP", deciding="Include interest and taxes; exclude equipment, dividends, borrowing, buyback.",
 rule="Operating = customer receipts − operating payments, and under US GAAP interest paid is operating.", camo=["equipment","dividends","borrowing","treasury stock"],
 why="$170,000 drops interest. $47,000 nets everything. $127,000 subtracts dividends.")
