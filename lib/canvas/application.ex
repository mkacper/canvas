defmodule Canvas.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Canvas.Drawer.initalize_storage()

    children = [
      {
        Plug.Cowboy,
        scheme: :http, plug: Canvas.API, port: 4000 # port should be configurable
      }
    ]

    opts = [strategy: :one_for_one, name: Canvas.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
