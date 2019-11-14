defmodule LiveGraphTestWeb.Router do
  use LiveGraphTestWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveGraphTestWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

end
