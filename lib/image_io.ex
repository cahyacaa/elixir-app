defmodule ImageIO do
  def load_image(image_path) do
    image_path
      |> Image.open!()
  end

  @image_filetypes [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff"]
  def is_image?(filename) do
    file_extension = filename
      |> Path.extname()
      |> String.downcase()
      Enum.member?(@image_filetypes, file_extension)
  end

  def get_output_filename(imagename, image_filetype, imagename_prefix) do
    case imagename_prefix do
      nil -> "#{imagename}.#{image_filetype}"
      _ -> "#{imagename_prefix}_#{imagename}.#{image_filetype}"
    end
  end

  # def get_image_paths(path_input_image_folder) do
  #   IO.puts("Loading images from: #{path_input_image_folder}")
  #   path_input_image_folder
  #     |> File.ls!()
  #     |> Enum.filter(&is_image?/1)
  #     |> Enum.map(fn file ->
  #       Path.join(path_input_image_folder, file)
  #     end)
  # end

  def get_image_paths(path) do
    IO.puts("Loading images from: #{path}")

    case File.ls(path) do
      {:ok, entries} ->
        IO.inspect(entries, label: "▶️ File.ls/1 returned")

        images =
          entries
          |> Enum.filter(&is_image?/1)

        IO.inspect(images, label: "▶️ After is_image? filter")

        full_paths =
          images
          |> Enum.map(&Path.join(path, &1))

        IO.inspect(full_paths, label: "▶️ Full paths to return")
        full_paths

      {:error, reason} ->
        IO.inspect(reason, label: "❌ File.ls/1 error")
        raise File.Error, action: "list directory", path: path, reason: reason
    end
  end



    def save_image(image, imagename, save_folder_path, image_filetype, imagename_prefix \\ nil) do
      filename =
        if imagename_prefix do
          "#{imagename_prefix}-#{imagename}.#{image_filetype}"
        else
          "#{imagename}.#{image_filetype}"
        end

      filepath = Path.join(save_folder_path, filename)

      # Assuming you are using a library like `Image` to save the image
      case Image.write(image, filepath) do
        {:ok, _} -> {:ok, filepath}
        {:error, reason} -> {:error, reason}
      end
    end

end
