defmodule GatherlyWeb.MagicLinkController do
  @moduledoc """
  Controller for handling magic link access and anonymous user registration.
  """

  use GatherlyWeb, :controller
  alias Gatherly.Accounts.User
  alias Gatherly.Events.MagicLink

  def join(conn, %{"token" => token}) do
    case MagicLink.valid_token(token) do
      {:ok, magic_link} ->
        # Load the associated event
        magic_link = Ash.load!(magic_link, [:event])

        # Check if user is already authenticated
        case get_session(conn, :current_user_id) do
          nil ->
            # Show anonymous registration form
            render(conn, :join, %{
              magic_link: magic_link,
              event: magic_link.event,
              changeset: %{}
            })

          _user_id ->
            # User already authenticated, redirect to event
            redirect(conn, to: ~p"/events/#{magic_link.event_id}")
        end

      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid or expired invitation link.")
        |> redirect(to: ~p"/")
    end
  end

  def register(conn, %{"token" => token, "user" => user_params}) do
    case MagicLink.valid_token(token) do
      {:ok, magic_link} ->
        magic_link = Ash.load!(magic_link, [:event])

        # Create anonymous user
        case User.create_anonymous(Map.merge(user_params, %{"magic_token" => token})) do
          {:ok, user} ->
            # Increment magic link usage
            MagicLink.increment_uses(magic_link)

            # Set user session
            conn
            |> put_session(:current_user_id, user.id)
            |> put_session(:user_type, :anonymous)
            |> put_flash(:info, "Welcome #{user.name}! You've joined #{magic_link.event.title}.")
            |> redirect(to: ~p"/events/#{magic_link.event_id}")

          {:error, changeset} ->
            render(conn, :join, %{
              magic_link: magic_link,
              event: magic_link.event,
              changeset: changeset
            })
        end

      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid or expired invitation link.")
        |> redirect(to: ~p"/")
    end
  end

  # Helper for generating magic links (dev/admin use)
  def generate(conn, %{"event_id" => event_id}) do
    case get_session(conn, :current_user_id) do
      nil ->
        conn
        |> put_flash(:error, "You must be logged in to generate invite links.")
        |> redirect(to: ~p"/sign-in")

      user_id ->
        case MagicLink.generate_for_event(event_id, user_id) do
          {:ok, magic_link} ->
            magic_url = MagicLink.generate_magic_url(magic_link.token)

            json(conn, %{
              success: true,
              magic_url: magic_url,
              token: magic_link.token,
              expires_at: magic_link.expires_at
            })

          {:error, _changeset} ->
            json(conn, %{success: false, error: "Failed to generate magic link"})
        end
    end
  end
end
