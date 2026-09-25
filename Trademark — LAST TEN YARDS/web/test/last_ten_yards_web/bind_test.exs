defmodule LastTenYardsWeb.BindTest do
  use ExUnit.Case, async: true

  defp http_ip(env), do: "config/config.exs" |> Config.Reader.read!(env: env) |> get_in([:last_ten_yards, LastTenYardsWeb.Endpoint, :http, :ip])

  test "dev and test bind to localhost only" do
    assert http_ip(:dev) == {127, 0, 0, 1}
    assert http_ip(:test) == {127, 0, 0, 1}
  end

  test "prod runtime config still binds all interfaces" do
    runtime = File.read!("config/runtime.exs")
    assert runtime =~ "if config_env() == :prod do"
    assert runtime =~ "ip: {0, 0, 0, 0}"
  end
end
