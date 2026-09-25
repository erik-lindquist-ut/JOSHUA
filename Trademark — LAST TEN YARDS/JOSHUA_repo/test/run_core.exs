# Runs every spec that needs no Hex packages: elixir test/run_core.exs
for f <- ~w(json.ex checkout.ex store/rules.ex stripe_webhook.ex), do: Code.require_file("../lib/last_ten_yards/#{f}", __DIR__)
ExUnit.start()
for f <- ~w(checkout_test.exs rules_test.exs lines_test.exs stripe_webhook_test.exs schema_test.exs), do: Code.require_file("last_ten_yards/#{f}", __DIR__)
