defmodule Canvas.Drawer.StorageTest do
  use ExUnit.Case

  alias Canvas.Drawer
  alias Canvas.Drawer.{Canvas, Draw, Storage}

  test "init/0 creates schema and required mnesia tables" do
    # WHEN
    Storage.init()

    # THEN
    assert {:error, {_, {:already_exists, _}}} = :mnesia.create_schema([node()])
    assert {:aborted, {:already_exists, Canvas}} = :mnesia.create_table(Canvas, [])
    assert {:aborted, {:already_exists, Draw}} = :mnesia.create_table(Draw, [])
  end

  test "save_canvas/1 saves a canvas into storage" do
    # GIVEN
    canvas_id = "12345"
    canvas = %Canvas{id: canvas_id, drawings: []}

    # WHEN
    :ok = Storage.save_canvas(canvas)

    # THEN
    assert {:ok, ^canvas} = Storage.get_canvas_with_drawings_orderd_by_insert_time(canvas_id)

    # cleanup
    :mnesia.clear_table(Canvas)
  end

  test "save_draw/1 saves a draw into storage" do
    # GIVEN
    canvas_id = "12345"
    canvas = %Canvas{id: canvas_id}
    Storage.save_canvas(canvas)
    draw = Drawer.draw_rectangle({3, 2}, 5, 3, "X", "O", canvas)

    # WHEN
    :ok = Storage.save_draw(draw)

    # THEN
    assert {:ok, %{drawings: [^draw]}} =
             Storage.get_canvas_with_drawings_orderd_by_insert_time(canvas_id)

    # cleanup
    :mnesia.clear_table(Canvas)
    :mnesia.clear_table(Draw)
  end

  test "get_canvas_with_drawings_orderd_by_insert_time/1 returns canvas with properly sorted drawings" do
    # GIVEN
    canvas_id = "12345"
    canvas = %Canvas{id: canvas_id}
    Storage.save_canvas(canvas)

    drawings =
      for x <- 1..3 do
        draw = %Draw{canvas_id: canvas_id, inserted_at: x}
        :ok = Storage.save_draw(draw)
        draw
      end

    canvas_with_drawings = %{canvas | drawings: drawings}

    # WHEN
    stored_canvas = Storage.get_canvas_with_drawings_orderd_by_insert_time(canvas_id)

    # THEN
    assert {:ok, ^canvas_with_drawings} = stored_canvas

    # cleanup
    :mnesia.clear_table(Canvas)
    :mnesia.clear_table(Draw)
  end

  test "get_canvas_with_drawings_orderd_by_insert_time/1 returns not found error when provided canvas id does not exist" do
    # GIVEN
    canvas_id = "not_existent_id"

    # WHEN
    result = Storage.get_canvas_with_drawings_orderd_by_insert_time(canvas_id)

    # THEN
    assert {:error, :canvas_not_found} = result
  end
end
