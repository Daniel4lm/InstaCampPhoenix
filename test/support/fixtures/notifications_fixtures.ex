defmodule Instacamp.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Instacamp.Notifications` context.
  """

  alias Instacamp.Accounts
  alias Instacamp.Posts
  alias Instacamp.Repo

  @doc """
  Generate post like notification.
  """
  def post_notification_fixture(%Posts.Post{} = post, %Accounts.User{} = author) do
    {:ok, notification} =
      post
      |> Instacamp.Notifications.create_post_notification(author)
      |> Repo.insert()

    notification
  end

  @doc """
  Generate following notification.
  """
  def following_notification_fixture(%Accounts.User{} = user, %Accounts.User{} = follower) do
    {:ok, notification} =
      follower
      |> Instacamp.Notifications.create_following_notification(user)
      |> Repo.insert()

    notification
  end
end
