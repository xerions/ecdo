defmodule Ecdo.Mixfile do
  use Mix.Project

  def project do
    [app: :ecdo,
     version: "0.0.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: Coverex.Task, coveralls: true],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :ecto, :ecto_it]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:mariaex, ">= 0.0.0"},
     {:postgrex, ">= 0.0.0"},
     {:poison, "~> 1.0"},
     {:ecto, "~> 0.15.0"},
     {:ecto_it, "~> 0.2.0"},
     {:ecto_migrate, "~> 0.6.0"},
     {:coverex, "~> 1.4.1", only: :test}]
  end
end
