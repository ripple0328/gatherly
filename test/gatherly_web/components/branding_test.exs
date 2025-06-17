defmodule GatherlyWeb.BrandingTest do
  use GatherlyWeb.ConnCase

  describe "brand consistency across pages" do
    test "consistent brand colors are used throughout", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Primary color usage
      assert response =~ "primary"
      assert response =~ "from-primary"
      assert response =~ "text-primary"
      assert response =~ "bg-primary"
      
      # Secondary color usage  
      assert response =~ "secondary"
      assert response =~ "via-secondary"
      assert response =~ "to-secondary"
      
      # Accent color usage
      assert response =~ "accent"
      assert response =~ "to-accent"
      assert response =~ "text-accent"
    end

    test "gradient styling is consistent", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Main brand gradient pattern
      assert response =~ "bg-gradient-to-r from-primary via-secondary to-accent"
      assert response =~ "bg-clip-text text-transparent"
      
      # Alternative gradient patterns
      assert response =~ "from-primary to-secondary"
      assert response =~ "from-secondary to-accent"
      assert response =~ "from-accent to-primary"
    end

    test "typography follows brand guidelines", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Font weights for branding
      assert response =~ "font-bold"
      assert response =~ "font-semibold"
      
      # Text sizing for hierarchy
      assert response =~ "text-6xl"  # Main hero
      assert response =~ "text-4xl"  # Section headers
      assert response =~ "text-xl"   # Subheadings
    end

    test "logo is displayed with proper accessibility", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Alt text for images
      assert response =~ ~r/alt="Gatherly[^"]*"/
      
      # Logo should not be decorative only
      refute response =~ ~r/alt=""/
      refute response =~ ~r/role="presentation"/
    end

    test "hover and interaction states maintain brand", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Hover effects (present in buttons and cards on home page)
      assert response =~ "hover:scale-"
      assert response =~ "hover:shadow-"
      
      # Transition effects
      assert response =~ "transition-"
      assert response =~ "duration-"
    end

    test "sections use brand-appropriate badges and indicators", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Badge styling with brand colors
      assert response =~ "badge-primary"
      assert response =~ "badge-secondary" 
      assert response =~ "badge-accent"
      assert response =~ "badge-outline"
      
      # Brand emojis/indicators
      assert response =~ "✨"  # Features
      assert response =~ "🎉"  # Events
      assert response =~ "💬"  # Testimonials
      assert response =~ "🚀"  # CTA
    end

    test "card and component styling maintains brand consistency", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Card gradient backgrounds
      assert response =~ "bg-gradient-to-br from-primary/5"
      assert response =~ "bg-gradient-to-br from-secondary/5"
      assert response =~ "bg-gradient-to-br from-accent/5"
      
      # Border and shadow consistency
      assert response =~ "border-primary/10"
      assert response =~ "border-secondary/10"
      assert response =~ "border-accent/10"
      
      # Hover effects on cards
      assert response =~ "hover:shadow-xl"
      assert response =~ "hover:shadow-2xl"
    end

    test "animation and motion respect brand personality", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Brand animations
      assert response =~ "animate-gradient"
      assert response =~ "animate-fade-in"
      assert response =~ "animate-pulse"
      
      # Delay patterns for staged reveals
      assert response =~ "delay-200"
      assert response =~ "delay-400"
      assert response =~ "delay-600"
      assert response =~ "delay-800"
    end
  end

  describe "responsive brand display" do
    test "logo scales appropriately on different screen sizes", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Responsive text sizing
      assert response =~ "text-6xl md:text-7xl"  # Hero title
      assert response =~ "text-4xl md:text-6xl"  # Section headers
      assert response =~ "text-4xl md:text-5xl"  # Subsection headers
      
      # Responsive spacing
      assert response =~ "gap-4"
      assert response =~ "gap-6"
    end

    test "navigation adapts while maintaining brand", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Responsive layout (home page uses flex responsive classes)
      assert response =~ "flex-col sm:flex-row"  # CTAs are responsive
      
      # Home page has responsive design elements
      assert response =~ "grid-cols-1"
    end

    test "layout maintains brand hierarchy on mobile", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Mobile-first grid layouts
      assert response =~ "grid-cols-1 md:grid-cols-2"
      assert response =~ "grid-cols-1 md:grid-cols-3"
      assert response =~ "flex-col sm:flex-row"
      
      # Responsive padding/margins
      assert response =~ "py-20"
      assert response =~ "px-4"
      assert response =~ "max-w-"
    end
  end
end