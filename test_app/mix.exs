defmodule TestApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_app,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {TestApp.Application, []}
    ]
  end

  defp deps do
    [
      {:rivulet, path: "../"}
    ]
  end

  defp aliases do
    [
      compile: ["compile --warnings-as-errors"],
      test: ["test --no-start"]
    ]
  end
end
