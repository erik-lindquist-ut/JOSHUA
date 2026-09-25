# RIBBON — Design Addendum: Base Requirements · Colorways · Fold-Out
### Rev C companion to the build spec and business plan

---

## 1 · Base requirements (formalized)

The structural base is now specified as numbered requirements a fabricator can be held to.

| # | Requirement | Value / rule |
|---|---|---|
| B1 | Structure | Single central steel spine (200 × 100 × 6 mm RHS equivalent), top cantilevered; **no leg, apron, or brace in any knee-clear bay** |
| B2 | Feet | Two weighted pedestals under the standing zones; base plates ≥700 × 700 × 12 mm with internal ballast |
| B3 | Anti-tip | Withstand a **350 N horizontal pull** at any top edge and a 100 kg point load on the edge (child sitting/climbing) without tipping |
| B4 | Load | ≥150 kg/m² distributed; deflection ≤3 mm at any cantilevered end under load |
| B5 | Knee clearance | Four bays: surface 740 mm, **≥685 mm clear underside**, ≥480 mm depth, ≥760 mm width — preserved in every configuration and fold state |
| B6 | Leveling | M16 adjustable glides; level on floors up to 10 mm out of plane |
| B7 | Footrail | 42 mm 304-stainless tube at the tall zones, 200 mm above floor |
| B8 | Safety | No pinch points, no exposed fasteners in child reach, all corners R20+ bullnose |
| B9 | Finish | Powder-coat (colorway-selectable, see §2), low-VOC, BIFMA-relevant durability |
| B10 | Serviceability | Base disassembles with standard tools for flat-pack shipping; every part serialized to the unit's digital twin |

These become acceptance criteria in fabricator contracts and the QA gates in the digital thread.

## 2 · Colorway system

Color becomes a **configurator dimension** alongside height mix and inserts — three coordinated layers per colorway: top (solid surface), base (powder-coat), and accents (trough inserts, footrail, well tubs).

**Launch colorways (working names)**
| Colorway | Top | Base | Accents | Aimed at |
|---|---|---|---|---|
| **Cloud** | Warm white | Deep navy | Teal | Flagship / civic |
| **Grove** | Soft sage | Charcoal | Natural oak lids | Museums, libraries |
| **Citrus** | Pale sand | White | Coral + amber wells | Children's / education |
| **Slate** | Mid grey | Black | Stainless | Coworking / hospitality |
| **Custom** | Per spec | RAL any | Per spec | Institutional branding (premium) |

**Engineering constraints (real, from solid-surface fabrication practice):**
- Not all solid-surface colors thermoform — large-particulate/chip lines are excluded; the palette is drawn from **thermoformable** solid-surface ranges only, validated per brand (Corian / HI-MACS / Staron guides).
- Light, low-pattern colors hide seams and repairs best — the launch palette biases that way; dark tops are offered with a documented care note.
- Powder-coat = any RAL at no premium; **custom top colors** carry a surcharge and minimum-order because they break sheet-purchasing economies.
- Colorways change **nothing structural** — same molds/toolpaths, so SKUs multiply at near-zero manufacturing cost. Accent parts (lids, tubs) are the cheap variety layer.

## 3 · Fold-out functionality

**Design intent:** fold for **shipping, storage, and reconfiguration** — not a daily one-person fold. The table is ~150+ kg; the win is freight volume, doorway access, and venues that must clear the floor seasonally.

**Mechanism — fold at the module joints (tri-fold):**
- The top already decomposes into height modules + two end caps (Phase 2 architecture). The fold-out version places **two engineered hinge lines at module joints** on the straight runs, splitting the table into a center section + two folding wings.
- Hinge lines fall at **flat plateau points of the wave** (never mid-curve), with a machined stainless piano-hinge spine below the surface and a compression-lock latch; the visible joint is a tight seam, not the seamless monolith.
- The **central trough splits** with the fold: the stainless liner is made in three gasketed segments; inserts span only within a segment.
- Folded envelope: ≈ **1.5 × 1.2 m footprint** (wings vertical) — through a standard double door, and cuts LTL freight class/volume meaningfully.
- **Safety:** gas-strut damping on the wings, positive lock engaged/disengaged with a tool (child-safe — B8 applies), no finger gaps >8 mm at the hinge line in any state, and knee-clear bays (B5) preserved when deployed.

**Honest trade-offs — offered as a variant, not the default:**
- Two visible seams interrupt the seamless top (the flagship's signature); seam quality becomes a QA gate.
- ~+$400–700 unit cost (hinges, locks, segmented liner, added QA) at pilot volumes.
- Slightly reduced edge stiffness at the hinge line — B4 deflection must be re-verified per unit.
- **Product line:** *RIBBON One* (seamless flagship) and *RIBBON Fold* (tri-fold variant). Fold is expected to win in schools, event spaces, and multi-use civic rooms; One in permanent installations.

## 4 · Ripple effects across the project

- **Build spec:** base section restated as B1–B10; colorway + Fold variant sections appended.
- **Configurator:** two new dimensions (colorway; One/Fold) → still one parametric file per order.
- **Crossover model:** Fold cuts the freight input (smaller shipped volume) and adds ~$400–700 unit cost — in freight-dominated regions Fold *improves* the centralized case and slightly delays the open-a-node break-even; test both in the model's yellow cells.
- **Roadmap:** Fold prototypes in **Phase 1 (pilot)** — at least one pilot site gets a Fold unit; colorways launch with the configurator MVP; custom colorway unlocks at Phase 2.
- **Pilot protocol additions:** fold/unfold cycle count and time, latch/pinch audit, seam wear at the hinge line, and colorway preference intercepts.
- **Business plan:** product section now carries the two-variant line and colorway system; Rev C.

---
## 5 · Rev E — Ribbon Segment architecture (Level-as-Ribbon) architecture (every level becomes a table)

**The pivot:** RIBBON is no longer one monolithic multi-height surface. **Each height level is now its own discrete table** — a self-supporting unit with its own top, base, and requirements — and the product is the *system*: ribbon segments **dock edge-to-edge** to form the Racetrack, Ring, or Hex profiles (or any custom arrangement), and undock to stand alone.

### The ribbon segment family
| Unit | Height | Role | Notes |
|---|---|---|---|
| L560 | 560 mm | Toddler table | Lowest anti-tip risk |
| L650 / L680 | 650–680 mm | Child tables | |
| L740-A | 740 mm | **Accessible table** | Knee-clear per B5 on all open sides |
| L780 / L820 | 780–820 mm | Tween tables | |
| L950 | 950 mm | Counter table | Footrail integral |
| L1050 / L1100 | 1050–1100 mm | Bar tables | Widest base plate (tall + narrow = hardest anti-tip) |
| **F-Hub** | varies | **Fixed focal section as its own hub table** | Planted / Service / Ice / Solid; services rise in its own mast |

A Racetrack arrangement ≈ 8–10 ribbon segments + 1 F-Hub; Hex ≈ 6 + hub; Ring ≈ 8 wedge-ribbons + hub. Ramped **transition caps** bridge adjacent tops so the docked profile still reads as one flowing surface.

### What this wins
- **Manufacturing collapses in complexity:** flat or simply-curved tops per table — thermoform molds shrink or vanish; several levels need no mold at all. The make/buy/print matrix simplifies a full phase early.
- **Freight becomes trivial:** individual tables stack and ship standard LTL; the fold-out variant's *raison d'être* (shipping envelope) is largely absorbed — **RIBBON Fold narrows to fold-leg options on individual ribbon segments**.
- **Crossover economics shift:** with freight per arrangement dropping sharply, the **centralized case strengthens** and the open-a-node break-even rises — re-test in the model (freight cells down, per-unit assembly/docking labor up slightly).
- **Sales flexibility:** venues can start with three tables and grow to a full arrangement; damaged or outgrown levels replace one table at a time; every level is separately rentable/reconfigurable.

### What this costs (honest)
- **The seamless wave dies.** The signature continuous surface becomes a docked, stepped profile with managed seams at every junction. Transition caps soften but do not hide this.
- **Docking is now a safety-critical subsystem:** inter-table latches must produce **zero finger-entrapment gaps (≤8 mm or ≥25 mm, never between)**, no relative movement in normal use, and tool-release only (child-safe).
- **Anti-tip is per-table, not per-system:** B3's 350 N test now applies to *each undocked unit* — hardest for the tall bar tables, which drive base-plate size.
- **The central trough fragments:** it survives as per-table trough segments that align when docked; continuous ice/water runs are no longer possible across tables — wet functions consolidate into the F-Hub.

### Spec impact
- **B12 (new): docking** — latched, tool-release, zero entrapment gaps, ≤1 mm top misalignment at seams, arrangement stability ≥ single-table stability.
- **B3 revised:** anti-tip verified per segment, unspliced, worst case (bar heights).
- **B11 (focal):** the F-Hub *is* the fixed focal section — unchanged in role, now self-contained.
- Colorways apply per-table (mixed-colorway arrangements now possible — flag as a configurator option and a merchandising win).

### Roadmap impact
Phase 0 prototype becomes **one full docked Racetrack arrangement + undock/redock trials**; the pilot protocol adds docking-cycle, seam-wear, and misalignment checks; Phase 3's LFAM case weakens (fewer complex tops) while robotic assembly/QA of docking hardware strengthens.

---
## 6 · Rev F — Transition pieces (the connective tissue of Ribbon Segment architecture (Level-as-Ribbon))

Transition pieces are now first-class parts: they bridge adjacent ribbon segments so a docked arrangement reads as one flowing system, and they close the safety gaps docking creates.

### The family
| Part | Code | Function |
|---|---|---|
| **Straight ramp cap** | TC-Δxxx-S | Bridges two spliced segments of height delta Δ (e.g., TC-Δ090-S bridges 90 mm). Locks into both tables' B12 latches, covers the seam. |
| **Corner ramp cap** | TC-Δxxx-C60 / C90 | Same, turning 60° (Hex corners) or 90° (custom layouts). |
| **Ring wedge cap** | RC-Δxxx | Curved transition for Ring wedge-ribbons. |
| **End cap** | EC-hhh | Finishes an exposed dock face at height hhh with a bullnosed terminus (open-ended and growing arrangements). |
| **Level bridge** | LB-hhh | Zero-delta seam cover joining two same-height tables into one continuous run. |

### Engineering rules (honest physics)
- **Delta classes:** Δ ≤ 120 mm → 300 mm ramp; Δ 121–240 mm → 450 mm ramp; Δ > 240 mm → **stepped cap** (two mini-plateaus), because a single ramp would exceed ~28° and anything set on it slides.
- **No-set-down zone:** any cap steeper than 10° carries a molded ridge texture and contrast band — a visual/tactile "don't park your drink here" cue (and a cane-detectable edge).
- **Safety integration:** caps span the inter-table seam with zero entrapment gaps (B12), add ≤1 mm surface step, and cannot be lifted without tool release (child-safe).
- **Material:** same solid-surface family as tops, colorway-matched or deliberately contrast-banded (configurator choice); underside GF-nylon chassis with the latch interface.
- **Count per arrangement:** Racetrack ≈ 8–10 caps + 0–2 ECs; Hex ≈ 6 corner caps; Ring ≈ 8 RCs. Caps are the highest-count SKU in the system — tooled early, injection/compression molded at volume.

**Spec impact — B13 (new): transition pieces.** Every docked height change carries a cap of the correct delta class; caps meet B12 gap/step limits; ≥10° caps carry the no-set-down treatment; caps removable only by tool; arrangement is non-compliant if any dock face is left open without an EC.
