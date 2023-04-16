defmodule InstacampWeb.Features.AuthTest do
  use InstacampWeb.FeatureCase

  feature "user signs up and changes user settings", %{session: session} do
    session
    |> visit_root_path()
    |> assert_text("Sign Up")
    |> click(Query.link("Sign Up"))
    |> assert_text("Sign up to see post and videos from your friends")
    |> fill_in(Query.css(~s([name="user[email]")), with: "john@mail.org")
    |> fill_in(Query.css(~s([name="user[full_name]")), with: "John Kiwi")
    |> fill_in(Query.css(~s([name="user[location]")), with: "San Francisco")
    |> fill_in(Query.css(~s([name="user[username]")), with: "john_4k")
    |> fill_in(Query.css(~s([name="user[password]")), with: "Valid_password")
    |> click(Query.button("Sign up"))
    |> lazily_refute_has(Query.text("Sign up to see post and videos from your friends"))
    |> wait(400)
    |> assert_text("Welcome John Kiwi. Your account is created successfully!")

    photo_field = file_field("avatar_url")

    session
    |> log_in_user("john@mail.org", "InValid_password")
    |> wait(400)
    |> assert_text("Invalid email or password")
    |> log_in_user("john@mail.org", "Valid_password")
    |> wait(400)
    |> assert_text("Campy")
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
    |> assert_text("Full name should be at least 4 character(s)")
    |> fill_in(Query.css(~s([name="user[full_name]"])), with: "John Smith")
    |> fill_in(Query.css(~s([name="user[location]"])), with: "London")
    |> fill_in(Query.css(~s([name="user[bio]"])), with: "Something about me...")
    |> click(Query.css(~s([for="user-settings-form_settings_theme_mode_dark"])))
    |> attach_file(photo_field, path: "test/support/test_image.jpg")
    |> click(Query.button("Submit"))

    find(session, photo_field, fn e ->
      value = Wallaby.Element.value(e)
      assert value =~ "test_image.jpg"
    end)

    session
    |> assert_has(Query.css("#flash"))
    |> assert_text("User updated successfully!")
    |> click(Query.css("#flash"))
    |> click(Query.css("[id='user-avatar']"))
    |> assert_text("John Smith")
    |> click(Query.css("[id='user-avatar']"))

    # |> attach_file(photo_field, path: "priv/static/images/phoenix.png")
    # |> wait(1000)
    # |> click(Query.button("Submit"))

    # find(session, photo_field, fn e ->
    #   value = Wallaby.Element.value(e)
    #   assert value =~ "phoenix.png"
    # end)

    # session
    # # |> wait(1000)
    # |> assert_text("User updated successfully!")
    # |> click(Query.css("#flash"))

    avatars_path =
      :instacamp
      |> Application.app_dir("priv")
      |> Path.join("uploads/avatars")

    assert File.dir?(avatars_path)

    {:ok, files} = File.ls(avatars_path)

    Enum.map(files, fn file_name ->
      if String.starts_with?(file_name, "test_image-") ||
           String.starts_with?(file_name, "thumb_test_image-") do
        avatars_path
        |> Path.join(file_name)
        |> File.rm!()
      end
    end)
  end
end
