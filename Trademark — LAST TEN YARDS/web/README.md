# Last Ten Yards — website + store (Phoenix)

Mobile-first. `/` shows the 15 posts. `/store` is the store; **Buy** sends the buyer to a Stripe-hosted checkout page, so card numbers never touch this app.

| Piece | Where |
|---|---|
| Posts, renderer, theme | `priv/static/assets/` |
| Business lines | **63 lines**, one row each in `priv/lines.json`, each citing where the record names it: the 13 line folders, the business marks in the IP register, the pinboard, the forest plan and the sky-layer steps. Each line gets its own storefront at `/l/<slug>`; the directory is `/lines`. **Adding a line is one row — no code.** |
| Database | **Postgres** via Ecto: `business_lines`, `products` (each on a line) and `orders` tables (`priv/repo/migrations/`). Orders are made only by a signed Stripe webhook. No card data and no buyer contact data are stored — Stripe keeps those |
| Products for sale | Live in the `products` table. `priv/products.json` (empty on purpose) seeds it: `mix run priv/repo/seeds.exs`. Each item: `id`, `name`, `blurb`, `cents`, `stripe_price` |
| Stripe webhook | `POST /stripe/webhook` — checks the Stripe-Signature (HMAC-SHA256, 5-minute window), records paid orders once, marks refunds (`lib/last_ten_yards/stripe_webhook.ex`) |
| Stripe checkout logic | `lib/last_ten_yards/checkout.ex` |
| Heroku | `Procfile` (release phase runs `mix ecto.migrate`), `elixir_buildpack.config`, `config/runtime.exs` (reads `DATABASE_URL`) |

**Specs:** 162 post specs (node, all pass) · **70 core specs** — checkout, store rules, lines file, webhook signature, schema-in-step (`elixir test/run_core.exs`, all pass) · **20 database checks in real Postgres 16**, plus all 63 lines loaded into it (`priv/repo/structure.sql` + `test/sql/schema_check.sql`, all pass) · **`mix test`: 94 specs, 0 failures** on the real stack (Phoenix 1.7.14, Ecto 3.12, Postgres 16), 2026-09-25. The server boots and serves every page: `/`, `/lines`, `/l/<slug>`, `/store`, `/store/thanks`; unknown line → 404.

**Heroku config vars it reads:** `DATABASE_URL` (set by the Heroku Postgres add-on), `SECRET_KEY_BASE`, `PHX_HOST`, `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`. Nothing secret lives in the code.

**His hand (accounts, keys, money):** Heroku account + app, the Heroku Postgres add-on (a paid plan), Stripe account + products/prices + a webhook pointed at `/stripe/webhook`, the config vars above, the domain.
