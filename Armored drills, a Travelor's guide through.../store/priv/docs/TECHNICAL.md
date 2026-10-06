# Technical documentation — Fail Fast Compendium ↔ Phoenix LiveView / Elixir store

**Audience:** World-class Ruby/Rails developers bridging into (or reviewing) the Phoenix/Elixir stack.  
**Not for:** Provost / Principal Technologist acceptance meeting — see `README.md`.

---

## Mental model (Rails → Elixir)

| Rails | This stack |
|---|---|
| Rails app | Phoenix 1.7 + Bandit |
| Action Controller | `ArmoredStoreWeb.StoreController` (HTML) |
| LiveView (Hotwire-ish) | `phoenix_live_view ~> 1.0` available; store UI today is classic controllers + HEEx |
| ActiveRecord | Ecto + Postgrex (`ArmoredStore.Repo`) |
| `config/routes.rb` | `lib/armored_store_web/router.ex` |
| `db/seeds.rb` | `priv/repo/seeds.exs` → `Catalog.seed_store/2` |
| Stripe Checkout + webhooks | `ArmoredStore.Checkout` + `POST /stripe/webhook` |
| Asset pipeline | Static CSS under `priv/static`; HEEx templates |
| Heroku | `Procfile` + `elixir_buildpack.config` + `config/runtime.exs` |

App name: **`armored_store`**. Dev: Postgres DBs `armored_store_dev` / `_test`, port **4001**.

```bash
cd "…/Armored drills, a Travelor's guide through.../store"
mix setup          # deps.get, ecto.create, migrate, seeds
mix test
mix phx.server     # http://localhost:4001/
```

Env: `PGUSER` / `PGPASSWORD` / `PGHOST` (defaults postgres/postgres/localhost). Checkout: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`.

---

## Where the Compendium sits in the product graph

```
Course Mastery Coach Framework   (method canon — domain-free)
        │
        ▼
_build/build_compendium.py       (PDF + DOCX generator)
  ├── items_a.py / items_b.py    (81-item armored drill source)
  └── pa_anchor.json             (PA concept · rule · trap · tell)
        │
        ├──► Armored_Accounting_for_Decision_Making.pdf / .docx   ← WGU handoff
        │
        └──► store (Phoenix)
               ├── priv/STORE_ADDITIONS.json   # title #7, unpriced
               ├── priv/PREVIEWS.json          # Introduction excerpt
               ├── priv/KDP_LISTINGS.json      # priced titles #1–6
               └── Catalog.seed_store/2
```

- Compendium is store addition **#7**: listed, previewable, **no buy button** until a priced KDP listing exists (`price_usd` on additions is ignored).
- Paid PDF/DOCX are **not** served by the app (404); exception: the WGU Fail Fast Compendium handoff PDF under `priv/static/handoff/` (`paid_files_test.exs` allows only that labeled path).

---

## Compendium build pipeline (Python)

Path: `Armored Accounting for Decision Making - The Fail Fast Compendium (book, V1)/_build/`

| File | Role |
|---|---|
| `build_compendium.py` | reportlab PDF + python-docx; five sections |
| `items_a.py` / `items_b.py` | Item bank; fixed seed → key balance A20 · B24 · C27 · D27 |
| `pa_anchor.json` | Pre-assessment anchor rows |

```bash
python3 _build/build_compendium.py <out_dir>
# needs: reportlab, python-docx, Pillow, pypdf, DejaVu Sans (DEJAVU_DIR)
```

Preview extract for the store:

```bash
cd store && python3 tools/extract_previews.py   # → priv/PREVIEWS.json from each .docx
```

---

## Phoenix store — modules Rails people care about

| Module | Responsibility |
|---|---|
| `ArmoredStore.Catalog` | Products + paid orders; collections (`Originals`, `Armored Fail Fast`, school shelves) |
| `ArmoredStore.Listings` | Parse KDP JSON + store additions |
| `ArmoredStore.Checkout` | Stripe Checkout Session; HTTP client injected (tests never hit Stripe) |
| `ArmoredStore.StripeWebhook` | Idempotent `record_paid` on `stripe_session_id` |
| `ArmoredStore.Programs` / `Bundles` / `Examples` | Program shelves, bundles, example pages |
| `ArmoredStoreWeb.Router` | Browser + webhook pipelines; catch-all 404 |

Routes (browser): `/`, `/books`, `/books/:slug`, `/books/:slug/files`, `/books/:slug/example`, `/docs/readme`, `/docs/technical`, `/schools/:school`, `/programs/:slug`, `POST /checkout/:slug`, `/thanks`. Handoff PDF: `/handoff/Armored_Accounting_for_Decision_Making_Fail_Fast_Compendium.pdf`.  
Webhook: `POST /stripe/webhook`.

---

## Related Phoenix LiveView app (control plane, not the store)

**Tentative One** (`Tentative One — Phoenix-LiveView app + specs/tentative_one/`): LiveView run that advances on **1** unless stopped; gates irreversible steps (delete, send, money, regulated data, email, password). Specs: 399 (gate, run matrix, property, LiveView). Core 349 via `elixir test/run_core.exs`.

This is the operational “binary gate” sibling to Fail Fast’s educational method—not required for the Provost packet.

---

## Last Ten Yards web store

Separate Phoenix app (register A6). Pointers only in JOSHUA; vault originals under `50_Ribbon/11_Last_Ten_Yards/`. Not part of this handoff folder.

---

## Acceptance checks for engineers

- [ ] `mix test` green in `store/`
- [ ] Compendium appears on home / books with “Price not set”
- [ ] Preview `#preview` matches Introduction in the `.docx`
- [ ] Paid book PDF/DOCX remain unsaved under HTTP; only `priv/static/handoff/` Fail Fast Compendium PDF is viewable
- [ ] Rebuild PDF with same seed reproduces answer key counts

