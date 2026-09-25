defmodule TentativeOneWeb.Router do
  use TentativeOneWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TentativeOneWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", TentativeOneWeb do
    pipe_through :browser
    live "/", RunLive
  end
end
