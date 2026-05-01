import Config

postgres_port = String.to_integer(System.get_env("POSTGRES_PORT", "5435"))

config :gatherly, Gatherly.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: postgres_port,
  database: "gatherly_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :gatherly, GatherlyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "****************************************************************",
  server: false

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
config :phoenix_live_view, enable_expensive_runtime_checks: true
config :phoenix, sort_verified_routes_query_params: true
