defmodule Canvas do

  def draw_rectangle({x, y}, width, height, outline_char) do
    canvas_x = 
      Enum.reduce(x..x+width-1, %{}, fn x, canvas ->
        canvas
        |> Map.put({x, y}, outline_char) 
        |> Map.put({x, y + height - 1}, outline_char) 
      end)

    Enum.reduce(y..y+height-1, canvas_x, fn y, canvas ->
      canvas
      |> Map.put({x, y}, outline_char) 
      |> Map.put({x + width - 1, y}, outline_char) 
    end)
  end

  def to_binary(canvas) do
    for y <- 0..31 do
      Enum.join(for x <- 0..31 do
        Map.get(canvas, {x, y}, " ")
      end ++ ["\n"])
    end
  end
end
