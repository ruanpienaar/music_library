defmodule MusicLibraryWeb.Router do
  use MusicLibraryWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MusicLibraryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MusicLibraryWeb do
    pipe_through :browser

    live "/", DashboardLive
    live "/artists", ArtistLive
    live "/tracks", TrackLive
    live "/today", TodayLive
    live "/on-this-day", OnThisDayLive
    live "/decades", DecadesLive
  end

  # Other scopes may use custom stacks.
  scope "/api/1/", MusicLibraryWeb do
    pipe_through :api

    # curl -XGET -vvv http://localhost:4000/api/1/artist/Ladytron
    get "/artist/:name", Api.Artist, :get

    # curl -XPOST -H "Content-Type: application/json" -vvv http://localhost:4000/api/1/artist -d "{\"name\": \"Ladytron\"}"
    post "/artist", Api.Artist, :post
    put "/artist", Api.Artist, :put

    delete "/delete", Api.Delete, :delete
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:music_library, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MusicLibraryWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
