defmodule Amsyc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AmsycWeb.Telemetry,
      Amsyc.Repo,
      {DNSCluster, query: Application.get_env(:amsyc, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Amsyc.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Amsyc.Finch},
      # Start a worker by calling: Amsyc.Worker.start_link(arg)
      # {Amsyc.Worker, arg},
      # Start to serve requests, typically the last entry
      AmsycWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Amsyc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AmsycWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
