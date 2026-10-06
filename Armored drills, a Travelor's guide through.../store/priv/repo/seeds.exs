# mix run priv/repo/seeds.exs — loads the products from priv/KDP_LISTINGS.json, a verbatim copy of
# "KDP listing sheet + JSON/KDP_LISTINGS.json", then the store additions in priv/STORE_ADDITIONS.json
# (titles not in the listing data yet; never priced). Prices come only from each listing record's price_usd.
# Safe to run again.
products =
  ArmoredStore.Catalog.seed_store(
    Application.app_dir(:armored_store, "priv/KDP_LISTINGS.json"),
    Application.app_dir(:armored_store, "priv/STORE_ADDITIONS.json")
  )

for p <- products do
  IO.puts("  #{p.title}: " <> if(p.cents, do: "#{p.cents} cents (#{p.price_source})", else: "Price not set"))
end

IO.puts("#{length(products)} products seeded.")
