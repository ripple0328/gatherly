defmodule Gatherly.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gatherly.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def unique_user_name, do: Faker.Person.name()
  def unique_image_url, do: Faker.Avatar.image_url()

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      provider: :google,
      uid: "xxxxxx",
      info: %{
        email: unique_user_email(),
        name: unique_user_name(),
        image: unique_image_url()
      },
      credentials: %{
        token: "token"
      }
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Gatherly.Accounts.register_oauth_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
