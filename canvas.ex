defmodule Canvas do

  def draw_rectangle({x, y}, width, height, outline_char, canvas \\ %{}) do
    canvas_horizontal = 
      Enum.reduce(x..x+width-1, canvas, fn x, canvas ->
        canvas
        |> Map.put({x, y}, outline_char) 
        |> Map.put({x, y + height - 1}, outline_char) 
      end)

    Enum.reduce(y..y+height-1, canvas_horizontal, fn y, canvas ->
      canvas
      |> Map.put({x, y}, outline_char) 
      |> Map.put({x + width - 1, y}, outline_char) 
    end)
  end


  def draw_rectangle2({x, y}, width, height, outline_char, fill_char \\ nil, canvas \\ %{}) do
    max_x = x+width-1
    max_y = y+height-1
    traverse_y({x, y}, {x, y}, max_x, max_y, outline_char, fill_char, canvas)
  end

  defp traverse_y(_init, {_cx, cy}, _max_x, max_y, _outline_char, _fill_char, canvas) when cy > max_y,
    do: canvas

  defp traverse_y(init, {cx, max_y = cy}, max_x, max_y, outline_char, fill_char, canvas),
    do: traverse_x(init, {cx, cy}, max_x, max_y, outline_char, fill_char, canvas)

  defp traverse_y(init, {cx, cy}, max_x, max_y, outline_char, fill_char, canvas) do
    canvas = traverse_x(init, {cx, cy}, max_x, max_y, outline_char, fill_char, canvas)
    traverse_y(init, {cx, cy + 1}, max_x, max_y, outline_char, fill_char, canvas)
  end

  defp traverse_x(_init, {cx = max_x, cy}, max_x, _max_y, outline_char, _fill_char, canvas) do
    IO.inspect "done"
    Map.put(canvas, {cx, cy}, outline_char) 
  end

  defp traverse_x({x, y}, {cx, cy = max_y}, max_x, max_y, outline_char, fill_char, canvas) do
    IO.inspect "max y"
    canvas = Map.put(canvas, {cx, cy}, outline_char) 
    traverse_x({x, y}, {cx + 1, cy}, max_x, max_y, outline_char, fill_char, canvas)
  end

  defp traverse_x({x, y}, {cx, y = cy}, max_x, max_y, outline_char, fill_char, canvas) do
    IO.inspect "STEP 1"
    IO.inspect cx
    IO.inspect max_x
    canvas = Map.put(canvas, {cx, cy}, outline_char) 
    traverse_x({x, y}, {cx + 1, cy}, max_x, max_y, outline_char, fill_char, canvas)
  end

  defp traverse_x({x, y}, {x = cx, cy}, max_x, max_y, outline_char, fill_char, canvas) do
    IO.inspect "2"
    canvas = Map.put(canvas, {cx, cy}, outline_char) 
    traverse_x({x, y}, {cx + 1, cy}, max_x, max_y, outline_char, fill_char, canvas)
  end

  defp traverse_x({x, y}, {cx, cy}, max_x, max_y, outline_char, fill_char, canvas) when not is_nil(fill_char) do
    IO.inspect "3"
    canvas = Map.put(canvas, {cx, cy}, fill_char) 
    traverse_x({x, y}, {cx + 1, cy}, max_x, max_y, outline_char, fill_char, canvas)
  end

  defp traverse_x(init, {cx, cy}, max_x, max_y, outline_char, fill_char, canvas) do
    IO.inspect "4"
    traverse_x(init, {cx + 1, cy}, max_x, max_y, outline_char, fill_char, canvas)
  end

  def to_binary(canvas) do
    for y <- 0..31 do
      Enum.join(for x <- 0..31 do
        Map.get(canvas, {x, y}, " ")
      end ++ ["\n"])
    end
  end
end
