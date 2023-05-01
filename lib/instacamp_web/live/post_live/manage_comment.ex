defmodule InstacampWeb.PostLive.ManageComment do
  @moduledoc false

  use InstacampWeb, :live_component

  alias Instacamp.FileHandler
  alias InstacampWeb.Components.Icons

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id="change-comment-comp" class="p-2 md:p-4 dark:bg-slate-500 dark:text-slate-100">
      <h1 :if={@action == :edit_comment} class="text-base md:text-xl font-semibold mb-4">
        Editing comment
      </h1>
      <div :if={@action == :comment_reply} class="flex items-center gap-2 mb-4">
        <div class="w-max p-1 border rounded-lg border-gray-200 text-gray-300">
          <Icons.reply class="w-5 h-5" />
        </div>
        <h1 class="text-base md:text-lg font-medium">
          Reply to
        </h1>
        <div class="flex items-center gap-2">
          <.user_avatar
            with_link={~p"/user/#{@comment.user.username}"}
            src={FileHandler.get_avatar_thumb(@comment.user.avatar_url)}
            class="w-8 h-8"
          />

          <.link
            navigate={~p"/user/#{@comment.user.username}"}
            class="truncate font-bold text-gray-500 dark:text-inherit hover:underline"
          >
            <%= @comment.user.username %>
          </.link>
        </div>
      </div>

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
            <div id="trix-editor-comment" phx-update="ignore">
              <trix-editor
                input="comment_body"
                class="min-h-[100px] rounded-md border-gray-400 dark:bg-slate-700 dark:text-slate-100 dark:border-slate-400 text-justify overflow-hidden overflow-x-auto text-semibold text-gray-600 focus:ring-2 focus:ring-indigo-400 focus:ring-opacity-90 focus:border-transparent dark:focus:border-transparent dark:focus:ring-blue-400"
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
