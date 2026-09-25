import Config

config :tentative_one, TentativeOneWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  debug_errors: true,
  secret_key_base: String.duplicate("dev-only-not-a-secret-", 4)
