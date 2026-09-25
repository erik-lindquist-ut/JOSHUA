defmodule TentativeOneWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint TentativeOneWeb.Endpoint
      use TentativeOneWeb, :verified_routes
      import Plug.Conn
      import Phoenix.ConnTest
      import TentativeOneWeb.ConnCase
    end
  end

  setup _tags, do: {:ok, conn: Phoenix.ConnTest.build_conn()}
end
