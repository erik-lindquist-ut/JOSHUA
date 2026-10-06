defmodule ArmoredStoreWeb.Router do
  use ArmoredStoreWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :webhook do
    plug :accepts, ["json"]
  end

  scope "/stripe", ArmoredStoreWeb do
    pipe_through :webhook
    post "/webhook", WebhookController, :stripe
  end

  scope "/", ArmoredStoreWeb do
    pipe_through :browser
    get "/", StoreController, :index
    get "/docs/readme", StoreController, :docs_readme
    get "/docs/technical", StoreController, :docs_technical
    get "/books", StoreController, :books
    get "/schools/:school", StoreController, :school
    get "/programs/:slug", StoreController, :program
    get "/books/:slug/files", StoreController, :files
    get "/books/:slug", StoreController, :show
    get "/books/:slug/example", StoreController, :example
    post "/checkout/:slug", StoreController, :checkout
    get "/thanks", StoreController, :thanks
  end

  # Everything else (including any guess at a book file) is a plain 404.
  scope "/", ArmoredStoreWeb do
    get "/*path", StoreController, :not_found
  end
end
