defmodule ArmoredStore.HygieneTest do
  use ExUnit.Case, async: true

  @email ~r/[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}/

  test "no email address anywhere in the app's source, config, data or README" do
    files =
      (Path.wildcard("{lib,config,priv}/**/*") ++ ["README.md", "mix.exs", "Procfile"])
      |> Enum.filter(&File.regular?/1)
      |> Enum.reject(&(Path.extname(&1) in ~w(.jpg .ico .png)))

    assert files != []
    hits = for f <- files, Regex.match?(@email, File.read!(f)), do: f
    assert hits == []
  end

  test "dev and test listen on localhost only, port 4001" do
    http = Application.get_env(:armored_store, ArmoredStoreWeb.Endpoint)[:http]
    assert http[:ip] == {127, 0, 0, 1}
    if System.get_env("PORT") == nil, do: assert(http[:port] == 4001)
  end

  test "own database" do
    assert Application.get_env(:armored_store, ArmoredStore.Repo)[:database] == "armored_store_test"
  end

  test "Heroku files are present" do
    assert File.read!("Procfile") =~ "web: mix phx.server"
    assert File.read!("elixir_buildpack.config") =~ "elixir_version"
    assert File.read!("config/runtime.exs") =~ "DATABASE_URL"
  end

  test "build output is git-ignored inside store/" do
    ignore = File.read!(".gitignore")
    assert ignore =~ "/deps/"
    assert ignore =~ "/_build/"
  end
end
