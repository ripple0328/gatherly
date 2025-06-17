defmodule GatherlyWeb.NavbarTest do
  use GatherlyWeb.ConnCase

  # Test the navbar specifically by creating a route that uses the app layout
  describe "navbar components" do
    test "navbar elements are present when app layout is used" do
      # Since home page uses layout: false, we need to check what the navbar would contain
      # by testing the layout component directly or by creating a test page with layout

      # For now, let's test that the layout files contain the expected elements
      app_layout_path =
        Path.join([
          :code.priv_dir(:gatherly),
          "..",
          "lib",
          "gatherly_web",
          "components",
          "layouts",
          "app.html.heex"
        ])

      case File.read(app_layout_path) do
        {:ok, content} ->
          # Test navbar branding elements in layout file
          assert content =~ "logo-icon.svg"
          assert content =~ "Gatherly"
          assert content =~ "gradient"
          assert content =~ "Features"
          assert content =~ "Event Types"
          assert content =~ "Sign In"
          assert content =~ "Create Account"

        {:error, _} ->
          # Layout file should exist
          flunk("app.html.heex layout file not found")
      end
    end

    test "layout contains proper navbar structure" do
      app_layout_path =
        Path.join([
          :code.priv_dir(:gatherly),
          "..",
          "lib",
          "gatherly_web",
          "components",
          "layouts",
          "app.html.heex"
        ])

      case File.read(app_layout_path) do
        {:ok, content} ->
          # Navbar structure
          assert content =~ "navbar"
          assert content =~ "navbar-start"
          assert content =~ "navbar-center"
          assert content =~ "navbar-end"

          # Branding elements
          assert content =~ "AI-Powered Event Planning"
          assert content =~ "hover:bg-primary/5"

        {:error, _} ->
          flunk("app.html.heex layout file not found")
      end
    end
  end
end
