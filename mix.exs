defmodule ChessPlus.MixProject do
  use Mix.Project

  def project do
    [
      app: :chess_plus_server,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ChessPlus.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.16", only: [:dev], runtime: false},
      {:poison, "~> 2.0"},
      {:guardian, git: "https://github.com/nanaki04/Guardian.git"},
      {:life_bloom, git: "https://github.com/nanaki04/LifeBloom.git"},
      {:path_finder, git: "https://github.com/nanaki04/PathFinder.git"},
    ]
  end
end
