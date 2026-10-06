# Armored Store

A small Phoenix store for the Joshua Says e-books: the five Armored drills,
The Traveler's Guide (public edition) and the Fail Fast Compendium (unpriced). Standalone app, own databases
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
- Store additions: `priv/STORE_ADDITIONS.json` holds titles that are not in the listing data yet, loaded after the
  listings (`Catalog.seed_store/2`). Today that is #7, *Armored Accounting for Decision Making: The Fail Fast
  Compendium*. An addition never carries a price (any `price_usd` there is ignored), so it shows "Price not set" and
  no buy button until its record, with a price, is in the listing data.
- Previews: every card links to its book page (`/books/:slug`), which shows the book's preview under
  `#preview`. The text is in `priv/PREVIEWS.json`, copied exactly from each book's own `.docx` by
  `python3 tools/extract_previews.py` (run from `store/`; it only reads the book files). The preview is the book's
  foreword when it has one (Accounting for Decision Making: "Introduction"; The Traveler's Guide: "A word before
  you go"); the five Armored drills have no foreword, so their opening section, "How to run it", is shown.
  A test checks every preview paragraph against the book file.
- C213 Armored Drill is not in the listing data (its README calls it an on-paper study drill), so it is not listed.

## Paid files

The PDF/DOCX books are not in this app and there is no route to them; every book file path returns 404
(see `test/armored_store_web/paid_files_test.exs`). Delivery of paid files is not built yet.

## Checkout

`ArmoredStore.Checkout` creates a Stripe Checkout Session at the listing price. The HTTP call is injected,
so tests never reach Stripe. The key is read from `STRIPE_SECRET_KEY`; with none set, Buy shows
"Checkout not configured". Orders are recorded only by the signed webhook at `/stripe/webhook`
(`STRIPE_WEBHOOK_SECRET`). Heroku: `Procfile`, `elixir_buildpack.config`, `config/runtime.exs`.

## WGU I.P. (2026-09-29)

WGU I.P.: gifted to WGU, 2026-09-29, see WGU IP - Gifted.md (in `Desktop/Workspace/JOSHUA/`)
