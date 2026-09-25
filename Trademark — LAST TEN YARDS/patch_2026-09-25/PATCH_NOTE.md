# Last Ten Yards — fixes, 2026-09-25

Made and tested on a box copy of `Trademark — LAST TEN YARDS/web` (Elixir 1.18.3 / OTP 27, PostgreSQL 17.11, Phoenix 1.7.24).
Nothing on the Mac was changed. The patch has **not** been applied anywhere on the Mac.

## Files here
- `LTY_fixes_2026-09-25.patch`: unified diff (`diff -ruN web_orig web`). Apply from inside `web/`: `patch -p1 < ../patch_2026-09-25/LTY_fixes_2026-09-25.patch`
- `favicon.ico`: binary, so the diff can't carry it (it only notes "Binary files differ"). Copy it to `web/priv/static/favicon.ico`. sha256 98e3541d0fff3ca8c0d878737e8f0a61ee2e5583d2d46bb385e0ad3496e076a7
- `store_thanks_no_session.png`, `store_thanks_with_session.png`: the two states of /store/thanks after the fix

## What changed and why (tests written first, seen failing, then fixed)
1. **priv/posts.test.js**: this was an old copy of the first 82 lines of `posts.test.js` and needed a `./posts.js` that was never in `priv/`, so it crashed. It's now a one-line redirect, `require('../posts.test.js')`, so both node files run the same 162 specs. No file was deleted.
2. **Favicon**: new `priv/static/favicon.ico` (a plain gold dot on the site's dark background, 16 and 32 px, no logos). `<link rel="icon" href="/favicon.ico">` added to the head of all 5 templates. There's no shared root layout because each page is a full HTML document. `/favicon.ico` now returns 200; it returned 404 before. Tests: favicon is served, and each page links it.
3. **README.md**: "all 24 lines loaded" is now "all 63 lines loaded". New test: every "N lines" count in the README must equal the number of rows in `priv/lines.json`.
4. **/store/thanks**: says "Your order is in." only when `session_id` looks like a Stripe checkout session id (`cs_…`). Otherwise it says "No order found." Both versions keep the back link, and the id is never displayed. To make real checkouts land on the right version, `Checkout.params/2` now sends buyers back to `/store/thanks?session_id={CHECKOUT_SESSION_ID}`; it used `?session=`, which the new check would ignore. `checkout_test.exs` was updated to match. Orders are still recorded only by the signed webhook. Tests cover: with an id; with no id; with an empty id, a non-Stripe id, or the old `session=` parameter.
5. **mix.lock**: the lock file generated on the box is included, pinning phoenix 1.7.24, phoenix_live_view 1.2.12, ecto 3.14.2, ecto_sql 3.14.0, bandit 1.12.5, postgrex 0.22.4, req 0.7.4 and floki 0.38.4.
6. **Server bind**: `config/config.exs` binds dev and test to 127.0.0.1; it was 0.0.0.0. Production is unchanged: `config/runtime.exs` still binds 0.0.0.0 under `if config_env() == :prod`, so Heroku works as before. New `test/last_ten_yards_web/bind_test.exs` checks both.

## Test counts after the fix (box, real Postgres)
| Suite | Before | After |
|---|---|---|
| `mix test` | 94 tests, 0 failures | **105 tests, 0 failures** (11 new) |
| `elixir test/run_core.exs` | 70 / 0 | **70 / 0** (one assertion changed to `session_id`) |
| `node posts.test.js` | 162 pass / 0 fail | **162 / 0** |
| `node priv/posts.test.js` | crashed (MODULE_NOT_FOUND) | **162 / 0** |
| SQL checks (`structure.sql` + `test/sql/schema_check.sql`) | 20 PASS | **20 PASS, 0 FAIL** |

## Not changed (flagged)
- `README.pdf` still says "24 lines", because it is a separate generated file. Regenerate it from README.md if you keep it.
- README still names Phoenix 1.7.14, Ecto 3.12 and Postgres 16. With this mix.lock the app runs Phoenix 1.7.24 and Ecto 3.14, and it was tested on Postgres 17.
- If you run `node --test` inside `web/`, it finds both spec files and runs the 162 specs twice. They all pass.
