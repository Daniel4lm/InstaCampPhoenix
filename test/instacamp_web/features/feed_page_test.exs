defmodule InstacampWeb.Features.FeedPageTest do
  use InstacampWeb.FeatureCase

  import Instacamp.AccountsFixtures
  import Instacamp.BlogFixtures

  alias Instacamp.Posts

  setup %{session: session} do
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
        user_1,
        :new,
        %{
          "title" => "Elixir and Phoenix web development"
        },
        ["elixir", "dev", "phoenix"]
      )

    _post_2 =
      blog_post_fixture(%Posts.Post{}, user_1, :new, %{"title" => "Service informations"}, [
        "info",
        "service",
        "city"
      ])

    _post_3 =
      blog_post_fixture(
        %Posts.Post{},
        user_1,
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
      blog_post_fixture(%Posts.Post{}, user_2, :new, %{"title" => "Tag All the Things!"}, [
        "people"
      ])

    session =
      session
      |> visit_login_path()
      |> log_in_user("john@mail.org", "Valid_password")

    %{sessions: session, user_1: user_1, user_2: user_2}
  end

  feature "user visits root path, renders list of posts", %{
    session: session,
    user_1: _user_1,
    user_2: _user_2
  } do
    session
    |> assert_text("Welcome back!")
    |> assert_has(Query.css("#post-filter-container"))
    |> assert_has(Query.css("#posts-feed"))
    |> assert_has(Query.css("[id^='feed-item-']", count: 5))
    |> assert_text("Filter posts")
    |> fill_in(Query.css(~s([name="post_filter[author]"])), with: "john")
    |> send_keys([:enter])
    |> assert_has(Query.css("[id^='feed-item-']", count: 3))
    |> assert_text("Elixir and Phoenix web development")
    |> assert_text("Service informations")
    |> assert_text("Using fetch with TypeScript")
    |> fill_in(Query.css(~s([name="post_filter[author]"])), with: "daniel")
    |> send_keys([:enter])
    |> assert_has(Query.css("[id^='feed-item-']", count: 0))
    |> assert_text("Empty list or no results match this query!")
    |> clear(Query.css(~s([name="post_filter[author]"])))
    |> fill_in(Query.css(~s([name="post_filter[title]"])), with: "elixir")
    |> click(Query.text("Submit"))
    |> assert_has(Query.css("[id^='feed-item-']", count: 2))
    |> assert_text("Elixir and Phoenix web development")
    |> assert_text("Super Simple Start with Elixir")
    |> click(Query.css("[id^='feed-item-']", text: "Elixir and Phoenix web development"))
    |> assert_has(Query.css("#post-tags"))
    |> assert_text("#elixir")
    |> click(Query.text("#elixir"))
    |> assert_has(Query.css("[id^='feed-item-']", count: 3))
    |> click(Query.text("Reset filter"))
    |> assert_has(Query.css("[id^='feed-item-']", count: 5))
    |> touch_down(Query.css("#infinite-scroll-marker"), 0, 0)

    find(session, Query.css("[id^='feed-item-']", count: 6))

    session
    |> visit("/?with_comments=true")
    |> assert_has(Query.css("[id^='feed-item-']", count: 0))
    |> assert_text("Empty list or no results match this query!")
  end
end
