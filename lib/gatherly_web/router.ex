defmodule GatherlyWeb.Router do
  use GatherlyWeb, :router

  import GatherlyWeb.UserAuth

  pipeline :browser do
    plug :accepts, [
      "html",
      "swift",
      "swiftui"
    ]

    plug :fetch_session
    plug :fetch_live_flash

    plug :put_root_layout,
      html: {GatherlyWeb.Layouts, :root},
      swiftui: {GatherlyWeb.Layouts.SwiftUI, :root}

    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        "default-src 'self';img-src 'self' lh3.googleusercontent.com data:;style-src 'self' 'unsafe-inline';script-src 'self' 'unsafe-inline';"
    }

    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    get("/metrics", TelemetryUI.Web, [], assigns: %{telemetry_ui_allowed: true})
  end

  scope "/", GatherlyWeb do
    pipe_through :browser
    delete "/signout", GoogleAuthController, :delete
    get "/auth/google", GoogleAuthController, :request
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

  ## Authentication routes

  scope "/", GatherlyWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{GatherlyWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/", UserLoginLive, :new
      live "/signin", UserLoginLive, :new
    end
  end

  scope "/", GatherlyWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{GatherlyWeb.UserAuth, :ensure_authenticated}] do
      live "/:user_id", ProfileLive, :show
      live "/users/settings", UserSettingsLive, :edit
    end
  end
end
