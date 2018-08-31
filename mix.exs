defmodule Extract.MixProject do
  use Mix.Project

  def project do
    [
      app: :extract,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_options: [warnings_as_errors: true],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE*"],
      maintainers: ["Mariane Coelho", "Vinicius Souza"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/redealumni/extract"},
      description: "A common set of utilities for Elixir/Phoenix applications"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end
end
