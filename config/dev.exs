import Config

postgres_port = String.to_integer(System.get_env("POSTGRES_PORT", "5435"))

config :gatherly, Gatherly.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: postgres_port,
  database: "gatherly_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :gatherly, GatherlyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "****************************************************************",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:gatherly, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:gatherly, ~w(--watch)]}
  ]

config :gatherly, GatherlyWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
      ~r"priv/gettext/.*\.po$"E,
      ~r"lib/gatherly_web/router\.ex$"E,
      ~r"lib/gatherly_web/(controllers|live|components)/.*\.(ex|heex)$"E
    ]
  ]

config :gatherly, dev_routes: true
config :logger, :default_formatter, format: "[$level] $message
"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  debug_attributes: true,
  enable_expensive_runtime_checks: true
