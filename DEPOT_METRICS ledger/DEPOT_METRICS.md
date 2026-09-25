# Depot metrics — the ledger

*Opened 2026-09-10. **Measure before improving.** One sheet for every number the depot thesis turns on, with each metric defined precisely enough that two entries taken a month apart are comparable.*

**Status of each instrument is stated, because most are not measurable yet and pretending otherwise is how a plan gets built on a guess.**

| Metric | Status | Gate |
|---|---|---|
| Net per hour driven | **live once Checkr clears** | background check, 3–10 business days |
| kWh per revenue mile | **live once driving** | same |
| Charging cost, home vs public | **partially live now** — the public rate is knowable today | home rate needs the property |
| Turnaround minutes | blocked | needs the property |
| Charging-position dwell | blocked | needs the property |
| Curb-to-room minutes | blocked | needs the property **and** a licence |
| Semi charging feasibility | blocked | **utility service study.** Not a measurement — a question for the utility |

---

## 1 · Rideshare week one — the first real numbers

*One row per shift. Nothing here is an estimate; if a cell is unknown, leave it blank rather than filling it.*

**Definitions.** *Revenue miles* = miles with a fare aboard. *Deadhead* = miles without. *Net* = gross earnings minus charging, minus a per-mile wear reserve you set once and do not change mid-week.

| Date | Hours online | Total miles | Revenue miles | Gross $ | kWh used | Charge $ | Net $ | Net / hour |
|---|---|---|---|---|---|---|---|---|
| | | | | | | | | |
| | | | | | | | | |
| | | | | | | | | |
| | | | | | | | | |
| | | | | | | | | |
| | | | | | | | | |
| | | | | | | | | |
| **Week 1** | | | | | | | | |

**The question this answers:** does an hour of driving clear enough, after energy and wear, to be worth the hour? Nothing else on this sheet matters until it does.

---

## 2 · Energy — the number the depot thesis rests on

| | Public / supercharger | Home, off-peak | Home, on-peak |
|---|---|---|---|
| $ per kWh | | | |
| kWh per revenue mile | | | |
| **$ per revenue mile** | | | |

**The public column is fillable today.** The home columns need the property. **The spread between them is the entire depot argument** — if it is small, home base is a convenience rather than a business case.

---

## 3 · Turnaround — the depot's real metric

*Not miles driven. Minutes from a vehicle stopping to it moving again with the next payload aboard.*

| Date | Arrive | Plugged in | Payload staged | Depart | **Turnaround min** | Notes |
|---|---|---|---|---|---|---|
| | | | | | | |
| | | | | | | |
| | | | | | | |

**Charging-position dwell** — hours a vehicle occupies a position while not charging. A position blocked by a full vehicle is a position that is not a depot.

| Vehicle | Position occupied | Charging complete | Vehicle moved | **Idle-blocked hrs** |
|---|---|---|---|---|
| | | | | |

---

## 4 · Curb to room — the arrival number

*Minutes from a person arriving at the curb to being in their room. **This is a care measurement wearing a stopwatch.*** Every minute of it is spent by someone at the worst moment of their life, in a hallway, in front of strangers.

| Date | Curb | Inside | Intake done | In room | **Curb-to-room min** | Path discreet? |
|---|---|---|---|---|---|---|
| | | | | | | |
| | | | | | | |

**Departure, measured the same way and for the opposite reason.** Leaving should be unhurried and visible — the one arrival on this campus that should be slow.

| Date | Notice given | Belongings out | Left | Returned as alumni? |
|---|---|---|---|---|
| | | | | |

---

## 5 · Semi charging — a question, not a measurement

Megawatt-class charging is not a residential service. Before this is planned around, someone at the utility must answer:

- ☐ What service currently reaches the property — amperage, phase, transformer rating?
- ☐ What would a dedicated 100 kW circuit require, and at what cost?
- ☐ Is a transformer upgrade needed, who pays, and what is the lead time?
- ☐ What are the demand charges on a commercial rate at that draw?

**Unverified and potentially prohibitive.** Until these are answered, `04_Tesla_Semi` has no home-base assumption in it.

---
*Spans `03`, `04`, `07`, `08`, `09`. Parent index: `00_MIND/zones/MIND_Zone_V.md`.*
© 2026 Erik Daniel Lindquist. Zone V.
