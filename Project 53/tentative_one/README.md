# Tentative One

A Phoenix LiveView app that moves on **1** unless told otherwise.

Paste steps, one per line. Each step runs on its own as a **tentative 1**.
Only an inflection point stops a step: deleting, sending, money, regulated
data, an email address, or a password. Then one key decides:
**1 clears it · 0 skips it**. A 0 skips only that step, and the rest still runs.
A 0 while the run is moving stops the whole run.
Anything you type in the box is you telling it otherwise, and it becomes the next step.
**West** counts every keystroke you had to spend.

| Part | File |
|---|---|
| The gate: which steps are 0s | `lib/tentative_one/gate.ex` |
| The run: tick, hold, 1, 0, otherwise | `lib/tentative_one/run.ex` |
| The page | `lib/tentative_one_web/live/run_live.ex` |

## Specs: 399

| Suite | Specs | Ran |
|---|---|---|
| `gate_test` + `gate_corpus_test`: 125 zeros, 67 ones | 200 | green |
| `run_test`: core behavior | 10 | green |
| `run_matrix_test`: 4 states × 10 inputs, 6 reasons × 3 | 59 | green |
| `run_property_test`: 100 seeded random runs, 7 laws checked after every move | 100 | green |
| `run_live_test`: LiveView | 50 | **written, not yet run** |

The core 349 run with plain Elixir: `elixir test/run_core.exs`.
The full 399 run with `mix test` once deps can be fetched.
