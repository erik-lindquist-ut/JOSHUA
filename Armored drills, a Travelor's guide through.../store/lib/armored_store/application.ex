defmodule ArmoredStore.Application do
  use Application

  def start(_type, _args),
    do: Supervisor.start_link([ArmoredStore.Repo, ArmoredStoreWeb.Endpoint], strategy: :one_for_one, name: ArmoredStore.Supervisor)
end
