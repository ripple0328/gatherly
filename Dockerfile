# Build stage
FROM elixir:1.18.4-otp-28 AS builder

# Install build dependencies
RUN apt-get update && \
	apt-get install -y \
	build-essential \
	git \
	&& rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Install hex package manager and rebar
RUN mix local.hex --force && \
	mix local.rebar --force

# Set production environment
ENV MIX_ENV=prod

# Copy mix files for dependency caching
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get --only prod && mix deps.compile

# Copy the rest of the application
COPY . .

# Setup and build assets
RUN mix assets.setup && mix assets.deploy

# Compile the project and create release
RUN mix do compile, phx.digest, release

# Runtime stage
FROM elixir:1.18.4-otp-28-slim AS runtime

# Install runtime dependencies
RUN apt-get update && \
	apt-get install -y \
	postgresql-client \
	openssl \
	&& rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r app && useradd -r -g app app

# Create app directory
WORKDIR /app

# Copy release from builder stage
COPY --from=builder --chown=app:app /app/_build/prod/rel/gatherly ./

# Switch to non-root user
USER app

# Expose the port the app runs on
EXPOSE 8080

# Start the application using the release
CMD ["./bin/gatherly", "start"]
