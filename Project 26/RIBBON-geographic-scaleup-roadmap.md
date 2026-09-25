# RIBBON — Manufacturing & Distribution Scale-Up Roadmap

> **⚠ SUPERSEDED IN PART (Rev H.1).** This document predates Rev E (Level-as-Table / ribbon segments). Its freight assumptions (oversized monolith, ~class 400) and its distributed-microfactory recommendation no longer hold: stacked-segment freight (~class 85) strengthens the CENTRALIZED case — current guidance lives in PRD-12 and the crossover model, and the network decision waits on real quotes (Freight RFQ package). Phasing logic, DFMA principles, and make/buy/print reasoning remain useful history.


### West → East → National → Global

> Builds on the distributed-leaning hybrid from the productionization playbook. All figures are rough order-of-magnitude planning assumptions (±30–40%), not quotes.

---

## Operating principle

Optimize **landed cost + lead time**, not ex-works fabrication cost. For an oversized, heavy, high-mix product, freight and lead time dominate — so:

- **Centralize** the flat, dense, standard, low-mix parts (base plates, spine, trough kits, hardware) at a few **parts hubs**; make them in volume and ship them compact.
- **Distribute** the bulky, custom work (top skin, core, insert kitting, final assembly, QA) to **regional microfactories** near demand, fed by the parametric file + a hub kit.
- **License** to add nodes fast once a region proves out. Never long-haul an assembled 3.9 m table — and never ship one across an ocean.
- The **digital thread** (one configurator → CAD/CAM → QA standard) is the connective tissue that keeps quality consistent across every node without central manufacturing.

### Network roles
| Role | Makes | Traits | Placement |
|---|---|---|---|
| **Parts hub** (centralized) | Base plates, steel spine, trough kits, hardware, power modules | Flat, dense, standard, low-mix — travels well | Few, central to the regions they feed |
| **Regional microfactory** (distributed) | Top skin (thermoform → LFAM), core, insert kitting, assembly, QA | Bulky, custom, final assembly — must be local | Many, near demand |
| **Design/Ops HQ** | Parametric engine, configurator, digital thread, QA + licensing | Asset-light IP core | One |

---

## Phased geographic roadmap

| Phase | Timeframe | Nodes added | Made local vs. shipped in | Landed cost trend | Lead time | Primary risk |
|---|---|---|---|---|---|---|
| **W — West anchor** | Yr 1–2 | SoCal microfactory (LA metro) | Everything local at first; dense parts sourced regionally | Baseline | 3–8 wks | Single point of failure |
| **E — East node** | Yr 2–3 | Southeast microfactory **+ central parts hub (Midwest)** | Coasts finish/assemble locally; hub ships compact dense parts to both | ↓ (freight ~halved nationally) | 3–6 wks | Two-node quality consistency |
| **N — National mesh** | Yr 3–4 | +2–3 licensed microfactories (TX, Mid-Atlantic, +1) | Last-mile finishing local; LFAM tops begin at high-volume nodes | ↓↓ (freight minimized) | 1–3 wks | Partner onboarding & QA at scale |
| **G — Global** | Yr 4–6+ | Continental nodes: Canada → Europe → APAC → MEA | Export the **design**, qualify regional fabricators; ship only specialized components | Region-local | In-region | Tariffs, standards, IP |

### Phase W — West anchor (Yr 1–2)
One SoCal finishing/assembly microfactory serving CA, the Pacific Northwest, Arizona, Nevada, and the mountain west. Dense parts are sourced regionally on an interim basis. Goal: prove the product, the configurator→CAM path, and the first references. Short-haul LTL keeps landed cost low across the West.

### Phase E — East node → coast-to-coast (Yr 2–3)
Stand up a **Southeast microfactory** — recommended in the **Piedmont/Triad of North Carolina** (deep furniture-manufacturing cluster around High Point) or **Atlanta** (logistics depth + Savannah port) — serving the Eastern Seaboard, Southeast, and into the Mid-Atlantic/Northeast. Simultaneously open a **central parts hub in the Midwest metal-fab corridor** (Ohio/Indiana/Chicago) that makes base plates and spines in volume and ships them compact to *both* coasts, minimizing dense-part freight from a central point. Result: two finishing microfactories + one parts hub put ~90% of US institutional demand within medium-haul of a node, roughly halving national freight versus a single West node.

### Phase N — National mesh (Yr 3–4)
Add 2–3 more regional microfactories to erase the last freight miles — Texas/South-Central (Dallas), Mid-Atlantic/Northeast (PA/NJ), and one more as volume warrants — onboarded via **licensing and on-demand networks** (regional solid-surface + metal shops, Xometry-type capacity) rather than owned plants. **Large-format additive (LFAM) tops** come online at the highest-volume nodes, eliminating mold cost and re-enabling true per-order geometry. Coverage becomes asset-light, fast (1–3 wk lead), and resilient.

### Phase G — Global (Yr 4–6+)
Replicate make-near-demand internationally by **exporting the design, not the table**: qualify regional fabricators, stand up continental parts hubs, and ship only specialized components where needed. Sequence by attractiveness × ease of entry:

1. **Canada (Yr 4)** — adjacency and USMCA; serve from US nodes first, then a Toronto/Vancouver microfactory.
2. **Europe (Yr 4–5)** — strong education/institutional/design demand and sustainability alignment; metric-native. A Benelux/Germany microfactory + continental parts hub. **Our multi-height wave maps naturally onto EN 1729 educational-furniture size marks** — a credibility and spec advantage. Watch CE marking, accessibility norms, and ecodesign/EPR obligations; local content sidesteps EU furniture duties.
3. **APAC (Yr 5–6)** — fastest-growing contract-furniture region but the most competitive and manufacturing-dense. **License to strong regional manufacturers**, localize aggressively, and protect IP carefully; premium nodes (Singapore/ANZ) vs. cost partners (Vietnam/China).
4. **Middle East (Yr 5–6)** — hospitality and civic megaprojects; premium, partner-led.

**Global considerations grid**
- **Tariffs/trade** — furniture carries meaningful import duties and trade actions; local make-near-demand avoids most of them, so distribution is a *tariff* strategy, not just a logistics one.
- **Standards/certification** — US: BIFMA, Greenguard, ADA. EU: EN 1729 (education sizing), CE, accessibility, ecodesign/EPR. Each region needs local cert; the multi-height concept is a selling point against sizing standards.
- **IP** — register design rights per jurisdiction; serialized files, controlled toolpaths, staged disclosure to licensees; strongest caution in low-enforcement markets.
- **Supply resilience** — qualify multi-region suppliers for solid surface, steel, and stainless; prioritize recycled/low-carbon feedstock; nearshore where possible.

---

## Make / buy / print — how it localizes
- **Top skin:** made-with-mold early in each new node → shifts to **printed (LFAM)** once that node's volume justifies it. Print capability rolls out node-by-node, west to east to global.
- **Dense standard parts** (base plates, spine, trough kits, hardware): consolidate to **continental parts hubs** — each region *buys from its hub*, not from overseas.
- **Inserts/lids:** printed at any new/low-volume node; tooled (bought) per continent once regional volume pays for molds.

## When to open a node / centralize a part (rule of thumb)
- **Open a regional finishing node** when in-region annual volume × freight-saved-per-unit **exceeds** node standup + fixed cost — for an oversized product that tends to land around **~150–300 units/yr** in a region given the freight it saves.
- **Centralize a part** only when (per-unit scale saving × units) **exceeds** the added freight of shipping it in. Flat/dense parts clear this easily; the bulky top never does — which is the whole reason the top stays distributed.
