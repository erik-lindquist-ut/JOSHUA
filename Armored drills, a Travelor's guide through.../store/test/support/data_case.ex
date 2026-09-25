defmodule ArmoredStore.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias ArmoredStore.Repo
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(ArmoredStore.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end
end
