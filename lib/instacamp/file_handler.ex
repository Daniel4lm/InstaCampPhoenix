defmodule Instacamp.FileHandler do
  @moduledoc """
  Handles file manipulation
  """

  import Phoenix.LiveView

  alias InstacampWeb.Router.Helpers, as: Routes

  @type socket :: Phoenix.LiveView.Socket.t()

  @upload_resources [:post_photo_url]

  @spec maybe_upload_image(socket(), String.t(), atom(), String.t()) :: String.t() | nil
  def maybe_upload_image(socket, upload_directory_path, resource, old_file_name) do
    if !File.exists?(upload_directory_path), do: File.mkdir!(upload_directory_path)

    image_filename = get_filename(socket, resource)

    if image_filename do
      socket
      |> consume_uploaded_entries(resource, fn meta, _entry ->
        dest_path = create_image(upload_directory_path, meta, image_filename, resource)

        maybe_remove_old_images(resource, old_file_name)

        {:ok,
         Routes.static_path(
           socket,
           "#{get_upload_directory_name(resource)}/#{Path.basename(dest_path)}"
         )}
      end)
      |> List.first()
    end
  end

  defp create_image(upload_directory_path, meta, image_filename, resource)
       when resource in @upload_resources do
    dest_path = file_cp(upload_directory_path, meta, image_filename)
    dest_path
  end

  defp create_image(upload_directory_path, meta, image_filename, :avatar_url) do
    dest_path = file_cp(upload_directory_path, meta, image_filename)
    dest_thumb_path = file_cp(upload_directory_path, meta, "thumb_#{image_filename}")

    {:ok, _dst_path} = mogrify_thumbnail(meta.path, dest_path, 300)
    {:ok, _dst_path} = mogrify_thumbnail(meta.path, dest_thumb_path, 150)

    dest_path
  end

  defp maybe_remove_old_images(_resource, nil), do: nil

  defp maybe_remove_old_images(:avatar_url, old_file_name) do
    remove_old_image(old_file_name, :avatar_url)

    old_file_name
    |> get_avatar_thumb()
    |> remove_old_image(:avatar_url)
  end

  defp maybe_remove_old_images(resource, old_file_name) do
    remove_old_image(old_file_name, resource)
  end

  @spec get_avatar_thumb(binary()) :: binary()
  def get_avatar_thumb("/images/default-avatar.png"), do: "/images/default-avatar.png"

  def get_avatar_thumb(avatar_url) do
    file_name = String.replace_leading(avatar_url, "/uploads/avatars/", "")
    Path.join(["/uploads/avatars", "thumb_#{file_name}"])
  end

  defp remove_old_image(image_url, resource) do
    file_name = String.replace_leading(image_url, get_upload_directory_name(resource), "")
    path = Path.join(["priv" <> get_upload_directory_name(resource), file_name])
    if File.exists?(path), do: File.rm!(path)
  end

  @doc """
  Resize the image file with a given path, destination, and size
  """
  @spec mogrify_thumbnail(binary(), binary(), number()) ::
          {:error, :invalid_src_path | map()} | {:ok, binary()}
  def mogrify_thumbnail(src_path, dst_path, size) do
    try do
      src_path
      |> Mogrify.open()
      |> Mogrify.resize_to_limit("#{size}x#{size}")
      |> Mogrify.save(path: dst_path)
    rescue
      File.Error -> {:error, :invalid_src_path}
      error -> {:error, error}
    else
      _image -> {:ok, dst_path}
    end
  end

  defp get_upload_directory_name(:avatar_url), do: "/uploads/avatars"
  defp get_upload_directory_name(:post_photo_url), do: "/uploads/blog"

  @spec get_filename(socket(), atom()) :: String.t() | nil
  def get_filename(socket, resource) do
    {completed, []} = uploaded_entries(socket, resource)

    case List.first(completed) do
      nil ->
        nil

      entry ->
        generate_filename(entry)
    end
  end

  @spec generate_filename(map()) :: String.t()
  def generate_filename(entry) do
    [ext | _] = MIME.extensions(entry.client_type)

    "#{String.replace(entry.client_name, ".#{ext}", "")}-#{Ecto.UUID.generate()}.#{ext}"
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

  @spec check_image_format(String.t()) :: nil | String.t()
  def check_image_format(image_name) do
    case Regex.match?(~r/[a-z0-9\-]+\.(jpg)|(png)|(jpeg)/i, image_name) do
      true -> nil
      false -> "Wrong image format!"
    end
  end
end
