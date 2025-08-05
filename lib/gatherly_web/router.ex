defmodule GatherlyWeb.Router do
  use GatherlyWeb, :router
  use AshAuthentication.Phoenix.Router

  # Import for custom authentication helpers if needed
  # import AshAuthentication.Plug.Helpers

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GatherlyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GatherlyWeb do
    pipe_through :browser

    get "/", PageController, :home

    # Authentication routes
    auth_routes(AuthController, Gatherly.Accounts.User, path: "/auth")
    sign_out_route(AuthController)
    sign_in_route()
    reset_route([])
  end

  # Health check endpoint for Fly.io
  scope "/", GatherlyWeb do
    pipe_through :api

    get "/health", PageController, :health
  end

  # Other scopes may use custom stacks.
  # scope "/api", GatherlyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:gatherly, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GatherlyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
