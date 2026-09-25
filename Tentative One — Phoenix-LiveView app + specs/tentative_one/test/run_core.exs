# Runs the core suites without Hex: elixir test/run_core.exs
for f <- ~w(gate run), do: Code.require_file("../lib/tentative_one/#{f}.ex", __DIR__)
ExUnit.start()
for f <- Path.wildcard(Path.join(__DIR__, "tentative_one/*_test.exs")), do: Code.require_file(f)
