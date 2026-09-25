import Config

config :armored_store, ecto_repos: [ArmoredStore.Repo]

# Local Postgres for dev and test. Heroku uses DATABASE_URL (config/runtime.exs).
config :armored_store, ArmoredStore.Repo,
  username: System.get_env("PGUSER", "postgres"),
  password: System.get_env("PGPASSWORD", "postgres"),
  hostname: System.get_env("PGHOST", "localhost"),
  database: "armored_store_#{config_env()}",
  pool: if(config_env() == :test, do: Ecto.Adapters.SQL.Sandbox, else: DBConnection.ConnectionPool),
  pool_size: 10

config :armored_store, ArmoredStoreWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [formats: [html: ArmoredStoreWeb.ErrorHTML], layout: false],
  secret_key_base: System.get_env("SECRET_KEY_BASE", String.duplicate("dev-only-not-a-secret-", 4)),
  # No :server key here: `mix phx.server` serves in dev, runtime.exs serves in prod,
  # and `mix run` (seeds) and `mix test` never bind a port.
  # Dev and test listen on localhost only, port 4001 (Last Ten Yards has 4000).
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT", "4001"))]

# Tests must never reach Stripe: the HTTP call is swapped for one that refuses.
if config_env() == :test do
  config :armored_store, :stripe_post, {ArmoredStore.Checkout, :offline_post}
end

config :phoenix, :json_library, Jason
config :logger, level: if(config_env() == :test, do: :warning, else: :info)
