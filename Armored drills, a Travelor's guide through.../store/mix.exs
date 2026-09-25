defmodule ArmoredStore.MixProject do
  use Mix.Project

  def project,
    do: [
      app: :armored_store,
      version: "0.1.0",
      elixir: "~> 1.14",
      releases: [armored_store: []],
      elixirc_paths: paths(Mix.env()),
      deps: deps(),
      aliases: aliases()
    ]

  def application, do: [mod: {ArmoredStore.Application, []}, extra_applications: [:logger, :crypto]]

  defp paths(:test), do: ["lib", "test/support"]
  defp paths(_), do: ["lib"]

  defp deps,
    do: [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.0"},
      {:bandit, "~> 1.5"},
      {:jason, "~> 1.2"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, ">= 0.0.0"},
      {:req, "~> 0.5"},
      {:floki, ">= 0.30.0", only: :test}
    ]

  defp aliases,
    do: [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
end
