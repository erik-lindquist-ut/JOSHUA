defmodule ArmoredStoreWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :armored_store

  # Heroku terminates TLS; trust its forwarded proto header
  plug Plug.RewriteOn, [:x_forwarded_proto]
  plug Plug.Static, at: "/", from: :armored_store, gzip: false, only: ArmoredStoreWeb.static_paths()
  plug Plug.RequestId
  # JSON bodies are left unread so the webhook can verify the raw bytes.
  plug Plug.Parsers, parsers: [:urlencoded], pass: ["*/*"]
  plug Plug.Head
  plug Plug.Session, store: :cookie, key: "_armored_store", signing_salt: "armored-store"
  plug ArmoredStoreWeb.Router
end
