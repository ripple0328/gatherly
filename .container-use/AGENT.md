This is a Phoenix/Elixir project called Gatherly.

Tool versions (from .tool-versions):
- Elixir: 1.18 (with OTP 28)
- Node.js: 24.2.0

Development commands:
- `bash -c '. /opt/asdf.sh && <command>'` - Run commands with asdf environment
- `mix deps.get` - Install Elixir dependencies  
- `mix ecto.setup` - Setup database (create, migrate, seed)
- `mix phx.server` - Start Phoenix development server
- `mix test` - Run tests
- `mix format` - Format code
- `mix credo` - Run static analysis
- `cd assets && npm install` - Install frontend dependencies
- `cd assets && npm run build` - Build frontend assets

Project structure:
- lib/gatherly/ - Core domain logic and contexts
- lib/gatherly_web/ - Web interface (controllers, views, LiveViews, components)
- assets/ - Frontend assets (CSS, JS, package.json)
- config/ - Application configuration
- priv/repo/migrations/ - Database migrations
- test/ - Test files

The project uses:
- Phoenix Framework with LiveView
- PostgreSQL database
- Tailwind CSS for styling
- Webpack for asset bundling

To view your work: `git checkout gatherly-debug/charmed-burro`