defmodule LastTenYards.Application do
  use Application
  def start(_t, _a), do: Supervisor.start_link([LastTenYards.Repo, LastTenYardsWeb.Endpoint], strategy: :one_for_one, name: LastTenYards.Supervisor)
end
