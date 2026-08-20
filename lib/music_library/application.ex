defmodule MusicLibrary.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    {:ok, _, _} =
      Ecto.Migrator.with_repo(
        MusicLibrary.Repo,
        &Ecto.Migrator.run(&1, :up, all: true)
      )

    children = [
      MusicLibraryWeb.Telemetry,
      MusicLibrary.Repo,
      {DNSCluster, query: Application.get_env(:music_library, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MusicLibrary.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MusicLibrary.Finch},
      # Start a worker by calling: MusicLibrary.Worker.start_link(arg)
      # {MusicLibrary.Worker, arg},
      # Start to serve requests, typically the last entry
      MusicLibrary.LastFm.PeriodicFetcher,
      MusicLibrary.PeriodicDataGenerator,
      MusicLibrary.AlbumCoverDownload,
      MusicLibraryWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MusicLibrary.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MusicLibraryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
