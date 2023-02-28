defmodule InstacampWeb.Features.AuthTest do
  use InstacampWeb.FeatureCase

  feature "user signs up and changes user settings", %{session: session} do
    session
    |> visit_root_path()
    |> assert_text("Sign Up")
    |> click(Query.link("Sign Up"))
    |> assert_text("Sign up to see post and videos from your friends.")
    |> fill_in(Query.css(~s([name="user[email]")), with: "john@mail.org")
    |> fill_in(Query.css(~s([name="user[full_name]")), with: "John Kiwi")
    |> fill_in(Query.css(~s([name="user[location]")), with: "San Francisco")
    |> fill_in(Query.css(~s([name="user[username]")), with: "john_4k")
    |> fill_in(Query.css(~s([name="user[password]")), with: "Valid_password")
    |> click(Query.button("Sign up"))

    session
    |> find(Query.css(".alert-info"))
    |> assert_text("Welcome John Kiwi. Your account is created successfully!")

    photo_field = file_field("avatar_url")

    session
    |> log_in_user("john@mail.org", "InValid_password")
    |> wait(400)
    |> log_in_user("john@mail.org", "Valid_password")
    |> wait(400)
    |> assert_text("InstaCamp")
    |> assert_has(Query.css("[id='user-avatar']"))
    |> click(Query.css("[id='user-avatar']"))
    |> assert_has(Query.css("[id='settings-menu']"))
    |> assert_text("John Kiwi")
    |> assert_text("john@mail.org")
    |> assert_text("My profile")
    |> assert_text("Saved list")
    |> assert_text("Log Out")
    |> click(Query.link("My profile"))
    |> assert_text("John Kiwi")
    |> assert_text("Location San Francisco")
    |> assert_text("Edit Profile")
    |> assert_text("Posts 0")
    |> assert_text("Followers 0")
    |> assert_text("Following 0")
    |> click(Query.link("Edit Profile"))
    |> assert_text("Edit Profile")
    |> assert_text("Change Password")
    |> assert_text("Full name")
    |> assert_text("Username")
    |> fill_in(Query.css(~s([name="user[full_name]"])), with: "Joh")
    |> wait(400)
    |> assert_text("Full name should be at least 4 character(s)")
    |> fill_in(Query.css(~s([name="user[full_name]"])), with: "John Smith")
    |> wait(400)
    |> fill_in(Query.css(~s([name="user[location]"])), with: "London")
    |> wait(400)
    |> fill_in(Query.css(~s([name="user[bio]"])), with: "Something about me...")
    |> wait(400)
    |> attach_file(photo_field, path: "test/support/blog_image.jpg")
    |> click(Query.button("Submit"))

    find(session, photo_field, fn e ->
      value = Wallaby.Element.value(e)
      assert value =~ "blog_image.jpg"
    end)

    session
    |> assert_has(Query.css(".alert-info"))
    |> assert_text("User updated successfully!")

    session
    |> click(Query.css("[id='user-avatar']"))
    |> assert_text("John Smith")
    |> wait(1000)
  end
end
