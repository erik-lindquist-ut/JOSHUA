defmodule LastTenYardsWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :last_ten_yards
  # Heroku terminates TLS; trust its forwarded proto header
  plug Plug.RewriteOn, [:x_forwarded_proto]
  plug Plug.Static, at: "/", from: :last_ten_yards, gzip: false, only: LastTenYardsWeb.static_paths()
  plug Plug.RequestId
  plug Plug.Parsers, parsers: [:urlencoded], pass: ["*/*"]
  plug Plug.Head
  plug Plug.Session, store: :cookie, key: "_lty", signing_salt: "lty-store"
  plug LastTenYardsWeb.Router
end
