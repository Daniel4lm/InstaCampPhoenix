defmodule InstacampWeb.FeatureCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Instacamp.Posts
  alias Wallaby.Browser
  alias Wallaby.Element
  alias Wallaby.Query

  @type session :: Wallaby.Session.t()

  using do
    quote do
      use Wallaby.Feature

      import InstacampWeb.FeatureCase
      import Wallaby.Query

      # use Wallaby.DSL
      alias InstacampWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint InstacampWeb.Endpoint

      @type session :: Wallaby.Session.t()

      @spec lazily_refute_has(session(), Wallaby.Query) :: session()
      def lazily_refute_has(parent, %Query{} = query) do
        conditions = Keyword.put(query.conditions, :count, 0)
        assert_has(parent, %Query{query | conditions: conditions})
      end

      setup _ do
        on_exit(fn -> Application.put_env(:wallaby, :js_logger, :stdio) end)
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Instacamp.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Instacamp.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Instacamp.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end

  @spec log_in_user(session(), String.t(), String.t()) :: session()
  def log_in_user(session, email, password) do
    email_query = Query.css(~s([name="user[email]"]))
    pass_query = Query.css(~s([name="user[password]"]))
    log_in_query = Query.button("Log In")

    session
    |> Browser.assert_text("Log in form")
    |> Browser.fill_in(email_query, with: email)
    |> Browser.fill_in(pass_query, with: password)
    |> Browser.click(log_in_query)
  end

  @spec visit_root_path(session()) :: session()
  def visit_root_path(session) do
    Browser.visit(session, "/")
  end

  @spec visit_login_path(session()) :: session()
  def visit_login_path(session) do
    Browser.visit(session, "/auth/login")
  end

  @spec open_post_page(session(), Posts.Post.t()) :: session()
  def open_post_page(session, %Posts.Post{} = post) do
    Browser.visit(session, "/post/" <> post.slug)
  end

  @spec open_mailbox(session()) :: session()
  def open_mailbox(session) do
    list_group_item = Query.css(".list-group-item")

    session
    |> Browser.visit("/dev/mailbox")
    |> wait(4000)
    |> Browser.all(list_group_item)
    |> List.first()
    |> Element.click()

    Browser.focus_frame(session, Query.css("iframe"))
  end

  @spec wait(session(), integer()) :: session()
  def wait(session, timeout) do
    :timer.sleep(timeout)
    session
  end
end
