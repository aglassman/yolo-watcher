defmodule YoloWatcher.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      YoloWatcherWeb.Telemetry,
      YoloWatcher.Repo,
      {DNSCluster, query: Application.get_env(:yolo_watcher, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: YoloWatcher.PubSub},
      {Task.Supervisor, name: YoloWatcher.TaskSupervisor},
      {Task, fn -> ResultsServer.accept(4040) end},
      # Start a worker by calling: YoloWatcher.Worker.start_link(arg)
      # {YoloWatcher.Worker, arg},
      # Start to serve requests, typically the last entry
      YoloWatcherWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: YoloWatcher.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    YoloWatcherWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
