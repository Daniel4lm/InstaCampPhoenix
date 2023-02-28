defmodule Instacamp.FileHandler do
  @moduledoc """
  Handles file manipulation
  """

  import Phoenix.LiveView

  alias InstacampWeb.Router.Helpers, as: Routes

  @type socket :: Phoenix.LiveView.Socket.t()

  @spec get_filename(socket(), atom()) :: String.t() | nil
  def get_filename(socket, resource) do
    {completed, []} = uploaded_entries(socket, resource)

    case List.first(completed) do
      nil ->
        nil

      entry ->
        entry.client_name
    end
  end

  @spec generate_filename(map()) :: String.t()
  def generate_filename(entry) do
    [ext | _] = MIME.extensions(entry.client_type)

    "#{Ecto.UUID.generate()}.#{ext}"
  end

  @spec file_cp(String.t(), map(), String.t()) :: String.t()
  def file_cp(dir, meta, file_name) do
    dest =
      :instacamp
      |> Application.app_dir(dir)
      |> Path.join(file_name)

    File.cp!(meta.path, dest)

    dest
  end

  @spec maybe_upload_image(socket(), String.t(), String.t(), atom()) :: String.t() | nil
  def maybe_upload_image(socket, upload_directory_name, upload_directory_path, resource) do
    if !File.exists?(upload_directory_path), do: File.mkdir!(upload_directory_path)

    image_filename = get_filename(socket, resource)

    if image_filename do
      socket
      |> consume_uploaded_entries(resource, fn meta, _entry ->
        dest = file_cp(upload_directory_path, meta, image_filename)

        {:ok, Routes.static_path(socket, "#{upload_directory_name}/#{Path.basename(dest)}")}
      end)
      |> List.first()
    end
  end

  @spec check_image_format(String.t()) :: nil | String.t()
  def check_image_format(image_name) do
    case Regex.match?(~r/[a-z0-9\-]+\.(jpg)|(png)|(jpeg)/i, image_name) do
      true -> nil
      false -> "Wrong image format!"
    end
  end
end
