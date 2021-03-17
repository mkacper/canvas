defmodule Canvas.Drawer do
  @moduledoc """
  Provides an API for performing drawing operations on a canvas.
  """

  alias Canvas.Drawer.{Coordinates, Storage}

  @canvas_size 32

  defmodule Canvas do
    defstruct ~w(id width height drawings coordinates)a
  end

  defmodule Draw do
    defstruct ~w(canvas_id coordinates inserted_at)a
  end

  # API

  def initalize_storage(),
    do: Storage.init()

  def new_canvas,
    do: %Canvas{id: id(), width: @canvas_size, height: @canvas_size, drawings: []}

  def get_canvas(id),
    do: Storage.get_canvas_with_drawings_orderd_by_insert_time(id)

  def save_draw(%Draw{} = draw),
    do: Storage.save_draw(draw)

  def save_canvas(%Canvas{} = canvas),
    do: Storage.save_canvas(canvas)

  def draw_rectangle(point, width, height, outline_char, fill_char, %Canvas{id: canvas_id})
      when not is_nil(outline_char) and not is_nil(fill_char) do
    coordinates = Coordinates.rectangle(point, width, height, outline_char, fill_char)
    %Draw{coordinates: coordinates, canvas_id: canvas_id, inserted_at: timestamp()}
  end

  def flood_fill(point, fill_char, %Canvas{id: canvas_id} = canvas) do
    canvas = apply_drawings(canvas)
    coordinates = Coordinates.flood_fill(point, fill_char, canvas.coordinates)
    %Draw{coordinates: coordinates, canvas_id: canvas_id, inserted_at: timestamp()}
  end

  def apply_drawings(%Canvas{drawings: drawings} = canvas) do
    coordinates =
      Enum.reduce(drawings, %{}, fn %Draw{coordinates: coordinates}, canvas_coordinates ->
        Map.merge(canvas_coordinates, coordinates)
      end)

    %{canvas | coordinates: coordinates}
  end

  def to_binary(%Canvas{coordinates: coordinates}) do
    for y <- 0..(@canvas_size - 1) do
      Enum.join(
        for x <- 0..@canvas_size do
          Map.get(coordinates, {x, y}, " ")
        end ++ ["\n"]
      )
    end
  end

  # Utils

  defp id do
    ref = make_ref()
    :erlang.phash2(ref)
  end

  defp timestamp do
    :os.system_time(:millisecond)
  end
end
