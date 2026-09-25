import Config
config :last_ten_yards, ecto_repos: [LastTenYards.Repo]
# Local Postgres for dev and test. Heroku uses DATABASE_URL (config/runtime.exs).
config :last_ten_yards, LastTenYards.Repo,
  username: System.get_env("PGUSER", "postgres"),
  password: System.get_env("PGPASSWORD", "postgres"),
  hostname: System.get_env("PGHOST", "localhost"),
  database: "last_ten_yards_#{config_env()}",
  pool: if(config_env() == :test, do: Ecto.Adapters.SQL.Sandbox, else: DBConnection.ConnectionPool),
  pool_size: 10
config :last_ten_yards, LastTenYardsWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [formats: [html: LastTenYardsWeb.ErrorHTML], layout: false],
  secret_key_base: System.get_env("SECRET_KEY_BASE", String.duplicate("dev-only-not-a-secret-", 4)),
  # No :server key here: `mix phx.server` serves in dev, runtime.exs serves in prod,
  # and `mix run` (seeds) and `mix test` never bind a port.
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))]
config :phoenix, :json_library, Jason
config :logger, level: :info
