# Armored Store

A small Phoenix store for the Joshua Says e-books: the five Armored drills and
The Traveler's Guide (public edition). Standalone app, own databases
(`armored_store_dev`, `armored_store_test`), port 4001 on localhost in dev.

## Run

    mix setup        # deps.get, ecto.create, ecto.migrate, seeds
    mix test
    mix phx.server   # http://localhost:4001/

Postgres credentials come from PGUSER / PGPASSWORD / PGHOST (defaults: postgres / postgres / localhost).

## Where the data comes from

- Products, author, descriptions and prices: `priv/KDP_LISTINGS.json`, a verbatim copy of
  `../KDP listing sheet + JSON/KDP_LISTINGS.json` (a test checks the copy matches).
- Price = each record's `price_usd`. No price in the record means "Price not set" and no buy button.
  Nothing else sets a price.
- Covers: copies of the `Cover — .../*.jpg` files in `priv/static/images/covers/`.
- C213 Armored Drill is not in the listing data (its README calls it an on-paper study drill), so it is not listed.

## Paid files

The PDF/DOCX books are not in this app and there is no route to them; every book file path returns 404
(see `test/armored_store_web/paid_files_test.exs`). Delivery of paid files is not built yet.

## Checkout

`ArmoredStore.Checkout` creates a Stripe Checkout Session at the listing price. The HTTP call is injected,
so tests never reach Stripe. The key is read from `STRIPE_SECRET_KEY`; with none set, Buy shows
"Checkout not configured". Orders are recorded only by the signed webhook at `/stripe/webhook`
(`STRIPE_WEBHOOK_SECRET`). Heroku: `Procfile`, `elixir_buildpack.config`, `config/runtime.exs`.
