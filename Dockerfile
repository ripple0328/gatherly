# Use the official Elixir image with the latest OTP version
FROM elixir:1.18.4-otp-28

# Install required system dependencies
RUN apt-get update && \
	apt-get install -y \
	build-essential \
	inotify-tools \
	postgresql-client \
	&& rm -rf /var/lib/apt/lists/*

# Create app directory and copy the Mixfile and mix.lock to cache the deps
WORKDIR /app

# Install hex package manager
RUN mix local.hex --force && \
	mix local.rebar --force

# Set production environment
ENV MIX_ENV=prod

# Copy mix files for dependency caching
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get --only prod

# Copy the rest of the application
COPY . .

# Setup and build assets
RUN mix assets.setup && mix assets.deploy

# Compile the project
RUN mix do compile, phx.digest

# Expose the port the app runs on
EXPOSE 8080

# Start the application
CMD ["mix", "phx.server"]
