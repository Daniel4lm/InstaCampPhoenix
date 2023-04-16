defmodule InstacampWeb.PostLive.EditComment do
  @moduledoc false

  use InstacampWeb, :live_component

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="p-4 dark:bg-slate-500 dark:text-slate-100">
      <h1 class="text-2xl font-semibold mb-4">Editing comment</h1>

      <.form
        :let={f}
        for={@comment_changeset}
        id="edit_comment-form"
        phx-submit="save_comment"
        class="w-full"
        as={:comment}
      >
        <div class="flex flex-col">
          <%= hidden_input(f, :body, id: :comment_body, phx_hook: "CommentBodyHook") %>

          <div class="w-full">
            <div id="trix-editor" phx-update="ignore">
              <trix-editor
                input="comment_body"
                class="min-h-[100px] rounded-md border-gray-400 dark:bg-slate-700 dark:text-slate-100 dark:border-slate-400 text-justify overflow-hidden overflow-x-auto text-semibold text-gray-600 focus:ring-2 focus:ring-indigo-400 focus:ring-opacity-90 focus:border-transparent dark:focus:border-transparent dark:focus:ring-blue-400"
                placeholder="Write your blog post"
              >
              </trix-editor>
            </div>
            <%= error_tag(f, :body) %>
          </div>

          <%= submit("Save",
            id: "edit-comment-form-submit",
            class:
              "w-max m-2 py-2 px-8 border-none shadow rounded-full font-semibold text-sm text-gray-50 hover:bg-indigo-500 bg-indigo-400 cursor-pointer"
          ) %>
        </div>
      </.form>
    </div>
    """
  end
end
