defmodule Ecdo.Mixfile do
  use Mix.Project

  def project do
    [app: :ecdo,
     version: "0.1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: Coverex.Task, coveralls: true],
     deps: deps,
     description: description,
     package: package]
  end

  def application do
    [applications: [:logger, :ecto]]
  end

  defp deps do
    [{:mariaex, ">= 0.0.0", optional: true},
     {:postgrex, ">= 0.0.0", optional: true},
     {:ecto, "~> 0.15.0"},
     {:coverex, "~> 1.4.1", only: :test}]
  end

  defp description do
    "Ecdo is a dynamic interface for ecto aims to simplify building dynamic query API based on ecto models."
  end

  defp package do
    [contributors: ["Dmitry Russ(Aleksandrov)", "Yury Gargay"],
     links: %{"Github" => "https://github.com/xerions/ecdo"}]
  end
end
