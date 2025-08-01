defmodule Gatherly.MixProject do
  use Mix.Project

  def project do
    [
      app: :gatherly,
      version: "0.1.0",
      elixir: "~> 1.18.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      listeners: listeners(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [ignore_warnings: ".dialyzer_ignore.exs"],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.xml": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Gatherly.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies which listeners to use per environment.
  defp listeners(:dev), do: [Phoenix.CodeReloader]
  defp listeners(_), do: []

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:igniter, "~> 0.6", only: [:dev, :test]},
      # Phoenix framework - Updated to latest RC
      {:phoenix, "~> 1.8.0-rc.4"},
      {:phoenix_ecto, "~> 4.6.5"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_view, "~> 1.1.2"},
      {:phoenix_live_dashboard, "~> 0.8.5"},

      # Database - Updated versions
      {:ecto_sql, "~> 3.13.2"},
      {:postgrex, "~> 0.21.0"},

      # HTML parsing and testing - Updated
      {:floki, "~> 0.38.0", only: :test},
      {:lazy_html, ">= 0.0.0", only: :test},

      # Asset management - Updated
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3.1", runtime: Mix.env() == :dev},

      # HTTP client - Updated
      {:finch, "~> 0.20.0"},

      # Email - Updated
      {:swoosh, "~> 1.19.5"},

      # Telemetry and monitoring - Updated
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.3.0"},

      # Internationalization - Updated
      {:gettext, "~> 0.26"},

      # JSON handling - Updated
      {:jason, "~> 1.4"},

      # Clustering - Updated
      {:dns_cluster, "~> 0.2.0"},

      # Web server - Updated
      {:bandit, "~> 1.6"},
      # Development tools - Updated
      {:tidewave, "~> 0.2", only: [:dev]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.8", only: :test},
      {:mox, "~> 1.2", only: :test},

      # Test coverage
      {:excoveralls, "~> 0.18", only: :test},

      # Dagger SDK for CI/CD workflows
      {:dagger, github: "dagger/dagger", sparse: "sdk/elixir", only: [:dev, :test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build", "assets.deploy"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind gatherly", "esbuild gatherly"],
      "assets.deploy": [
        "tailwind gatherly --minify",
        "esbuild gatherly --minify",
        "phx.digest"
      ]
    ]
  end
end
