defmodule Canvas.MixProject do
  use Mix.Project

  def project do
    [
      app: :canvas,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :mnesia],
      mod: {Canvas.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.4"}
    ]
  end
end
