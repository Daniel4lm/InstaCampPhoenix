defmodule Instacamp.BlogTest do
  use Instacamp.DataCase, async: true

  import Instacamp.AccountsFixtures
  import Instacamp.BlogFixtures

  alias Instacamp.Posts
  alias Instacamp.Repo

  @valid_post_attrs %{
    "body" =>
      "This morning the view from the window was beautiful. A little heavier snow fell, but soon it started to melt...",
    "title" => "Post title",
    "tags" => []
  }

  @invalid_post_attrs %{"body" => nil, "title" => "Awesome title", "tags" => []}

  defp create_blog_deps(_attrs) do
    user = user_fixture()
    post = blog_post_fixture(user, :new)
    comment = blog_comment_fixture(post, user)
    %{user: user, post: post, comment: comment}
  end

  describe "blog_posts changeset & register" do
    setup [:create_blog_deps]

    test "change_post/2 returns valid changeset", %{
      post: _post
    } do
      assert %Ecto.Changeset{} =
               blog_post_changeset = Posts.change_post(%Posts.Post{}, @valid_post_attrs)

      assert blog_post_changeset.valid?
    end

    test "change_post/2 returns invalid changeset" do
      blog_post_changeset =
        Posts.change_post(
          %Posts.Post{},
          @invalid_post_attrs
        )

      assert "can't be blank" in errors_on(blog_post_changeset).body

      refute blog_post_changeset.valid?
    end

    test "change_post/2 returns invalid changeset when title is too short" do
      blog_post_changeset =
        Posts.change_post(
          %Posts.Post{},
          %{
            body:
              "This morning the view from the window was beautiful. A little heavier snow fell, but soon it started to melt...",
            title: "Post"
          }
        )

      assert "Message title should be at least 5 character(s)" in errors_on(blog_post_changeset).title

      refute blog_post_changeset.valid?
    end
  end

  describe "test blog posts" do
    setup [:create_blog_deps]

    test "list_blog_posts/0 returns a list of all blog posts" do
      refute Enum.empty?(Posts.list_posts())
    end

    test "list posts", %{user: user} do
      tags = blog_tag_fixture(["nature", "winter", "city"])

      assert {:ok, %Posts.Post{} = post_2} =
               Posts.create_or_update_post(%Posts.Post{}, user, :new, %{
                 "body" =>
                   "This morning the view from the window was beautiful. A little heavier snow fell, but soon it started to melt...",
                 "title" => "Beautiful nature",
                 "tags" => tags
               })

      assert {:ok, %Posts.Post{} = _post_3} =
               Posts.create_or_update_post(%Posts.Post{}, user, :new, %{
                 "body" =>
                   "Today I froze, it can last me the whole winter. After the cold and wind, snow could fall.",
                 "title" => "Service Information",
                 "tags" => tags
               })

      all_posts = Posts.list_posts()
      assert Enum.count(all_posts) == 3

      [term_post] = Posts.search_posts_by_term("nature")

      assert term_post.title == post_2.title
      assert term_post.user_id == post_2.user_id

      posts_by_tag_name = Posts.search_posts_by_tag("nature")
      assert Enum.count(posts_by_tag_name) == 2
    end

    test "get_post!/1 returns the post with blog user, likes and tags preloaded", %{
      post: post
    } do
      assert %Posts.Post{} = post_from_db = Posts.get_post!(post.id)

      assert post_from_db.user.id == post.user_id
      assert "elixir" in Enum.map(post_from_db.tags, & &1.name)
    end

    test "get_post_by_slug!/1 returns the post by slug", %{
      post: post
    } do
      assert %Posts.Post{} = post_from_db = Posts.get_post_by_slug!(post.slug)

      assert post_from_db.slug == post.slug
    end

    test "calculate_read_time/1 returns the estimated post read time", %{
      post: post
    } do
      post_ert = Posts.calculate_read_time(post)

      assert post_ert <= 1
    end
  end

  describe "test blog create, update and delete" do
    setup [:create_blog_deps]

    test "create_or_update_post/4 with valid data creates a blog post", %{
      post: _post,
      user: user
    } do
      assert {:ok, %Posts.Post{} = post} =
               Posts.create_or_update_post(%Posts.Post{}, user, :new, @valid_post_attrs)

      assert post.body == @valid_post_attrs["body"]
      assert post.title == @valid_post_attrs["title"]
    end

    test "create_or_update_post/4 with invalid data returns error changeset", %{
      post: _post,
      user: user
    } do
      assert {:error, %Ecto.Changeset{}} =
               Posts.create_or_update_post(%Posts.Post{}, user, :new, @invalid_post_attrs)
    end

    test "create_or_update_post/4 updates the post", %{
      post: post,
      user: user
    } do
      blog_post_peloaded = Repo.preload(post, [:user, :tags])
      new_tags = blog_tag_fixture(["sport", "health"])

      update_attrs = %{
        "body" =>
          "It's different in the city, but there is snow on the hills and mountains. Of course, the problems on the roads started right away...",
        "title" => "Some updated title",
        "tags" => blog_post_peloaded.tags ++ new_tags
      }

      assert {:ok, %Posts.Post{} = updated_post} =
               Posts.create_or_update_post(blog_post_peloaded, user, :edit, update_attrs)

      assert updated_post.id == blog_post_peloaded.id
      assert updated_post.body == update_attrs["body"]
      assert updated_post.title == update_attrs["title"]
      assert Enum.count(updated_post.tags) == 5
    end

    test "create_or_update_post/4 does not update the post", %{
      post: post,
      user: user
    } do
      update_attrs = %{"title" => "Post title", "tags" => []}

      blog_post_peloaded = Repo.preload(post, [:user])

      assert {:ok, %Posts.Post{} = post} =
               Posts.create_or_update_post(blog_post_peloaded, user, :edit, update_attrs)

      assert post.title == "Post title"
    end

    test "delete_post/1 deletes the post", %{
      post: post,
      user: user
    } do
      assert {:ok, %Posts.Post{}} = Posts.delete_post(post, user)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end
  end

  describe "test post comments" do
    setup [:create_blog_deps]

    test "change_comment/2 returns valid changeset" do
      assert %Ecto.Changeset{} =
               post_comment_changeset =
               Posts.change_comment(%Posts.Comment{}, %{
                 "body" => "Hii. This is my first comment!"
               })

      assert post_comment_changeset.valid?
    end

    test "change_comment/2 returns invalid changeset" do
      assert %Ecto.Changeset{} =
               post_comment_changeset = Posts.change_comment(%Posts.Comment{}, %{"body" => nil})

      refute post_comment_changeset.valid?
    end

    test "create_or_update_comment/5 creates a valid post comment", %{
      post: post,
      user: _user
    } do
      second_user = user_fixture()

      assert {:ok, comment} =
               Posts.create_or_update_comment(%Posts.Comment{}, post, second_user, :new, %{
                 "body" => "Hii. This is my first comment!"
               })

      assert comment.user.id == second_user.id
      assert comment.post_id == post.id
    end

    test "list_post_comments/3 renders all post comments per page", %{
      post: post,
      user: _user,
      comment: _comment
    } do
      second_user = user_fixture()

      assert {:ok, _comment_1} =
               Posts.create_or_update_comment(%Posts.Comment{}, post, second_user, :new, %{
                 "body" => "First comment!"
               })

      assert {:ok, _comment_2} =
               Posts.create_or_update_comment(%Posts.Comment{}, post, second_user, :new, %{
                 "body" => "Second comment!"
               })

      assert {:ok, _comment_3} =
               Posts.create_or_update_comment(%Posts.Comment{}, post, second_user, :new, %{
                 "body" => "Third comment!"
               })

      commented_post = Posts.get_post!(post.id)
      assert commented_post.total_comments == 4

      list_of_post_comments = Posts.list_post_comments(post, 1, 2)
      assert Enum.count(list_of_post_comments) == 2

      updated_list_of_post_comments = Posts.list_post_comments(post, 1, 4)
      assert Enum.count(updated_list_of_post_comments) == 4
    end

    test "create_or_update_comment/2 updates the existing comment", %{
      post: post,
      user: user,
      comment: comment
    } do
      assert {:ok, updated_comment} =
               Posts.create_or_update_comment(comment, post, user, :edit, %{
                 "body" => "This is my second comment"
               })

      assert updated_comment.id == comment.id
      refute updated_comment.body == comment.body
    end

    test "delete_comment/2 deletes the existing comment", %{
      post: post,
      user: _user,
      comment: comment
    } do
      assert {:ok, deleted_comment} = Posts.delete_comment(comment, post)

      assert deleted_comment.id == comment.id
      assert_raise Ecto.NoResultsError, fn -> Posts.get_comment!(deleted_comment.id) end
    end
  end

  describe "test post & comment likes" do
    setup [:create_blog_deps]

    test "users can like or unlike post or comments", %{
      post: post,
      user: user
    } do
      second_user = user_fixture()

      assert {:ok, comment_1} =
               Posts.create_or_update_comment(%Posts.Comment{}, post, second_user, :new, %{
                 "body" => "First comment!"
               })

      assert {:ok, comment_2} =
               Posts.create_or_update_comment(%Posts.Comment{}, post, second_user, :new, %{
                 "body" => "Second comment!"
               })

      assert {:ok, like_from_user_2} = Posts.create_like(second_user, :post, post)
      assert like_from_user_2.liked_id == post.id
      assert like_from_user_2.user_id == second_user.id

      liked_post = Posts.get_post!(post.id)
      assert liked_post.total_likes == 1

      assert {:ok, like_for_comment_1} = Posts.create_like(user, :comment, comment_1)
      assert {:ok, like_for_comment_2} = Posts.create_like(user, :comment, comment_2)

      liked_comment_2 = Posts.get_comment!(like_for_comment_2.liked_id)
      assert liked_comment_2.total_likes == 1

      assert like_for_comment_1.liked_id == comment_1.id
      assert like_for_comment_1.user_id == user.id
      assert like_for_comment_1.liked_id == comment_1.id
      assert like_for_comment_1.user_id == user.id

      assert {:ok, like_for_comment_2} = Posts.unlike(user, :comment, liked_comment_2)
      unliked_comment_1 = Posts.get_comment!(like_for_comment_2.liked_id)
      assert unliked_comment_1.total_likes == 0
    end
  end

  describe "test post bookmark" do
    setup [:create_blog_deps]

    test "users can bookmark/unbookmark the post", %{
      post: post
    } do
      second_user = user_fixture()
      third_user = user_fixture()

      assert {:ok, post_bookmark_1} = Posts.create_bookmark(post, second_user)
      assert {:ok, _post_bookmark_2} = Posts.create_bookmark(post, third_user)

      bookmarked_post =
        post.id
        |> Posts.get_post!()
        |> Repo.preload([:posts_bookmarks])

      assert Enum.count(bookmarked_post.posts_bookmarks) == 2

      bookmarks_count = Posts.count_post_bookmarks(bookmarked_post)
      assert bookmarks_count == 2

      third_bookmark = Posts.is_bookmarked(post, third_user)
      assert third_bookmark.user_id == third_user.id

      assert {:ok, _deleted_bookmark} = Posts.unbookmark(post_bookmark_1)

      second_bookmarked_post =
        post.id
        |> Posts.get_post!()
        |> Repo.preload([:posts_bookmarks])

      second_bookmarks_count = Posts.count_post_bookmarks(second_bookmarked_post)
      assert second_bookmarks_count == 1
    end
  end
end
