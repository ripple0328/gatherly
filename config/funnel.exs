import Config

# Production-like configuration for Tailscale Funnel
config :gatherly, GatherlyWeb.Endpoint,
  # Allow all origins for Funnel
  check_origin: [
    "//localhost",
    "//127.0.0.1",
    "//*.ts.net"
  ],
  # Increase timeout for production traffic
  http: [
    ip: {0, 0, 0, 0}, 
    port: 4000,
    timeout: 30_000,
    max_connections: 16_384
  ],
  # Disable dev features for production-like performance
  code_reloader: false,
  debug_errors: false,
  # Use production secret key (generate new one for real production)
  secret_key_base: "6wc3JmCAHD0ZbuAnEPbvJHHoFUUTnmr8isxiNcKmU1ChGLFFYI5qT2m8FklM7ejG",
  # Optimize asset serving
  static_url: [scheme: "https"],
  force_ssl: [rewrite_on: [:x_forwarded_proto]]

# Enable production logging
config :logger, level: :info

# Optimize database for higher load
config :gatherly, Gatherly.Repo,
  username: "postgres",
  password: "postgres", 
  hostname: "postgres",
  database: "gatherly_dev",
  pool_size: 20,
  timeout: 60_000,
  queue_target: 5000