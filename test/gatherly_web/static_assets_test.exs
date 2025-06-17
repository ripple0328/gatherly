defmodule GatherlyWeb.StaticAssetsTest do
  use GatherlyWeb.ConnCase

  describe "logo and branding assets" do
    test "logo SVG files are accessible", %{conn: conn} do
      # Main logo
      conn = get(conn, "/images/logo.svg")
      assert response(conn, 200)
      
      # Logo icon
      conn = get(conn, "/images/logo-icon.svg") 
      assert response(conn, 200)
      
      # White logo variant
      conn = get(conn, "/images/logo-white.svg")
      assert response(conn, 200)
    end

    test "favicon files are accessible", %{conn: conn} do
      # SVG favicon
      conn = get(conn, "/images/favicon.svg")
      assert response(conn, 200)
      
      # PNG favicons
      conn = get(conn, "/images/favicon-32.png")
      assert response(conn, 200)
      
      conn = get(conn, "/images/favicon-16.png")
      assert response(conn, 200)
    end

    test "app icon PNG files are accessible", %{conn: conn} do
      # Logo PNG variants
      conn = get(conn, "/images/logo-512.png")
      assert response(conn, 200)
      
      conn = get(conn, "/images/logo-icon-256.png")
      assert response(conn, 200)
    end

    test "logo SVG contains proper branding elements", %{conn: conn} do
      conn = get(conn, "/images/logo.svg")
      response = response(conn, 200)
      
      # SVG structure
      assert response =~ ~r/<svg[^>]*viewBox="0 0 200 60"/
      
      # Gradient definitions
      assert response =~ "logoGradient"
      assert response =~ "iconGradient"
      assert response =~ "accentGradient"
      
      # Brand colors
      assert response =~ "#7c3aed"  # Primary purple
      assert response =~ "#06b6d4"  # Secondary cyan
      assert response =~ "#10b981"  # Accent green
      
      # Logo text
      assert response =~ "Gatherly"
    end

    test "logo icon SVG contains interconnected design", %{conn: conn} do
      conn = get(conn, "/images/logo-icon.svg")
      response = response(conn, 200)
      
      # SVG dimensions
      assert response =~ ~r/<svg[^>]*viewBox="0 0 44 44"/
      
      # Central hub circle
      assert response =~ ~r/<circle[^>]*cx="22"[^>]*cy="22"[^>]*r="6"/
      
      # Connection lines (representing collaboration)
      assert response =~ ~r/<line[^>]*x1="22"[^>]*y1="22"/
      
      # Gradient fills
      assert response =~ "url(#iconGradient)"
      assert response =~ "url(#accentGradient)"
    end

    test "favicon SVG is optimized for small size", %{conn: conn} do
      conn = get(conn, "/images/favicon.svg")
      response = response(conn, 200)
      
      # Favicon dimensions (32x32)
      assert response =~ ~r/<svg[^>]*viewBox="0 0 32 32"/
      
      # Simplified design for small size
      assert response =~ ~r/<circle[^>]*cx="16"[^>]*cy="16"[^>]*r="4"/
      
      # Contains brand gradients
      assert response =~ "iconGradient"
      assert response =~ "accentGradient"
    end
  end

  describe "PWA manifest" do
    test "manifest.json is accessible and valid", %{conn: conn} do
      conn = get(conn, "/manifest.json")
      response = response(conn, 200)
      
      # Parse JSON to ensure it's valid
      manifest = Jason.decode!(response)
      
      # Required PWA fields
      assert manifest["name"] == "Gatherly - AI-Powered Event Planning"
      assert manifest["short_name"] == "Gatherly"
      assert manifest["start_url"] == "/"
      assert manifest["display"] == "standalone"
      assert manifest["theme_color"] == "#7c3aed"
      assert manifest["background_color"] == "#ffffff"
    end

    test "manifest contains proper icon definitions", %{conn: conn} do
      conn = get(conn, "/manifest.json")
      response = response(conn, 200)
      manifest = Jason.decode!(response)
      
      # Icons array exists
      assert is_list(manifest["icons"])
      assert length(manifest["icons"]) > 0
      
      # Check for required icon sizes
      icon_sizes = Enum.map(manifest["icons"], & &1["sizes"])
      assert "16x16" in icon_sizes
      assert "32x32" in icon_sizes
      assert "256x256" in icon_sizes
      assert "512x512" in icon_sizes
      
      # Check icon purposes
      icon_purposes = Enum.map(manifest["icons"], & &1["purpose"]) |> Enum.reject(&is_nil/1)
      assert "any maskable" in icon_purposes
    end

    test "manifest includes proper metadata", %{conn: conn} do
      conn = get(conn, "/manifest.json")
      response = response(conn, 200)
      manifest = Jason.decode!(response)
      
      # App description
      assert manifest["description"] =~ "Effortless event planning made collaborative"
      
      # Orientation
      assert manifest["orientation"] == "portrait-primary"
      
      # Categories
      assert is_list(manifest["categories"])
      assert "productivity" in manifest["categories"]
      assert "social" in manifest["categories"]
      assert "lifestyle" in manifest["categories"]
    end
  end

  describe "static file content types" do
    test "SVG files served with correct content type", %{conn: conn} do
      conn = get(conn, "/images/logo.svg")
      assert get_resp_header(conn, "content-type") |> hd() =~ "image/svg+xml"
    end

    test "PNG files served with correct content type", %{conn: conn} do
      conn = get(conn, "/images/logo-512.png")
      assert get_resp_header(conn, "content-type") |> hd() =~ "image/png"
    end

    test "manifest served with correct content type", %{conn: conn} do
      conn = get(conn, "/manifest.json")
      assert get_resp_header(conn, "content-type") |> hd() =~ "application/json"
    end
  end
end