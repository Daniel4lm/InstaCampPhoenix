defmodule Instacamp.Accounts.UserNotifier do
  @moduledoc false

  import Swoosh.Email

  alias Instacamp.Mailer

  @from {"Campy", "info-contact@campy.com"}

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, text_body, html_body) do
    email =
      new()
      |> from(@from)
      |> to(recipient)
      |> subject(subject)
      |> text_body(text_body)
      |> html_body(html_body)

    case Mailer.deliver(email) do
      {:ok, _metadata} ->
        {:ok, email}

      {:error, term} ->
        {:error, term}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    text_body = """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the url below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """

    html_body = """
    Hi #{user.email},<br/></br/>
    You can confirm your account by visiting the url below:<br/></br/>
    <a href="#{url}" target="_blank">#{url}</a><br/></br/>
    If you didn't create an account with us, please ignore this.
    """

    deliver(user.email, "Please confirm your account", text_body, html_body)
  end

  # def deliver_confirmation_instructions(user, url) do
  #   deliver(user.email, "Confirmation instructions", """

  #   ==============================

  #   Hi #{user.email},

  #   You can confirm your account by visiting the URL below:

  #   #{url}

  #   If you didn't create an account with us, please ignore this.

  #   ==============================
  #   """)
  # end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    text_body = """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the url below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """

    html_body = """
    Hi #{user.email},<br/></br/>
    You can reset your password by visiting the url below:<br/></br/>
    <a href="#{url}" target="_blank">#{url}</a><br/></br/>
    If you didn't request this change, please ignore this.
    """

    deliver(user.email, "Please confirm your account", text_body, html_body)
  end

  # def deliver_reset_password_instructions(user, url) do
  #   deliver(user.email, "Reset password instructions", """

  #   ==============================

  #   Hi #{user.email},

  #   You can reset your password by visiting the URL below:

  #   #{url}

  #   If you didn't request this change, please ignore this.

  #   ==============================
  #   """)
  # end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    text_body = """

    ==============================

    Hi #{user.email},

    You can change your e-mail by visiting the url below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """

    html_body = """
    Hi #{user.email},<br/></br/>
    You can change your e-mail by visiting the url below:<br/></br/>
    <a href="#{url}" target="_blank">#{url}</a><br/></br/>
    If you didn't request this change, please ignore this.
    """

    deliver(user.email, "Please confirm your account", text_body, html_body)
  end
end
