defmodule InstacampWeb.Router do
  use InstacampWeb, :router

  import InstacampWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {InstacampWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", InstacampWeb do
  #   pipe_through :api
  # end

  scope "/", InstacampWeb do
    pipe_through :browser

    live_session :default,
      on_mount: [
        InstacampWeb.LiveHooks,
        {InstacampWeb.LiveHooks, :assign_user}
      ],
      root_layout: {InstacampWeb.LayoutView, :root} do
      live "/", HomeLive
      live "/user/:username", SettingsLive.UserProfile, :index, as: :user_profile
      live "/user/:username/saved", SettingsLive.UserProfile, :saved, as: :user_profile
      live "/tag/:name", PostLive.List, :index
      live "/post/:slug", PostLive.Show, :show
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: InstacampWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Enum.member?([:dev, :test], Application.compile_env(:instacamp, :env)) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication live routes
  scope "/", InstacampWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :app_auth,
      on_mount: [
        InstacampWeb.LiveHooks,
        {InstacampWeb.LiveHooks, :assign_user}
      ],
      root_layout: {InstacampWeb.LayoutView, :root} do
      get "/auth/settings/confirm_email/:token", UserSettingsController, :confirm_email
      live "/accounts/edit", SettingsLive.Settings
      live "/accounts/password/change", SettingsLive.PassSettings
      live "/user/:username/following", SettingsLive.UserProfile, :following, as: :user_profile
      live "/user/:username/followers", SettingsLive.UserProfile, :followers, as: :user_profile
      live "/saved-list", PostListLive.SavedList, :list, as: :saved_list_path
      live "/seach-saved-list", PostListLive.SavedList, :search, as: :saved_list_path
      live "/new/post", PostLive.Form, :new
      live "/edit/post/:id", PostLive.Form, :edit
      live "/post/:slug/comments/:id/edit", PostLive.Show, :edit_comment
    end
  end

  # Authentication routes
  scope "/", InstacampWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :more_auth,
      on_mount: [
        InstacampWeb.LiveHooks,
        {InstacampWeb.LiveHooks, :assign_user}
      ],
      root_layout: {InstacampWeb.LayoutView, :root} do
      live "/auth/signup", UserAuthLive.SignUp, :new
      live "/auth/login", UserAuthLive.Login, :new
      post "/auth/login", UserSessionController, :create
      live "/reset-password", UserAuthLive.UserResetPassword, :new, as: :user_reset_password

      live "/reset-password/:token", UserAuthLive.UserResetPassword, :edit,
        as: :user_reset_password

      # get "/auth/reset_password", UserResetPasswordController, :new
      # post "/auth/reset_password", UserResetPasswordController, :create
      # get "/auth/reset_password/:token", UserResetPasswordController, :edit
      # put "/auth/reset_password/:token", UserResetPasswordController, :update
    end
  end

  scope "/", InstacampWeb do
    pipe_through [:browser]

    delete "/auth/logout", UserSessionController, :delete
    get "/auth/confirm", UserConfirmationController, :new
    post "/auth/confirm", UserConfirmationController, :create
    get "/auth/confirm/:token", UserConfirmationController, :edit
    post "/auth/confirm/:token", UserConfirmationController, :update
  end
end
