defmodule Instacamp.NotificationsTest do
  use Instacamp.DataCase, async: true

  import Instacamp.AccountsFixtures
  import Instacamp.BlogFixtures

  alias Instacamp.Notifications

  defp create_deps(_attrs) do
    user = user_fixture()
    second_user = user_fixture()
    post = blog_post_fixture(user, :new)
    comment = blog_comment_fixture(post, second_user)

    _post_like = like_fixture(second_user, :post, post)
    _comment_like = like_fixture(user, :comment, comment)

    %{user: user, second_user: second_user, post: post, comment: comment}
  end

  describe "test notifications" do
    setup [:create_deps]

    test "list_notifications/0 returns all notifications" do
      assert [_notification_1, _notification_2, _notification_3] =
               Notifications.list_notifications()
    end

    test "list_user_notifications/1 returns the list of notifications related to the user", %{
      user: user,
      second_user: second_user,
      post: post
    } do
      assert [_notification_1, _notification_2] = Notifications.list_user_notifications(user.id)
      assert [comment_like_notify] = Notifications.list_user_notifications(second_user.id)

      post_like_notification = Notifications.get_post_notification(second_user.id, post)
      assert post_like_notification.action_type == "post_like"

      assert comment_like_notify.action_type == "comment_like"
    end

    test "all_unread?/1 checks if all user notifications are read", %{
      user: user
    } do
      assert true == Notifications.all_unread?(user.id)
      assert :ok == Notifications.read_all(user.id)
      assert false == Notifications.all_unread?(user.id)
    end
  end
end
