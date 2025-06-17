defmodule GatherlyWeb.LayoutsTest do
  use GatherlyWeb.ConnCase

  describe "app layout with navbar (when using app layout)" do
    # Note: The home page uses layout: false, so navbar tests should be done
    # via direct layout testing or pages that use the app layout

    test "app layout file contains logo elements", %{} do
      # Test the layout file directly since home page doesn't use app layout
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
          # Navbar logo image
          assert content =~ ~r/logo-icon\.svg/
          assert content =~ "Gatherly"
          assert content =~ "AI-Powered Event Planning"

        {:error, _} ->
          flunk("app.html.heex layout file not found")
      end
    end
  end

  describe "root layout head elements" do
    test "includes correct page title", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      # Page title
      assert response =~ "Gatherly - Effortless Event Planning Made Collaborative"
    end

    test "includes all favicon variations", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      # SVG favicon (modern browsers)
      assert response =~ ~r/<link rel="icon" type="image\/svg\+xml" href="[^"]*\/images\/favicon\.svg"/

      # PNG favicons (fallback)
      assert response =~ ~r/<link rel="icon" type="image\/png" sizes="32x32" href="[^"]*\/images\/favicon-32\.png"/
      assert response =~ ~r/<link rel="icon" type="image\/png" sizes="16x16" href="[^"]*\/images\/favicon-16\.png"/

      # Apple touch icon
      assert response =~ ~r/<link rel="apple-touch-icon" sizes="180x180" href="[^"]*\/images\/logo-icon-256\.png"/
    end

    test "includes complete SEO meta tags", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      # Basic SEO
      assert response =~ "Effortless event planning made collaborative"

      # Open Graph
      assert response =~ "og:type"
      assert response =~ "og:title"
      assert response =~ "og:description"
      assert response =~ "og:image"
      assert response =~ "logo-512.png"

      # Twitter Cards
      assert response =~ "twitter:card"
      assert response =~ "twitter:title"
      assert response =~ "twitter:description"
      assert response =~ "twitter:image"
    end

    test "includes PWA configuration", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      # PWA manifest
      assert response =~ "manifest.json"

      # Theme color (brand primary purple)
      assert response =~ "#7c3aed"

      # Application name
      assert response =~ "application-name"
      assert response =~ "Gatherly"
    end

    test "has proper theme configuration", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      # DaisyUI theme
      assert response =~ ~r/<html[^>]*data-theme="gatherly"/

      # Body styling
      assert response =~ ~r/<body class="bg-base-100"/
    end
  end
end
