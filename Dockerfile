# Use the official Elixir image with the required OTP version
FROM elixir:1.18.4-otp-27

# Install required system dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    inotify-tools \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.x
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs

# Create app directory and copy the Mixfile and mix.lock to cache the deps
WORKDIR /app

# Install hex package manager
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files for dependency caching
COPY mix.exs mix.lock ./


# Install dependencies
RUN mix deps.get

# Copy the rest of the application
COPY . .

# Install Node.js dependencies
RUN cd assets && \
    npm install && \
    cd ..

# Compile the project
RUN mix do compile

# Expose the port the app runs on
EXPOSE 4000

# Start the application
CMD ["mix", "phx.server"]
