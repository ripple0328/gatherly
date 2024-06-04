defmodule GatherlyWeb.GoogleAuthController do
  alias GatherlyWeb.UserAuth
  alias Gatherly.Accounts
  use GatherlyWeb, :controller
  require Logger

  plug Ueberauth

  def request(conn, _params) do
    Phoenix.Controller.redirect(conn, to: Ueberauth.Strategy.Helpers.callback_url(conn))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Accounts.register_oauth_user(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome #{user.name}")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("Failed to create user #{inspect(changeset)}.")

        conn
        |> put_flash(:error, "Failed to create user.")
        |> redirect(to: ~p"/")

      {:error, reason} ->
        Logger.debug("failed Google exchange #{inspect(reason)}")

        conn
        |> put_flash(:error, "We were unable to contact GitHub. Please try again later")
        |> redirect(to: ~p"/")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
