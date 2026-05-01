defmodule Gatherly.Events do
  @moduledoc """
  Event planning context for Gatherly's clean reboot.

  The context keeps the first product loop low-friction: create an event, share it,
  let participants add themselves, and crowdsource logistics.
  """

  import Ecto.Query

  alias Ecto.Multi
  alias Gatherly.Events.{Event, Item, Participant, Proposal, ThreadComment, Vote}
  alias Gatherly.Repo

  @token_bytes 32

  def list_events do
    Event
    |> order_by([event], desc: event.inserted_at)
    |> Repo.all()
  end

  def get_event_by_slug!(slug) do
    Event
    |> where([event], event.slug == ^slug)
    |> Repo.one!()
  end

  def create_event(attrs) do
    owner_token = generate_token()
    invite_token = generate_token()

    event_attrs =
      attrs
      |> normalize_event_attrs()
      |> Map.put_new("slug", generate_slug())
      |> Map.put("owner_token_hash", hash_token(owner_token))
      |> Map.put("invite_token_hash", hash_token(invite_token))

    creator_name = blank_to_nil(Map.get(attrs, "creator_name") || Map.get(attrs, :creator_name))

    Multi.new()
    |> Multi.insert(:event, Event.changeset(%Event{}, event_attrs))
    |> maybe_insert_creator(creator_name)
    |> Repo.transaction()
    |> case do
      {:ok, %{event: event} = result} ->
        {:ok,
         result
         |> Map.put(:event, event)
         |> Map.put(:owner_token, owner_token)
         |> Map.put(:invite_token, invite_token)}

      {:error, _operation, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def change_event(attrs \\ %{}) do
    Event.changeset(%Event{}, attrs)
  end

  def list_participants(event_id) do
    Participant
    |> where([participant], participant.event_id == ^event_id)
    |> order_by([participant], asc: participant.inserted_at, asc: participant.display_name)
    |> Repo.all()
  end

  def create_participant(attrs) do
    attrs = normalize_participant_attrs(attrs)

    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert()
  end

  def verify_owner_token(event_id, token) do
    verify_event_token(event_id, token, :owner_token_hash)
  end

  def verify_invite_token(event_id, token) do
    verify_event_token(event_id, token, :invite_token_hash)
  end

  def submit_participant_with_invite(event_id, invite_token, attrs) do
    with {:ok, event} <- verify_invite_token(event_id, invite_token) do
      submission_token = generate_token()

      attrs =
        attrs
        |> normalize_participant_attrs()
        |> Map.take(["display_name", "rsvp_status", "role"])
        |> Map.put("event_id", event.id)
        |> Map.put("review_status", "pending")
        |> Map.put("submission_token_hash", hash_token(submission_token))

      %Participant{}
      |> Participant.changeset(attrs)
      |> Repo.insert()
      |> case do
        {:ok, participant} ->
          {:ok, %{participant: participant, submission_token: submission_token}}

        {:error, changeset} ->
          {:error, changeset}
      end
    end
  end

  def verify_submission_token(event_id, participant_id, token) do
    with {:ok, token_hash} <- token_hash_for_verification(token),
         %Participant{} = participant <- get_participant_for_event(event_id, participant_id),
         true <- secure_token_match?(participant.submission_token_hash, token_hash) do
      {:ok, participant}
    else
      _ -> {:error, :unauthorized}
    end
  end

  def update_participant_with_submission(event_id, participant_id, submission_token, attrs) do
    with {:ok, participant} <- verify_submission_token(event_id, participant_id, submission_token),
         true <- participant.review_status in ["pending", "accepted"] do
      participant
      |> Participant.changeset(safe_participant_self_edit_attrs(attrs))
      |> Repo.update()
    else
      _ -> {:error, :unauthorized}
    end
  end

  def review_participant(event_id, participant_id, owner_token, target_status) do
    with {:ok, event} <- verify_owner_token(event_id, owner_token),
         %Participant{} = participant <- get_participant_for_event(event.id, participant_id),
         true <- valid_review_transition?(participant.review_status, target_status) do
      participant
      |> Participant.changeset(%{"review_status" => target_status})
      |> Repo.update()
    else
      _ -> {:error, :unauthorized}
    end
  end

  def list_items(event_id) do
    Item
    |> where([item], item.event_id == ^event_id)
    |> order_by([item], asc: item.status, asc: item.inserted_at)
    |> Repo.all()
  end

  def create_item(attrs) do
    %Item{}
    |> Item.changeset(normalize_item_attrs(attrs))
    |> Repo.insert()
  end

  def update_item(id, attrs) do
    Item
    |> Repo.get!(id)
    |> Item.changeset(normalize_item_attrs(attrs))
    |> Repo.update()
  end

  def delete_item(id) do
    Item
    |> Repo.get!(id)
    |> Repo.delete()
  end

  def list_proposals(event_id) do
    Proposal
    |> where([proposal], proposal.event_id == ^event_id)
    |> order_by([proposal], asc: proposal.proposal_type, desc: proposal.inserted_at)
    |> preload(:votes)
    |> Repo.all()
  end

  def create_proposal(attrs) do
    %Proposal{}
    |> Proposal.changeset(normalize_proposal_attrs(attrs))
    |> Repo.insert()
  end

  def create_vote(attrs) do
    %Vote{}
    |> Vote.changeset(normalize_vote_attrs(attrs))
    |> Repo.insert()
  end

  def list_comments(event_id) do
    ThreadComment
    |> where([comment], comment.event_id == ^event_id)
    |> order_by([comment], asc: comment.inserted_at)
    |> Repo.all()
  end

  def create_comment(attrs) do
    %ThreadComment{}
    |> ThreadComment.changeset(attrs)
    |> Repo.insert()
  end

  defp maybe_insert_creator(multi, nil), do: multi

  defp maybe_insert_creator(multi, creator_name) do
    Multi.insert(multi, :creator, fn %{event: event} ->
      Participant.changeset(%Participant{}, %{
        event_id: event.id,
        display_name: creator_name,
        rsvp_status: "going",
        role: "starter",
        review_status: "accepted"
      })
    end)
  end

  defp normalize_event_attrs(attrs) do
    attrs
    |> stringify_keys()
    |> Map.take(["title", "slug", "event_type", "description", "starts_at", "location"])
    |> Map.put_new("event_type", "potluck")
    |> normalize_datetime("starts_at")
    |> normalize_blanks(["description", "location"])
  end

  defp normalize_participant_attrs(attrs) do
    attrs
    |> stringify_keys()
    |> Map.update("rsvp_status", "going", &normalize_rsvp_status/1)
    |> Map.put_new("review_status", "accepted")
  end

  defp safe_participant_self_edit_attrs(attrs) do
    attrs
    |> stringify_keys()
    |> Map.take(["display_name", "rsvp_status", "role"])
    |> Map.update("rsvp_status", "going", &normalize_rsvp_status/1)
  end

  defp normalize_item_attrs(attrs) do
    attrs
    |> stringify_keys()
    |> rename_key("assigned_to", "owner_name")
    |> rename_key("dietary_tags", "tags")
    |> Map.update("tags", [], &parse_tags/1)
    |> Map.put_new("status", "unassigned")
  end

  defp normalize_proposal_attrs(attrs) do
    attrs = stringify_keys(attrs)

    details =
      case blank_to_nil(Map.get(attrs, "details_text")) do
        nil -> Map.get(attrs, "details", %{})
        notes -> %{"notes" => notes}
      end

    attrs
    |> Map.take(["event_id", "proposal_type", "title", "proposed_by_name", "status"])
    |> Map.put("details", details)
    |> Map.put_new("status", "open")
    |> normalize_blanks(["proposed_by_name"])
  end

  defp normalize_vote_attrs(attrs) do
    attrs
    |> stringify_keys()
    |> Map.update("weight", 1, &normalize_vote_weight/1)
    |> normalize_blanks(["voter_name"])
  end

  defp normalize_datetime(params, key) do
    case Map.get(params, key) do
      nil ->
        params

      "" ->
        Map.put(params, key, nil)

      %DateTime{} ->
        params

      value when is_binary(value) ->
        value = String.replace(value, " ", "T")

        parsed =
          case NaiveDateTime.from_iso8601(value) do
            {:ok, ndt} -> {:ok, ndt}
            _ -> NaiveDateTime.from_iso8601(value <> ":00")
          end

        case parsed do
          {:ok, ndt} -> Map.put(params, key, DateTime.from_naive!(ndt, "Etc/UTC"))
          _ -> params
        end

      _ ->
        params
    end
  end

  defp normalize_blanks(params, keys) do
    Enum.reduce(keys, params, fn key, acc ->
      case Map.get(acc, key) do
        value when is_binary(value) -> Map.put(acc, key, blank_to_nil(value))
        _ -> acc
      end
    end)
  end

  defp blank_to_nil(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      text -> text
    end
  end

  defp blank_to_nil(value), do: value

  defp stringify_keys(attrs) do
    Map.new(attrs, fn {key, value} -> {to_string(key), value} end)
  end

  defp rename_key(params, old_key, new_key) do
    case Map.pop(params, old_key) do
      {nil, params} -> params
      {value, params} -> Map.put(params, new_key, value)
    end
  end

  defp normalize_rsvp_status("yes"), do: "going"
  defp normalize_rsvp_status("no"), do: "not_going"
  defp normalize_rsvp_status(status) when status in ["going", "maybe", "not_going"], do: status
  defp normalize_rsvp_status(_status), do: "maybe"

  defp normalize_vote_weight(weight) when is_integer(weight), do: weight

  defp normalize_vote_weight(weight) when is_binary(weight) do
    case Integer.parse(weight) do
      {int, ""} -> int
      _ -> 1
    end
  end

  defp normalize_vote_weight(_weight), do: 1

  defp parse_tags(tags) when is_binary(tags) do
    tags
    |> String.split([",", ";"], trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp parse_tags(tags) when is_list(tags), do: tags
  defp parse_tags(_tags), do: []

  defp verify_event_token(event_id, token, token_hash_field) do
    with {:ok, token_hash} <- token_hash_for_verification(token),
         %Event{} = event <- get_event(event_id),
         stored_hash when is_binary(stored_hash) <- Map.get(event, token_hash_field),
         true <- secure_token_match?(stored_hash, token_hash) do
      {:ok, event}
    else
      _ -> {:error, :unauthorized}
    end
  end

  defp get_event(event_id) do
    Repo.get(Event, event_id)
  rescue
    Ecto.Query.CastError -> nil
    Ecto.CastError -> nil
  end

  defp get_participant_for_event(event_id, participant_id) do
    Participant
    |> where([participant], participant.event_id == ^event_id)
    |> where([participant], participant.id == ^participant_id)
    |> Repo.one()
  rescue
    Ecto.Query.CastError -> nil
    Ecto.CastError -> nil
  end

  defp token_hash_for_verification(token) when is_binary(token) do
    case String.trim(token) do
      "" -> {:error, :unauthorized}
      trimmed_token -> {:ok, hash_token(trimmed_token)}
    end
  end

  defp token_hash_for_verification(_token), do: {:error, :unauthorized}

  defp secure_token_match?(stored_hash, candidate_hash)
       when is_binary(stored_hash) and is_binary(candidate_hash) and
              byte_size(stored_hash) == byte_size(candidate_hash) do
    Plug.Crypto.secure_compare(stored_hash, candidate_hash)
  end

  defp secure_token_match?(_stored_hash, _candidate_hash), do: false

  defp valid_review_transition?(status, status)
       when status in ~w(pending accepted rejected excluded) do
    true
  end

  defp valid_review_transition?("pending", target_status)
       when target_status in ~w(accepted rejected excluded) do
    true
  end

  defp valid_review_transition?("accepted", "excluded"), do: true
  defp valid_review_transition?(_current_status, _target_status), do: false

  defp generate_token do
    @token_bytes
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end

  defp hash_token(token) do
    :crypto.hash(:sha256, token)
    |> Base.url_encode64(padding: false)
  end

  defp generate_slug do
    6
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> String.replace(~r/[^a-zA-Z0-9]/, "")
    |> String.downcase()
    |> String.slice(0, 10)
  end
end
