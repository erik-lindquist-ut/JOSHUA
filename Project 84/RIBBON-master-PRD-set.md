# RIBBON — Master PRD Set (Rev F)
### One PRD per part · plus strategic PRDs · Ribbon Segment architecture (Level-as-Ribbon) is the ratified architecture

Format per PRD: Problem → Goals → Non-Goals → Key user stories → Requirements (P0/P1/P2 with acceptance criteria) → Success metrics → Open questions. Shared context: buyers are institutions (schools, museums/libraries, family hospitality, coworking, senior living); end users span toddlers to seniors including wheelchair users; production is configurator-driven and distributed-capable.

---

## PART PRDs

### PRD-01 · L-Ribbon Platform (the common chassis)
**Problem.** Fourteen mixed users can't share one fixed-height surface; monolithic multi-height tables are unshippable and unrepairable. Every ribbon segment must share one chassis so the system stays manufacturable and interoperable.
**Goals.** One chassis serves all heights 560–1100 mm; any two tables dock in <2 min; per-table freight ≤ standard LTL parcel/pallet class; single-table replacement possible in field.
**Non-Goals.** Motorized height adjustment (complexity/cost, v2+); outdoor-rated version (separate line); seating integration (chair-free is the product).
**Stories.** As a facilities manager, I want any damaged table swapped without touching the rest of the arrangement so downtime is minutes. As a teacher, I want to undock three tables for group work so the room reconfigures without tools beyond the release key.
**Requirements.**
- P0: Common dock interface on all four (Hex: six) edges; B1–B13 compliance per table; top of any height mounts the same chassis; serialized digital twin per table. *AC: any L-table docks to any other with ≤1 mm top misalignment; 350 N anti-tip passes undocked (B3).*
- P1: Integrated leveling readout (bubble/indicator); tool-free glide adjustment.
- P2: Sensor-ready mount (occupancy analytics) — design the cavity now, ship empty.
**Metrics.** Dock time (target <2 min, stretch <1 min); field-swap time <15 min; warranty claims <2%/yr.
**Open questions.** Engineering: one chassis size or two (standard + bar-width base)? Data: serialization format shared with configurator (PRD-09)?

### PRD-02 · L-Ribbons L560–L1100 (height variants)
**Problem.** Each user class needs a correct working height with class-specific risks (toddler edges, bar-height tip).
**Goals.** Full ladder 560/650/680/740/780/820/950/1050/1100; each passes B3 undocked; toddler and bar variants carry class-specific safety features.
**Non-Goals.** Heights outside 560–1100 (no demand evidence); per-table custom heights at launch (P2 via configurator).
**Stories.** As a preschool director, I want the L560 safe for unsupervised toddlers so it can live in the free-play room. As a café owner, I want L1050s that can't be pulled over so standing crowds are safe.
**Requirements.**
- P0: L740-A accessible variant with B5 knee clearance on all open sides; bar heights (L950+) get widened base plates sized by B3 worst case; L560/L650 get R25 edges and zero reachable fasteners. *AC: each height passes 350 N pull at worst edge; L740-A accepts a 760 mm wheelchair square-on at any open edge.*
- P1: Footrail integral on L950+; weighted-skirt option for high-traffic venues.
- P2: Configurator-set custom heights within class bands.
**Metrics.** Zero tip incidents in pilots; accessibility bay utilization ≥ weekly in every pilot.
**Open questions.** Engineering: does L1100 need a third foot or wider plate? Pilot data to decide.

### PRD-03 · The Knot (fixed focal segment, formerly F-Hub)
**Problem.** Arrangements need a heart — structure, services, and identity — and wet/powered functions can't fragment across spliced segments.
**Goals.** One hub per arrangement carries services (power/water/irrigation) up its own mast; typed at order (Planted · Service · Ice · Solid); recognizable brand signature.
**Non-Goals.** Field-swappable hub type (fixed-at-order is the law); hub-less arrangements at launch (P2 for pure same-height runs).
**Stories.** As an event manager, I want the Ice hub plumbed and drained so service runs without bus tubs. As a librarian, I want the Planted hub self-watering for two weeks so upkeep is trivial.
**Requirements.**
- P0: B11 compliance (≥200 kg service load, internal routing, child-safe); docks to all shapes' geometry; drain/valve serviceable from below. *AC: hub-fed power run passes load test; no exposed conductor/water line <1.4 m without tool access.*
- P1: Quick-connect utility umbilical (one floor connection).
- P2: Sensor/AV module type (screen or projector mount) for classrooms.
**Metrics.** Hub-type mix tracked at order; pilot photo-share rate (the hub is the marketing object).
**Open questions.** Stakeholder: which two hub types launch (packet decision)? Legal: plumbing code review for Ice hub by state.

### PRD-04 · Transition Pieces (TC/RC/EC/LB family)
**Problem.** Docked tables of different heights create steps, seams, and finger gaps; without engineered transitions the system looks assembled and is unsafe.
**Goals.** Every height change bridged by a correct-delta cap; arrangement reads as one flowing surface; zero entrapment gaps.
**Non-Goals.** Walkable/loadable ramps (caps are surface flow, not stairs); universal one-size cap (delta classes exist for physics reasons).
**Stories.** As a parent, I want no gap a child's finger fits into where tables meet. As a designer, I want contrast-banded caps so the height changes are legible to low-vision users.
**Requirements.**
- P0: Delta classes per Rev F rules (300/450 mm ramps, stepped >240 mm); B12 gap/step limits; ≥10° caps carry no-set-down ridge + contrast band; tool-only removal; EC required on any open dock face. *AC: gauge test — no gap 8–25 mm anywhere along a seated cap; cap lift force without tool >250 N.*
- P1: Colorway-matched and contrast-band options in configurator.
- P2: Integrated cable pass-through caps for Service-hub arrangements.
**Metrics.** Zero entrapment findings in pilot safety audit; cap misfit returns <1%.
**Open questions.** Engineering: compression vs. injection molding crossover volume? (feeds make/buy matrix).

### PRD-05 · Splicing System (docking) (B12 subsystem)
**Problem.** The entire architecture rests on tables joining rigidly, safely, and repeatedly without skilled labor.
**Goals.** <2 min per joint, tool-release only, 500+ cycles without degradation, docked arrangement stiffer than any single table.
**Non-Goals.** Powered/auto docking (v3 fantasy); cross-brand compatibility.
**Stories.** As a facilities tech, I want one release key for every joint in the building so reconfiguration is a one-person job.
**Requirements.**
- P0: Latched joint meeting B12 (zero entrapment, ≤1 mm step, no relative movement at 350 N); universal key; blind-mate alignment (self-guiding ±5 mm). *AC: 500-cycle test retains spec; misdock impossible test (wrong-height joint refuses latch without correct cap).*
- P1: Latch-state indicator (visual flag when not fully seated).
- P2: Smart latch (sensed state to digital twin).
**Metrics.** Dock cycle time; latch failure rate <0.1%/yr; zero pinch incidents.
**Open questions.** Engineering: license an existing industrial latch vs. custom? Blocking for Phase 0 BOM.

### PRD-06 · Trough Segments & Insert System
**Problem.** The monolith's continuous trough is gone; per-table segments must still deliver the swappable mode layer (social/dining/activity).
**Goals.** Segments align across docked same-height runs; inserts interchange across all tables of a class; wet functions live only in F-Hub.
**Non-Goals.** Cross-table continuous liquids (physics + safety); powered inserts (power is hub-only).
**Requirements.**
- P0: Segment rebate standard across L-tables; insert families (caddy, planter, blank lid, activity bin) fit every segment of their class; lids flush ≤0.5 mm. *AC: any insert seats in any same-class segment first try.*
- P1: Seasonal insert packs (merchandising).
- P2: Third-party insert spec (open a marketplace later — design the rebate as a published interface).
**Metrics.** Insert attach rate per order (target ≥2 packs); reorder rate.
**Open questions.** Design: publish rebate spec at launch or hold proprietary two years?

### PRD-07 · Base, Mast & Structure
**Problem.** Per-table stability (B3) and hub services (B11) now carry the whole safety case; bar heights are the worst case.
**Goals.** Every table passes undocked anti-tip; hub mast routes services; flat-pack ships in standard classes.
**Non-Goals.** Floor anchoring as default (rental/reconfig markets forbid it) — offered as option only.
**Requirements.**
- P0: B1–B4, B6, B10 per table; B11 mast in F-Hub; knock-down base with numbered, tool-minimal assembly. *AC: assembly by one untrained person <20 min/table with printed+QR instructions.*
- P1: Ballast options (sand/steel) by venue class.
- P2: Recycled low-carbon steel line as default when supply qualifies.
**Metrics.** Assembly time and error rate at pilots; freight class achieved per table.
**Open questions.** Engineering: shared foot casting across all heights vs. two sizes (cost fork).

### PRD-08 · Colorway System
**Problem.** Institutions need brand fit and wayfinding; color must add zero structural variance.
**Goals.** Cloud/Grove/Citrus/Slate + Custom; per-table colorway selection; height-legibility option (color = height, a wayfinding feature unique to Ribbon Segment architecture (Level-as-Ribbon)).
**Non-Goals.** Non-thermoformable palettes; per-unit custom without surcharge/minimums.
**Requirements.**
- P0: All four launch colorways available on every part incl. caps; contrast band standard on ≥10° caps. *AC: colorway swap = zero CAM change beyond material/finish codes.*
- P1: "Height-coded" preset (each level a fixed hue) for schools.
- P2: Institutional color-matching service.
**Metrics.** Colorway mix; % orders using height-coded preset.
**Open questions.** Design: is height-coding a safety win (legibility) worth making default in education? Pilot A/B.

### PRD-09 · Configurator & Digital Thread
**Problem.** Mass customization only works if the order file drives fabrication and every unit is traceable.
**Goals.** Order → parametric file → CAM at any node with zero manual CAD; per-table digital twin; arrangement-level BOM auto-generated (tables + caps + hub + inserts).
**Non-Goals.** Public 3D room-planner at launch (P1); e-commerce checkout for institutions (quote flow first).
**Requirements.**
- P0: Configurator sequence shape → hub type → table set → variant/fold-legs → colorway → inserts; auto cap-count and EC insertion (an invalid arrangement cannot be ordered); serialized twin per part. *AC: 100 random configs → 100 valid BOMs, zero manual fixes.*
- P1: Room-fit visualizer; dealer/GPO quote export.
- P2: Twin-fed service history and takeback valuation.
**Metrics.** Config-to-quote time <10 min; BOM error rate zero; node CAM acceptance without edits ≥98%.
**Open questions.** Engineering: build on existing CPQ vs. custom (blocking for seed scope).


### PRD-14 · AEL Family (optional seating)
**Problem.** Venues want optional seating moments without refuting the chair-free thesis; unmanaged third-party stools would block bays, mismatch heights, and break safety discipline.
**Goals.** Level-matched optional seating for every height band; zero interference with knee-clear bays; second attach-revenue line after inserts.
**Non-Goals.** Required seating in any arrangement (the table stays complete empty); seating at the Knot (never); task chairs/office seating (different product).
**Stories.** As a librarian, I want wobble perches at the child ribbons so kids can move while they read. As a wheelchair user, I want the 740 bay always clear so I never have to move someone's stool to sit at my own table.
**Requirements.**
- P0: Family per the ratified concept — floor cushions + wobble perches (L560–L680), drop-in low-back perch (740 bays, slides fully under, printed "this seat yields"), leaning perch (950), tall wide-base perch stool (1050–1100), nothing at the Knot; every unit nests under its own ribbon; B-series safety per unit (anti-tip, child-safe edges, no pinch points); bays never blocked or used for storage. *AC: arrangement passes full B-series with all AEL units deployed AND with zero units; bay-approach test passes with drop-in perch nested.*
- P1: Colorway-matched and height-coded AEL packs per level; venue bundles (education pack, hospitality pack).
- P2: Outdoor-rated AEL line (follows any outdoor table line, not before).
**Metrics.** AEL attach rate per order (target ≥1 pack); bay-yield compliance in pilots (zero blocked-bay observations); zero AEL tip incidents.
**Open questions.** Design: wobble-perch base geometry for L560 users (tip vs. movement trade) — resolve in Phase 1 pilot. Ops: make vs. buy for stool hardware (mirror the latch hybrid logic).

---

## STRATEGIC PRDs

### PRD-10 · Product Roadmap (strategy as a product)
**Problem.** Ribbon Segment architecture (Level-as-Ribbon) resets sequencing; without a ratified roadmap, engineering, sales, and supply chain will optimize different futures.
**Goals.** One committed sequence: Phase 0 docked-Racetrack prototype (+undock trials) → Phase 1 pilots (incl. one Hex cluster, one Fold-leg set) → Phase 2 production + configurator GA → Phase 3 scale; Ring enters at Phase 2+.
**Non-Goals.** Parallel monolith line (Rev E replaces it — packet decision closed unless reopened); international before national mesh.
**Requirements.** P0: stage-gate criteria per phase (Phase 0 exits on B3/B12/B13 pass + 14-user ergonomic validation; Phase 1 exits on pilot metrics + validated unit cost; Phase 2 exits on 98% CAM acceptance + margin ≥40%). P1: quarterly roadmap review cadence. P2: platform derivatives (desks? benches?) parked.
**Metrics.** Gate slippage <1 quarter each; % scope added post-gate (target ~0 — scope law: additions require removals).
**Open questions.** Stakeholder: ratify monolith retirement formally.

### PRD-11 · Manufacturing Sequence (the build as a product)
**Problem.** Ribbon Segment architecture (Level-as-Ribbon) re-orders what gets tooled when; wrong sequencing burns seed capital on molds the architecture no longer needs.
**Goals.** Tool in value order: (1) docking latch + chassis jigs, (2) transition-cap molds (highest-count SKU), (3) flat-top cutting programs (no molds), (4) F-Hub mast weldment, (5) simple-curve tops last.
**Non-Goals.** LFAM in the critical path (its case weakened; keep as Phase 3 upside); Ring tooling before Phase 2.
**Requirements.** P0: DFMA review before any tool cut; every part carries make/buy/print tag per volume (matrix maintained); QA gates at each node keyed to B-series. *AC: no tooling PO without a signed DFMA + volume forecast.* P1: dual-source every mold. P2: robotic dock-hardware assembly cell at scale.
**Metrics.** Tooling $ per shipped table (declining each phase); first-pass yield ≥95% by Phase 2.
**Open questions.** Engineering: cap molds compression vs. injection (with PRD-04).

### PRD-12 · Supply Network (centralize/distribute as a product)
**Problem.** Rev E's freight collapse strengthens centralization; the network design must be re-decided on the new physics, not the old.
**Goals.** Re-run the crossover model with Rev E inputs; likely outcome: **one central plant + regional final-assembly/QA partners** replaces full microfactories for longer; keep the distributed option as a real Phase 3 branch, not a commitment.
**Non-Goals.** Committing microfactory licenses before Rev E crossover data; overseas manufacture before national demand proof.
**Requirements.** P0: updated model run with quoted freight (stackable classes) and docking-labor adders before any node decision; supplier shortlist re-scored for flat-top + latch + cap competence. P1: parts-hub RFQ (Midwest) in Phase 1. P2: continental replication playbook.
**Metrics.** Landed cost per arrangement; node decision reversals (target zero — decide on data once).
**Open questions.** Data: real LTL quotes for stacked L-tables (blocking for the model re-run).

### PRD-13 · GTM & Pilot Program (learning as a product)
**Problem.** Pilots must now validate a *system* (docking, caps, growth-over-time) not just a table — and produce the evidence that closes institutional sales.
**Goals.** 3–5 SoCal pilots incl. one education **Hex cluster** and one grow-from-three-tables site; instrumented protocol incl. dock cycles, seam wear, cap safety gauge audits, focal-type preference; every pilot yields a reference + a validation report.
**Non-Goals.** Paid pilots (friction kills speed — subsidized in exchange for data/reference); consumer/residential channel.
**Requirements.** P0: pilot MOU template (observation rights, reference rights, safety reporting); protocol per validation packet + Rev E additions; monthly data pull into the twin. *AC: each pilot produces the report deck section within 2 weeks of close.* P1: architect/designer preview event per metro. P2: GPO listing post-BIFMA.
**Metrics.** Pilot→paid conversion ≥60%; reference use in ≥80% of subsequent proposals; zero safety incidents.
**Open questions.** Stakeholder: first outreach wave order (packet email ready — send is yours).

---
*Every PRD inherits the shared constraints: B-series spec compliance, child-safety-first, accessibility as core function, illustrative economics until quotes land. PRDs are living documents — revise at each stage gate (PRD-10).*
