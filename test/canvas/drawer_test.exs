defmodule Canvas.DrawerTest do
  use ExUnit.Case

  alias Canvas.Drawer

  test "new_canvas/0 returns Canvas struct" do
    # WHEN
    canvas = Drawer.new_canvas()

    # THEN
    assert is_binary(canvas.id)
    assert 32 = canvas.width
    assert 32 = canvas.height
    assert [] = canvas.drawings
  end

  test "draw_rectangle/6 returns a proper Draw" do
    # GIVEN
    canvas = Drawer.new_canvas()
    canvas_id = canvas.id
    init = {3, 2}
    width = 5
    height = 6
    outline_char = "@"
    fill_char = "X"
    timestamp = :os.system_time(:millisecond)

    # WHEN
    draw = Drawer.draw_rectangle(init, width, height, outline_char, fill_char, canvas)

    # THEN
    assert is_map(draw.coordinates)
    assert ^canvas_id = draw.canvas_id
    assert timestamp <= draw.inserted_at
  end

  test "draw_rectangle/6 crashes when either outline and fill chars are nil" do
    # GIVEN
    canvas = Drawer.new_canvas()

    # WHEN and THEN
    assert_raise FunctionClauseError,
                 "no function clause matching in Canvas.Drawer.draw_rectangle/6",
                 fn ->
                   Drawer.draw_rectangle({3, 2}, 1, 1, nil, nil, canvas)
                 end
  end

  test "flood_fill/3 applies all canvas drawings, performs flood fill operation and returns a proper Draw" do
    # GIVEN
    canvas = Drawer.new_canvas()
    canvas_id = canvas.id
    draw = Drawer.draw_rectangle({3, 2}, 5, 3, "@", "X", canvas)
    canvas = %{canvas | drawings: [draw]}
    timestamp = :os.system_time(:millisecond)
    fill_char = "-"

    # WHEN
    flood_filled_draw = Drawer.flood_fill({0, 0}, fill_char, canvas)

    # THEN
    assert is_map(flood_filled_draw.coordinates)
    assert timestamp <= flood_filled_draw.inserted_at
    assert ^canvas_id = flood_filled_draw.canvas_id
    assert timestamp <= draw.inserted_at

    assert Enum.all?(draw.coordinates, fn {point, char} ->
             char == Map.get(flood_filled_draw.coordinates, point)
           end)

    assert Enum.any?(flood_filled_draw.coordinates, &(elem(&1, 1) == fill_char))
  end

  test "apply_drawings/1 merges all drawings that belongs to a canvas" do
    # GIVEN
    canvas = Drawer.new_canvas()

    drawings =
      [d1, d2, d3] =
      for x <- 1..3 do
        Drawer.draw_rectangle({x, 2}, 5, 3, "@", "X", canvas)
      end

    canvas = %{canvas | drawings: drawings}

    mereged_drawings_coordinates =
      d1.coordinates |> Map.merge(d2.coordinates) |> Map.merge(d3.coordinates)

    # WHEN
    canvas = Drawer.apply_drawings(canvas)

    # THEN
    assert ^mereged_drawings_coordinates = canvas.coordinates
  end
end
