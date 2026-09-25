# mix run priv/repo/seeds.exs — loads the products from priv/KDP_LISTINGS.json, a verbatim copy of
# "KDP listing sheet + JSON/KDP_LISTINGS.json". Prices come only from each record's price_usd.
# Safe to run again.
products = ArmoredStore.Catalog.seed_from_listings(Application.app_dir(:armored_store, "priv/KDP_LISTINGS.json"))

for p <- products do
  IO.puts("  #{p.title}: " <> if(p.cents, do: "#{p.cents} cents (#{p.price_source})", else: "Price not set"))
end

IO.puts("#{length(products)} products seeded.")
