defmodule LastTenYards.DataCase do
  use ExUnit.CaseTemplate
  using do
    quote do
      alias LastTenYards.Repo
      import LastTenYards.DataCase
    end
  end
  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(LastTenYards.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end
end
