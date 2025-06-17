defmodule GatherlyWeb.PageControllerTest do
  use GatherlyWeb.ConnCase

  describe "GET /" do
    test "renders home page successfully", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Basic page load
      assert response =~ "Gatherly"
      assert response =~ "Effortless Event Planning"
    end

    test "displays logo in hero section", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Logo image is present
      assert response =~ ~r/src="[^"]*\/images\/logo-icon\.svg"/
      assert response =~ ~r/alt="Gatherly Logo"/
      
      # Logo styling classes
      assert response =~ "w-20 h-20"
      assert response =~ "drop-shadow-lg"
    end

    test "displays main heading with brand styling", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Main Gatherly heading with gradient styling
      assert response =~ ~r/<h1[^>]*bg-gradient-to-r[^>]*>.*Gatherly.*<\/h1>/s
      assert response =~ "from-primary via-secondary to-accent"
      assert response =~ "bg-clip-text text-transparent"
    end

    test "displays core features section", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Core features section
      assert response =~ ~r/id="features"/
      assert response =~ "✨ Core Features"
      assert response =~ "AI-Powered Planning"
      assert response =~ "Real-time Collaboration"
      assert response =~ "Smart Logistics"
    end

    test "displays event types section", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Event types section
      assert response =~ ~r/id="events"/
      assert response =~ "🎉 Event Types"
      assert response =~ "Potluck Dinners"
      assert response =~ "Camping Trips"
      assert response =~ "Hiking Adventures"
      assert response =~ "Game Nights"
    end

    test "displays testimonials section", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Testimonials section
      assert response =~ "💬 What People Say"
      assert response =~ "Loved by"
      assert response =~ "Event Planners"
    end

    test "displays call-to-action section", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # CTA section
      assert response =~ "🚀 Get Started"
      assert response =~ "Ready to Transform Your"
      assert response =~ "Event Planning?"
      assert response =~ "Start Your First Event"
      assert response =~ "Schedule Demo"
    end

    test "includes proper meta tags for SEO", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # SEO meta tags
      assert response =~ ~r/<meta name="description"[^>]*collaborative[^>]*>/
      assert response =~ "Effortless event planning made collaborative"
      
      # Title tag
      assert response =~ "Gatherly - Effortless Event Planning Made Collaborative"
    end

    test "includes social media meta tags", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Open Graph tags
      assert response =~ ~r/<meta property="og:type" content="website"/
      assert response =~ ~r/<meta property="og:title"[^>]*Gatherly[^>]*>/
      assert response =~ ~r/<meta property="og:description"[^>]*Transform your group events[^>]*>/
      assert response =~ ~r/<meta property="og:image"[^>]*logo-512\.png[^>]*>/
      
      # Twitter tags
      assert response =~ ~r/<meta name="twitter:card" content="summary_large_image"/
      assert response =~ ~r/<meta name="twitter:title"[^>]*Gatherly[^>]*>/
      assert response =~ ~r/<meta name="twitter:image"[^>]*logo-512\.png[^>]*>/
    end

    test "includes favicon and app icon links", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Favicon links
      assert response =~ ~r/<link rel="icon" type="image\/svg\+xml" href="[^"]*favicon\.svg"/
      assert response =~ ~r/<link rel="icon" type="image\/png" sizes="32x32" href="[^"]*favicon-32\.png"/
      assert response =~ ~r/<link rel="icon" type="image\/png" sizes="16x16" href="[^"]*favicon-16\.png"/
      
      # Apple touch icon
      assert response =~ ~r/<link rel="apple-touch-icon"[^>]*logo-icon-256\.png[^>]*>/
    end

    test "includes PWA manifest and theme color", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # PWA manifest
      assert response =~ ~r/<link rel="manifest" href="[^"]*manifest\.json"/
      
      # Theme color
      assert response =~ ~r/<meta name="theme-color" content="#7c3aed"/
      assert response =~ ~r/<meta name="application-name" content="Gatherly"/
    end
  end
end
