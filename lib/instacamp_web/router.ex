defmodule InstacampWeb.Router do
  use InstacampWeb, :router

  import InstacampWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {InstacampWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # pipeline :admin do
  #   plug :put_root_layout, html: {InstacampWeb.Layouts, :admin}
  #   plug :admin_auth
  # end

  # Other scopes may use custom stacks.
  # scope "/api", InstacampWeb do
  #   pipe_through :api
  # end

  scope "/", InstacampWeb do
    pipe_through :browser

    live_session :default,
      on_mount: [
        InstacampWeb.LiveHooks,
        {InstacampWeb.LiveHooks, :assign_theme_mode}
      ] do
      live "/", FeedLive, :index
      live "/user/:username", SettingsLive.UserProfile, :index, as: :user_profile
      live "/user/:username/saved", SettingsLive.UserProfile, :saved, as: :user_profile
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

  if Enum.member?([:dev, :test], Mix.env()) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## User settings live routes
  scope "/", InstacampWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :app_settings,
      on_mount: [
        InstacampWeb.LiveHooks,
        {InstacampWeb.LiveHooks, :ensure_authentication},
        {InstacampWeb.LiveHooks, :assign_theme_mode}
      ] do
      live "/auth/settings/confirm_email/:token", SettingsLive.Settings, :confirm_email
      live "/accounts/edit", SettingsLive.Settings, :edit
      live "/accounts/password/change", SettingsLive.PassSettings
      live "/user/:username/following", SettingsLive.UserProfile, :following, as: :user_profile
      live "/user/:username/followers", SettingsLive.UserProfile, :followers, as: :user_profile
      live "/saved-list", PostListLive.SavedList, :list, as: :saved_list_path
      live "/search-saved-list", PostListLive.SavedList, :search, as: :saved_list_path
      live "/new/post", PostLive.Form, :new
      live "/edit/post/:id", PostLive.Form, :edit
      live "/post/:slug/comments/:id/edit", PostLive.Show, :edit_comment
    end
  end

  # Authentication routes
  scope "/", InstacampWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :app_auth,
      on_mount: [
        InstacampWeb.LiveHooks,
        {InstacampWeb.LiveHooks, :redirect_if_user_is_authenticated},
        {InstacampWeb.LiveHooks, :assign_theme_mode}
      ],
      root_layout: {InstacampWeb.Layouts, :auth} do
      live "/auth/signup", UserAuthLive.UserSignUp, :new
      live "/auth/login", UserAuthLive.UserLogin, :new
      live "/auth/reset-password", UserAuthLive.UserResetPassword, :new

      live "/auth/reset-password/:token", UserAuthLive.UserResetPassword, :edit
    end

    post "/auth/login", UserSessionController, :create
  end

  scope "/", InstacampWeb do
    pipe_through [:browser]

    delete "/auth/logout", UserSessionController, :delete

    live_session :current_user_confirm,
      on_mount: [
        InstacampWeb.LiveHooks,
        {InstacampWeb.LiveHooks, :assign_user},
        {InstacampWeb.LiveHooks, :assign_theme_mode}
      ] do
      live "/auth/confirm/:token", UserAuthLive.UserConfirmation, :edit
      live "/auth/confirm", UserAuthLive.UserConfirmationInstructions, :new
    end
  end
end
