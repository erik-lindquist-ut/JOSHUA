defmodule TentativeOneWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :tentative_one

  @session_options [store: :cookie, key: "_t1", signing_salt: "t1-sign", same_site: "Lax"]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # the two client libraries straight from deps — no asset build step
  plug Plug.Static, at: "/js/phoenix", from: {:phoenix, "priv/static"}, gzip: false
  plug Plug.Static, at: "/js/lv", from: {:phoenix_live_view, "priv/static"}, gzip: false

  plug Plug.RequestId
  plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json], pass: ["*/*"], json_decoder: Jason
  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug TentativeOneWeb.Router
end
