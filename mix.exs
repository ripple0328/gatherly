defmodule Gatherly.MixProject do
  use Mix.Project

  def project do
    [
      app: :gatherly,
      version: "0.1.0",
      elixir: ">= 1.18.0 and < 2.0.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
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

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Phoenix framework
      {:phoenix, "~> 1.7.0"},
      {:phoenix_ecto, "~> 4.5"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:phoenix_live_view, "~> 0.20.0"},
      {:phoenix_live_dashboard, "~> 0.8.0"},

      # Database
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.17.0"},

      # HTML parsing and testing
      {:floki, ">= 0.36.0", only: :test},

      # Asset management
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3.1", runtime: Mix.env() == :dev},

      # HTTP client
      {:finch, "~> 0.16"},

      # Email
      {:swoosh, "~> 1.14"},

      # Telemetry and monitoring
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},

      # Internationalization
      {:gettext, "~> 0.22"},

      # JSON handling
      {:jason, "~> 1.4"},

      # Clustering
      {:dns_cluster, "~> 0.1"},

      # Web server
      {:bandit, "~> 1.0"},

      # Development tools
      {:tidewave, "~> 0.1", only: :dev},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.7", only: :test},
      {:mox, "~> 1.1", only: :test}
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
