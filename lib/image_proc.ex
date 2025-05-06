defmodule ImageProc do
  @moduledoc """
  Documentation for `ImageProc`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ImageProc.hello()
      :world

  """
  def hello do
    :world
  end

@imagename_prefix  ""
@output_image_filetypes ["jpeg", "webp"]

def process_images(path_input_folder, path_output_folder) do
  lst_paths_image = ImageIO.get_image_paths(path_input_folder)

  if not File.exists?(path_output_folder) do
    File.mkdir_p(path_output_folder)
  end

  for path_image <- lst_paths_image, image_filetype <- @output_image_filetypes do
    imagename = get_imagename(path_image)

    ImageIO.load_image(path_image)
    |> generate_resized_images(
        image_filetype,
        imagename,
        path_output_folder,
        @imagename_prefix
    )
  end
end

def get_imagename(path_image) do
  path_image
  |> Path.rootname()
  |> Path.basename()
  |> String.replace(" ", "")
  |> String.downcase()
end

def generate_resized_images(
    image,
    image_filetype,
    imagename,
    output_folder_path,
    imagename_prefix \\ nil
  ) do

  save_folder_path = Path.join(output_folder_path, imagename)

  if not File.exists?(save_folder_path) do
    File.mkdir(save_folder_path)
  end

  image_aspect = image |> Image.aspect()

  long_edge_final_map = get_resized_long_edge_map(image_aspect)
  image_long_edge_len = get_long_edge_len(image, image_aspect)

  for {sizename, long_edge_final} <- long_edge_final_map do

    scale_factor = long_edge_final / image_long_edge_len
    {:ok, resized_image} = image |> Image.resize(scale_factor)

    resized_imagename = "#{imagename}-#{sizename}"

    resized_image
    |> ImageIO.save_image(
	    resized_imagename,
	    save_folder_path,
	    image_filetype,
	    imagename_prefix
    )

    IO.puts("Writing image #{resized_imagename}.#{image_filetype} to #{save_folder_path}")
  end

end

@resized_long_edge_map_square %{"sm" => 334, "md" => 668, "lg" => 1334}
@resized_long_edge_map %{"sm" => 500, "md" => 1000, "lg" => 2000}
def get_resized_long_edge_map(image_aspect) do
  case image_aspect do
    :square -> @resized_long_edge_map_square
    _ -> @resized_long_edge_map
  end
end

def get_long_edge_len(image, image_aspect) do
  case image_aspect do
    :portrait -> image |> Image.height()
    _ -> image |> Image.width()
  end
end

end
