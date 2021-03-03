defmodule Rivulet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rivulet,
      version: "0.1.0",
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_deps: :app_direct,
        plt_add_apps: [:brod],
        ignore_warnings: "dialyzer.ignore-warnings"
      ],
      aliases: aliases()
    ]
  end

  def application do
    if Mix.env() == :test do
      [
        applications: [:mix, :logger, :meck]
        # mod: {Rivulet.Application, []}
      ]
    else
      [
        applications: [:mix, :logger, :brod]
        # mod: {Rivulet.Application, []}
      ]
    end
  end

  defp aliases do
    [
      compile: ["compile --warnings-as-errors"],
      test: ["test --no-start"]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 0.5.0", only: [:dev, :test], runtime: false},
      {:brod, "~> 3.15.0"}
    ]
  end
end
