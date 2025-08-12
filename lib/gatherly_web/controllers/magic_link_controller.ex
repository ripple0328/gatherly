defmodule GatherlyWeb.MagicLinkController do
  @moduledoc """
  Controller for handling magic link helpers.
  """

  use GatherlyWeb, :controller
  alias Gatherly.Accounts.User
  alias Gatherly.Events.MagicLink

  # LiveView will redirect here after creating the user so we can set the session cookie
  def complete(conn, %{"user_id" => user_id, "token" => token}) do
    case {Ash.get(User, user_id), MagicLink.get_by_token(token)} do
      {{:ok, user}, {:ok, magic_link}} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_session(:user_type, :anonymous)
        |> put_flash(:info, "Welcome #{user.name}!")
        |> redirect(to: ~p"/events/#{magic_link.event_id}")

      _ ->
        conn
        |> put_flash(:error, "Invalid session completion request.")
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
