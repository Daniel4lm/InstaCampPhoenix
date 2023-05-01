defmodule InstacampWeb.Features.PostsTest do
  use InstacampWeb.FeatureCase

  import Instacamp.AccountsFixtures
  import Instacamp.BlogFixtures

  alias Instacamp.Posts

  alias Wallaby.Query

  setup %{sessions: [session_1, session_2]} do
    user_1 =
      user_fixture(
        email: "john@mail.org",
        username: "john_4",
        full_name: "John Kiwi",
        location: "San Marino",
        password: "Valid_password"
      )

    user_2 =
      user_fixture(
        email: "damir@mail.org",
        username: "damir_m",
        full_name: "Damir",
        location: "Sarajevo",
        password: "Damirs_password"
      )

    _post_1 =
      blog_post_fixture(
        %Posts.Post{},
        user_2,
        :new,
        %{
          "title" => "Phoenix LiveView Streams"
        },
        ["stream", "liveview", "phoenix"]
      )

    _post_2 =
      blog_post_fixture(%Posts.Post{}, user_2, :new, %{"title" => "Service informations"}, [
        "info",
        "service",
        "city"
      ])

    _post_3 =
      blog_post_fixture(
        %Posts.Post{},
        user_2,
        :new,
        %{"title" => "Using fetch with TypeScript"},
        ["typescript"]
      )

    _post_4 =
      blog_post_fixture(
        %Posts.Post{},
        user_2,
        :new,
        %{
          "title" => "Super Simple Start with Elixir"
        },
        ["elixir", "dev"]
      )

    _post_5 =
      blog_post_fixture(
        %Posts.Post{},
        user_2,
        :new,
        %{"title" => "Making Tabs Mobile Friendly"}
      )

    _post_6 =
      blog_post_fixture(
        %Posts.Post{},
        user_2,
        :new,
        %{"title" => "Custom fonts with Phoenix and Tailwind CSS"}
      )

    session_1 =
      session_1
      |> visit_login_path()
      |> log_in_user("john@mail.org", "Valid_password")

    session_2 =
      session_2
      |> visit_login_path()
      |> log_in_user("damir@mail.org", "Damirs_password")

    %{sessions: [session_1, session_2], user_1: user_1, user_2: user_2}
  end

  @tag timeout: 90_000
  @sessions 2
  feature "users can create new post, like it, comment and follow each other", %{
    sessions: [session_1, session_2],
    user_1: user_1,
    user_2: user_2
  } do
    session_1
    |> assert_text("Welcome back!")
    |> visit("/new/post")
    |> assert_text("New blog post")
    |> fill_in(Query.css(~s([name="post[title]"])), with: "Eli")
    |> wait(400)
    |> fill_in(Query.css(~s([input="body_input"])),
      with: "Hello there"
    )
    |> wait(400)
    |> assert_text("Message title should be at least 5 character(s)")
    |> fill_in(Query.css(~s([name="post[title]"])), with: "Elixir development")
    |> wait(400)
    |> fill_in(Query.css(~s([name="post[tag]"])), with: "elixir")
    |> send_keys([:enter])
    |> fill_in(Query.css(~s([name="post[tag]"])), with: "tz")
    |> send_keys([:enter])
    |> assert_has(Query.css("#post-topic-elixir"))
    |> assert_text("#elixir")
    |> fill_in(Query.css(~s([name="post[tag]"])), with: "dev,")
    |> send_keys([:enter])
    |> assert_has(Query.css("#post-topic-dev"))
    |> assert_text("#dev")
    |> fill_in(Query.css(~s([input="body_input"])),
      with:
        "Hello there - Blog post with some text about development with Elixir and the Phoenix Framework"
    )
    |> send_keys([:enter])
    |> click(Query.css(~s([input="body_input"])))
    |> click(Query.button("Submit"))

    session_1
    |> assert_has(Query.text(user_1.full_name))
    |> assert_text("Edit Profile")
    |> assert_text("Posts 1")
    |> assert_text("Location " <> user_1.location)
    |> assert_text("Following 0")
    |> assert_has(Query.css("[id^='post-card-']", count: 1))
    |> assert_has(Query.css(~s([id^="post-topic-"]), count: 2))
    |> assert_text("#dev")
    |> assert_text("#elixir")
    |> assert_text("Elixir development")
    |> click(Query.link("Elixir development"))
    |> assert_text(user_1.full_name)
    |> assert_text("Elixir development")
    |> click(Query.css(~s([id="post-total-comments"])))
    |> assert_text("No comments yet")
    |> click(Query.css(~s([id="post-options-icon"])))
    |> assert_text("Copy link")
    |> click(Query.text("Copy link"))
    |> assert_text("Copied to Clipboard")
    |> assert_text("Delete post")
    |> assert_text("Edit post")
    |> click(Query.link("Edit post"))
    |> assert_text("Edit blog post")
    |> fill_in(Query.css(~s([name="post[title]"])), with: "Elixir and Phoenix development")
    |> wait(400)
    |> fill_in(Query.css(~s([name="post[tag]"])), with: "phoenix")
    |> send_keys([:enter])
    |> click(Query.button("Submit"))
    |> assert_has(Query.text("Edit Profile"))
    |> assert_has(Query.css(~s([id^="post-topic-"]), count: 3))
    |> assert_text("#dev")
    |> assert_text("#elixir")
    |> assert_text("#phoenix")
    |> assert_text("Elixir and Phoenix development")
    |> click(Query.link("Elixir and Phoenix development"))
    |> assert_text("Elixir and Phoenix development")

    # FIXME: Finish when we implement delete modal
    # |> click(Query.css(~s([id="post-options-icon"])))
    # |> assert_text("Delete post")
    # |> accept_prompt([with: "You want to delete post?"], fn session ->
    #   click(session, link("Delete post"))
    # end)

    session_2
    |> assert_text("Welcome back!")
    |> assert_has(Query.css("[id='user-avatar']"))
    |> click(Query.css("[id='user-avatar']"))
    |> assert_has(Query.css("[id='settings-menu']"))
    |> assert_text("Damir")
    |> assert_text("damir@mail.org")
    |> click(Query.css("[id='user-avatar']"))
    |> visit("/user/" <> user_1.username)
    |> assert_text(user_1.full_name)
    |> assert_has(Query.css("[id='follow-component']", text: "Follow"))
    |> assert_text("Posts 1")
    |> assert_text("Followers 0")
    |> assert_text("Following 0")
    |> click(Query.css("[id='follow-component']"))
    |> assert_has(Query.text("Unfollow"))
    |> assert_text("Followers 1")
    |> assert_text("Elixir and Phoenix development")
    |> click(Query.link("Elixir and Phoenix development"))
    |> assert_has(Query.css("[id='post-total-likes']", text: "0"))
    |> assert_has(Query.css("[id^='like-component-']"))
    |> click(Query.css("[id^='like-component-']"))
    |> assert_has(Query.css("[id='post-total-likes']", text: "1"))

    session_1
    |> assert_text("1 likes")
    |> click(Query.css("[id='notifications']"))
    |> assert_text(user_2.username <> " started following you")
    |> assert_text(user_2.username <> " liked your post")
    |> send_keys([:escape])

    session_2
    |> click(Query.css("[id='post-comment-icon']"))
    |> fill_in(Query.css(~s([input="body_input"])), with: "My first comment")
    |> wait(400)
    |> click(Query.button("Submit"))
    |> wait(400)
    |> assert_has(Query.text("Comments:"))
    |> assert_text("My first comment")

    session_1
    |> assert_text("1 comments")
    |> assert_text("Comments:")
    |> assert_text("My first comment")
    |> click(Query.css("[id='notifications']"))
    |> assert_text(user_2.username <> " commented on your post")
    |> send_keys([:escape])

    session_2
    |> click(Query.css("[id^='comments-option-']"))
    |> assert_text("Delete")
    |> assert_text("Edit")
    |> click(Query.text("Edit"))
    |> assert_text("Editing comment")
    |> fill_in(Query.css(~s([input="comment_body"])), with: "My edited comment")
    |> wait(400)
    |> click(Query.button("Save"))
    |> assert_text("My edited comment")

    session_2
    |> click(Query.css("[id^='tag-component-']"))
    |> assert_has(Query.css("[id='post-bookmarks-count']", text: "1"))
    |> visit("/user/" <> user_2.username)
    |> assert_text("Followers 0")

    session_1
    |> assert_has(Query.css("[id='post-bookmarks-count']", text: "1"))
    |> visit("/user/" <> user_1.username)
    |> assert_text("Followers 1")
    |> click(Query.css("[id='profile-followers-count']"))
    |> assert_has(Query.css("[id='follow-list-title']", text: "Followers"))
    |> assert_has(Query.css("[id^='follow-name-']", text: "Damir"))
    |> assert_has(Query.css("[id='follow-component']", text: "Follow"))
    |> click(Query.css("[id='follow-component']"))
    |> assert_has(Query.css("[id='follow-component']", text: "Unfollow"))
    |> send_keys([:escape])

    session_2
    |> assert_text("Followers 1")
    |> assert_text("Following 1")

    session_1
    |> assert_has(Query.css("[id='profile-followers-count']"))
    |> click(Query.css("[id='profile-followers-count']"))
    |> assert_has(Query.css("[id='follow-list-title']", text: "Followers"))
    |> assert_has(Query.css("[id^='follow-name-']", text: "Damir"))
    |> click(Query.css("[id='follow-component']", text: "Unfollow"))
    |> assert_has(Query.css("[id='follow-component']", text: "Follow"))
    |> send_keys([:escape])
    |> assert_text("Following 0")
    |> click(Query.link("Elixir and Phoenix development"))
    |> assert_has(Query.css("[id^='comment-container-']", count: 1))
    |> assert_has(Query.css("[id^='user-comment-']", count: 1))
    |> assert_has(Query.css("[id^='likes-count-for-']", text: "0 Likes"))
    |> click(Query.css("[id^='like-component-']", at: 0))
    |> assert_has(Query.css("[id^='likes-count-for-']", text: "1 Likes"))

    session_2
    |> assert_text("Followers 0")
    |> assert_text("Following 1")
    |> click(Query.css("[id='notifications']"))
    |> assert_text(user_1.username <> " liked your comment")
    |> send_keys([:escape])
    |> assert_has(Query.css("[id^='post-card-']", count: 5))
    |> touch_down(Query.css("#infinite-scroll-marker"), 0, 0)

    find(session_2, Query.css("[id^='post-card-']", count: 6))

    session_2
    |> visit("/user/" <> user_1.username)
    |> assert_text("Elixir and Phoenix development")
    |> click(Query.link("Elixir and Phoenix development"))
    |> click(Query.css("[id='post-comment-icon']"))
    |> assert_has(Query.text("Comments:"))
    |> assert_text("My edited comment")
    |> assert_has(Query.css("[id^='likes-count-for-']", text: "1 Likes"))
    |> click(Query.css("[id^='likes-count-for-']", at: 0))
    |> assert_has(Query.css("[id^='users-list-for-']"))
    |> hover(Query.css("[id^='user-hover-item']"))
    |> assert_has(Query.text(user_1.username))
    |> click(Query.css("[id^='comments-option-']"))
    |> assert_text("Delete")

    _delete_message =
      accept_confirm(session_2, fn s ->
        click(s, Query.text("Delete"))
      end)

    session_2
    |> assert_text("No comments yet")
    |> refute_has(Query.text("My edited comment"))

    session_1
    |> assert_text("No comments yet")
    |> assert_text("0 comments")
    |> visit("/user/" <> user_1.username)

    session_2
    |> click(Query.css("[id='post-comment-icon']"))
    |> fill_in(Query.css(~s([input="body_input"])), with: "My second comment")
    |> click(Query.button("Submit"))
    |> assert_has(Query.text("Comments:"))
    |> fill_in(Query.css(~s([input="body_input"])), with: "My third comment")
    |> click(Query.button("Submit"))
    |> fill_in(Query.css(~s([input="body_input"])), with: "My fourth comment")
    |> click(Query.button("Submit"))
    |> fill_in(Query.css(~s([input="body_input"])), with: "My fifth comment")
    |> click(Query.button("Submit"))
    |> fill_in(Query.css(~s([input="body_input"])), with: "My sixth comment")
    |> click(Query.button("Submit"))
    |> fill_in(Query.css(~s([input="body_input"])), with: "My seventh comment")
    |> click(Query.button("Submit"))
    |> assert_text("My second comment")
    |> assert_text("My seventh comment")

    session_1
    |> click(Query.link("Elixir and Phoenix development"))
    |> click(Query.css("[id='post-comment-icon']"))
    |> click(Query.css("[id='notifications']"))
    |> assert_has(
      Query.css("[id^='notification-comment-']",
        text: user_2.username <> " commented on your post",
        count: 6
      )
    )
    |> send_keys([:escape])
    |> assert_text("6 comments")
    |> assert_has(Query.css("[id^='user-comment-']", count: 5))
    |> touch_down(Query.css("#load-more-comments-btn"), 0, 0)
    |> assert_text("More comments")
    |> click(Query.css("#load-more-comments-btn"))
    |> assert_has(Query.css("[id^='user-comment-']", count: 6))

    find(session_1, Query.css("[id^='user-comment-']", text: "My fourth comment"), fn comment ->
      comment
      |> assert_text("My fourth comment")
      |> assert_has(Query.css("[id^='reply-to-comment-']", text: "Reply"))
      |> click(Query.text("Reply"))
    end)

    find(session_1, Query.css("#change-comment-comp"))

    session_1
    |> wait(400)
    |> assert_text("Reply to")
    |> fill_in(Query.css(~s([input="comment_body"])), with: "My reply to the fourth comment")
    |> wait(400)
    |> click(Query.button("Save"))
    |> assert_has(Query.text("My reply to the fourth comment", count: 1))
    |> touch_down(Query.css("#load-more-comments-btn"), 0, 0)
    |> assert_text("More comments")
    |> click(Query.css("#load-more-comments-btn"))
    |> assert_has(Query.css("[id^='reply-button-for-']", text: "1 Reply"))
    |> click(Query.text("1 Reply"))
    |> assert_has(Query.css("[id^='reply-list-for-']"))
    |> assert_has(Query.text("My reply to the fourth comment", count: 2))

    session_2
    |> assert_has(Query.text("My reply to the fourth comment", count: 1))
    |> assert_has(Query.css("[id^='user-comment-']", text: "My fourth comment"))
    |> click(Query.css("[id='notifications']"))
    |> assert_text(user_1.username <> " replied to your comment")
    |> send_keys([:escape])
  end
end
