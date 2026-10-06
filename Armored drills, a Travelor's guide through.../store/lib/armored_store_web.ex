defmodule ArmoredStoreWeb do
  @moduledoc """
  Web helpers. Covers, styles, favicon, robots.txt, and the labeled WGU handoff PDF
  under priv/static/handoff/ are static. Paid book PDF/DOCX are never served.
  """
  def static_paths, do: ~w(assets images favicon.ico robots.txt handoff)

  def router, do: quote(do: (use Phoenix.Router, helpers: false; import Plug.Conn; import Phoenix.Controller))
  # Every page is a full HTML document (StoreHTML.page/1), so no layouts wrap it.
  def controller, do: quote(do: (use Phoenix.Controller, formats: [:html], layouts: []; import Plug.Conn))
  def html, do: quote(do: (use Phoenix.Component; import Phoenix.HTML))

  defmacro __using__(which), do: apply(__MODULE__, which, [])
end
