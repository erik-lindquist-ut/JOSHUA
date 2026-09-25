# mix run priv/repo/seeds.exs — loads priv/lines.json, then priv/products.json (safe to run again).
# Adding a business line is one entry in priv/lines.json. A product names its line with "line": "<slug>".
alias LastTenYards.{Checkout, Store}
alias LastTenYards.Store.Rules

lines = "priv/lines.json" |> File.read!() |> Checkout.catalog()
[] = Rules.lines_file_errors(lines)
Enum.each(lines, fn l -> {:ok, _} = Store.upsert_line(l) end)

"priv/products.json"
|> File.read!()
|> Checkout.catalog()
|> Enum.with_index()
|> Enum.each(fn {p, i} -> {:ok, _} = Store.upsert_product(Map.merge(p, %{"slug" => p["id"], "position" => i})) end)

IO.puts("#{length(lines)} business lines seeded.")
