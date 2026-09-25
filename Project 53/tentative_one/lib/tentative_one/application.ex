defmodule TentativeOne.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: TentativeOne.PubSub},
      TentativeOneWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: TentativeOne.Supervisor)
  end
end
