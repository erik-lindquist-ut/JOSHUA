defmodule LastTenYardsWeb.PageController do
  use LastTenYardsWeb, :controller
  def index(conn, _), do: conn |> put_layout(false) |> put_root_layout(false) |> render(:index)
end
