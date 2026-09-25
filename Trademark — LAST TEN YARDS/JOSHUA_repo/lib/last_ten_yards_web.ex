defmodule LastTenYardsWeb do
  def static_paths, do: ~w(assets favicon.ico robots.txt)
  def router, do: quote(do: (use Phoenix.Router, helpers: false; import Plug.Conn; import Phoenix.Controller))
  # Every page is a full HTML document, so no layouts wrap it.
  def controller, do: quote(do: (use Phoenix.Controller, formats: [:html], layouts: []; import Plug.Conn))
  def html, do: quote(do: (use Phoenix.Component; import Phoenix.HTML))
  defmacro __using__(w), do: apply(__MODULE__, w, [])
end
