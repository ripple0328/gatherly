defmodule GatherlyWeb.AuthController do
  @moduledoc """
  Authentication controller for handling OAuth callbacks and sign in/out.
  """

  use GatherlyWeb, :controller
  use AshAuthentication.Phoenix.Controller

  def success(conn, _activity, user, _token) do
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> delete_session(:return_to)
    |> store_in_session(user)
    |> assign(:current_user, user)
    |> put_flash(:info, "Welcome #{user.name}!")
    |> redirect(to: return_to)
  end

  def failure(conn, _activity, _reason) do
    conn
    |> put_flash(:error, "Authentication failed. Please try again.")
    |> redirect(to: ~p"/sign-in")
  end

  def sign_out(conn, _params) do
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> clear_session(:gatherly)
    |> put_flash(:info, "You have been signed out.")
    |> redirect(to: return_to)
  end
end
