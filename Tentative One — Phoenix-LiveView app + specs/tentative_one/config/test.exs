import Config

config :tentative_one, TentativeOneWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: String.duplicate("test-only-not-a-secret-", 4),
  server: false

# tests drive ticks by hand
config :tentative_one, :tick_ms, :manual
config :logger, level: :warning
