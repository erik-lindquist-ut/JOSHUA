import Config

config :tentative_one, TentativeOneWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [formats: [html: TentativeOneWeb.ErrorHTML], layout: false],
  pubsub_server: TentativeOne.PubSub,
  live_view: [signing_salt: "t1-salt-a9"]

# how long a tentative 1 waits before it moves on its own
config :tentative_one, :tick_ms, 900

config :phoenix, :json_library, Jason
import_config "#{config_env()}.exs"
