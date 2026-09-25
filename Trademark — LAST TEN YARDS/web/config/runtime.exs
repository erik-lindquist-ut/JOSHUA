import Config
# Heroku sets PORT and DATABASE_URL (Heroku Postgres add-on); set SECRET_KEY_BASE, PHX_HOST,
# STRIPE_SECRET_KEY and STRIPE_WEBHOOK_SECRET as config vars.
if config_env() == :prod do
  config :last_ten_yards, LastTenYards.Repo,
    url: System.fetch_env!("DATABASE_URL"),
    ssl: [verify: :verify_none],
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "5"))

  config :last_ten_yards, LastTenYardsWeb.Endpoint,
    url: [host: System.get_env("PHX_HOST", "localhost"), scheme: "https", port: 443],
    http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
    server: true
end
