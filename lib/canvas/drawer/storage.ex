defmodule Canvas.Drawer.Storage do
  @moduledoc """
  Provides an API for interacting with canvas and drawings persistence layer.
  """

  alias Canvas.Drawer.{Canvas, Draw}

  def init() do
    :mnesia.create_schema([node()])
    :mnesia.start()

    :mnesia.create_table(Canvas,
      disc_copies: [node()],
      type: :set,
      attributes: [:id, :width, :height, :coordinates]
    )

    :mnesia.create_table(Draw,
      disc_copies: [node()],
      type: :bag,
      attributes: [:canvas_id, :coordinates, :inserted_at]
    )
    # we should pattern match on the return values and crash if they do not mach
    # our expectations
  end

  # it would be nice to verify if there is not a canvas with the same id already
  # in the storage
  def save_draw(draw), do: save_struct(draw)

  def save_canvas(canvas), do: save_struct(canvas)

  def get_canvas_with_drawings_orderd_by_insert_time(canvas_id) do
    case :mnesia.dirty_read({Canvas, canvas_id}) do
      [] ->
        {:error, :canvas_not_found}

      [canvas_obj] ->
        canvas = to_struct(canvas_obj)

        drawings =
          {Draw, canvas_id}
          |> :mnesia.dirty_read()
          |> Enum.map(&to_struct(&1))
          |> sort_asc_by_inserted_at()

        {:ok, %{canvas | drawings: drawings}}
    end
  end

  defp save_struct(struct) do
    struct
    |> to_object()
    |> :mnesia.dirty_write()
  end

  defp to_object(%Canvas{id: id, width: width, height: height, coordinates: coordinates}) do
    {Canvas, id, width, height, coordinates}
  end

  defp to_object(%Draw{canvas_id: id, coordinates: coordinates, inserted_at: inserted_at}) do
    {Draw, id, coordinates, inserted_at}
  end

  defp to_struct({Canvas, id, width, height, coordinates}) do
    %Canvas{id: id, width: width, height: height, coordinates: coordinates}
  end

  defp to_struct({Draw, id, coordinates, inserted_at}) do
    %Draw{canvas_id: id, coordinates: coordinates, inserted_at: inserted_at}
  end

  defp sort_asc_by_inserted_at(drawings) do
    Enum.sort(drawings, fn %{inserted_at: timestamp1}, %{inserted_at: timestamp2} ->
      timestamp1 < timestamp2
    end)
  end
end
