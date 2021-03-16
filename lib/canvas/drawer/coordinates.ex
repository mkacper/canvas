defmodule Canvas.Drawer.Coordinates do
  @moduledoc """
  Implements functions that translates drawing operations into
  set of coordinates that can be later used to visualise those.
  """

  # API

  def rectangle({x, y}, width, height, outline_char, fill_char) do
    init = {x, y}
    current = init
    max_x = x + width - 1
    max_y = y + height - 1
    traverse_y(init, current, max_x, max_y, outline_char, fill_char, %{})
  end

  def flood_fill(point, fill_char, coordinates, max \\ 32) do
    traverse_points(neighbours(point), %{}, fill_char, coordinates, max)
  end

  # Helpers

  # Rectangle

  defp traverse_y(_init, {_cx, cy}, _max_x, max_y, _outline_char, _fill_char, coordinates)
       when cy > max_y,
       do: coordinates

  defp traverse_y(init, {cx, cy} = current, max_x, max_y, outline_char, fill_char, coordinates) do
    coordinates = traverse_x(init, current, max_x, max_y, outline_char, fill_char, coordinates)
    traverse_y(init, {cx, cy + 1}, max_x, max_y, outline_char, fill_char, coordinates)
  end

  defp traverse_x(
         _init,
         {_cx = max_x, _} = current,
         max_x,
         _max_y,
         outline_char,
         _fill_char,
         coordinates
       ) do
    if outline_char do
      Map.put(coordinates, current, outline_char)
    else
      coordinates
    end
  end

  defp traverse_x(init, {cx, cy = max_y}, max_x, max_y, outline_char, fill_char, coordinates)
       when not is_nil(outline_char) do
    coordinates = Map.put(coordinates, {cx, cy}, outline_char)
    traverse_x(init, {cx + 1, cy}, max_x, max_y, outline_char, fill_char, coordinates)
  end

  defp traverse_x(
         {_, y} = init,
         {cx, y = cy} = current,
         max_x,
         max_y,
         outline_char,
         fill_char,
         coordinates
       )
       when not is_nil(outline_char) do
    coordinates = Map.put(coordinates, current, outline_char)
    traverse_x(init, {cx + 1, cy}, max_x, max_y, outline_char, fill_char, coordinates)
  end

  defp traverse_x(
         {x, _} = init,
         {x = cx, cy} = current,
         max_x,
         max_y,
         outline_char,
         fill_char,
         coordinates
       )
       when not is_nil(outline_char) do
    coordinates = Map.put(coordinates, current, outline_char)
    traverse_x(init, {cx + 1, cy}, max_x, max_y, outline_char, fill_char, coordinates)
  end

  defp traverse_x(init, {cx, cy} = current, max_x, max_y, outline_char, fill_char, coordinates)
       when not is_nil(fill_char) do
    coordinates = Map.put(coordinates, current, fill_char)
    traverse_x(init, {cx + 1, cy}, max_x, max_y, outline_char, fill_char, coordinates)
  end

  defp traverse_x(init, {cx, cy}, max_x, max_y, outline_char, fill_char, coordinates) do
    traverse_x(init, {cx + 1, cy}, max_x, max_y, outline_char, fill_char, coordinates)
  end

  # Flood fill

  defp traverse_points([], _, _, coordinates, _), do: coordinates

  defp traverse_points([{x, y} = p | ps], visited, fill_char, coordinates, max)
       when x > max or y > max or x < 0 or y < 0,
       do: traverse_points(ps, Map.put(visited, p, :visited), fill_char, coordinates, max)

  defp traverse_points([p | ps], visited, fill_char, coordinates, max) when is_map_key(visited, p),
    do: traverse_points(ps, visited, fill_char, coordinates, max)

  defp traverse_points([p | ps], visited, fill_char, coordinates, max) when is_map_key(coordinates, p),
    do: traverse_points(ps, Map.put(visited, p, :visited), fill_char, coordinates, max)

  defp traverse_points([p | ps], visited, fill_char, coordinates, max) do
    coordinates = Map.put(coordinates, p, fill_char)
    visited = Map.put(visited, p, :visited)
    traverse_points(ps ++ neighbours(p), visited, fill_char, coordinates, max)
  end

  # Utils

  defp neighbours({x, y}) do
    [
      {x - 1, y - 1},
      {x - 1, y},
      {x - 1, y + 1},
      {x, y - 1},
      {x, y + 1},
      {x + 1, y - 1},
      {x + 1, y},
      {x + 1, y + 1}
    ]
  end
end
