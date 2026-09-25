defmodule TentativeOne.MixProject do
  use Mix.Project

  def project do
    [
      app: :tentative_one,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: [setup: ["deps.get"]]
    ]
  end

  def application, do: [mod: {TentativeOne.Application, []}, extra_applications: [:logger]]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 0.20.17"},
      {:floki, ">= 0.30.0", only: :test},
      {:jason, "~> 1.2"},
      {:bandit, "~> 1.5"}
    ]
  end
end
