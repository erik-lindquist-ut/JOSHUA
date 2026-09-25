defmodule LastTenYardsWeb.Router do
  use LastTenYardsWeb, :router
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end
  pipeline :webhook do
    plug :accepts, ["json"]
  end
  scope "/stripe", LastTenYardsWeb do
    pipe_through :webhook
    post "/webhook", WebhookController, :stripe
  end
  scope "/", LastTenYardsWeb do
    pipe_through :browser
    get "/", PageController, :index
    get "/store", StoreController, :index
    post "/store/checkout/:id", StoreController, :checkout
    get "/store/thanks", StoreController, :thanks
    get "/lines", StoreController, :lines
    get "/l/:line", StoreController, :line
  end
end
