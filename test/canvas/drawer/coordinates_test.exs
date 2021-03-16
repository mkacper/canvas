defmodule Canvas.Drawer.CoordinatesTest do
  use ExUnit.Case

  alias Canvas.Drawer.Coordinates

  describe "rectangle/5" do
    test "returns correct coordinates" do
      # GIVEN
      init = {3, 2}
      width = 5
      height = 3
      outline_char = "@"
      fill_char = "X"

      # WHEN
      coordinates = Coordinates.rectangle(init, width, height, outline_char, fill_char)

      # THEN
      assert ^coordinates = %{
               {3, 2} => "@",
               {3, 3} => "@",
               {3, 4} => "@",
               {4, 2} => "@",
               {4, 3} => "X",
               {4, 4} => "@",
               {5, 2} => "@",
               {5, 3} => "X",
               {5, 4} => "@",
               {6, 2} => "@",
               {6, 3} => "X",
               {6, 4} => "@",
               {7, 2} => "@",
               {7, 3} => "@",
               {7, 4} => "@"
             }
    end

    test "returns coordinates in appropriate format" do
      # GIVEN
      init = {3, 2}
      width = 5
      height = 3
      outline_char = "X"
      fill_char = "@"

      # WHEN
      coordinates = Coordinates.rectangle(init, width, height, outline_char, fill_char)

      # THEN
      assert Enum.all?(coordinates, fn {_, char} -> char in [outline_char, fill_char] end)
      assert Enum.all?(coordinates, &in_rectangle_area?(init, width, height, &1))
    end

    test "does not require fill char" do
      # GIVEN
      init = {3, 2}
      width = 5
      height = 3
      outline_char = "X"
      fill_char = nil

      # WHEN
      coordinates = Coordinates.rectangle(init, width, height, outline_char, fill_char)

      # THEN
      assert Enum.all?(coordinates, fn {_, char} -> char == outline_char end)
      refute Enum.any?(coordinates, fn {_, char} -> char == fill_char end)
    end

    test "does not require outline char" do
      # GIVEN
      init = {3, 2}
      width = 5
      height = 3
      outline_char = nil
      fill_char = "X"

      # WHEN
      coordinates = Coordinates.rectangle(init, width, height, outline_char, fill_char)

      # THEN
      assert Enum.all?(coordinates, fn {_, char} -> char == fill_char end)
      refute Enum.any?(coordinates, fn {_, char} -> char == outline_char end)
    end

    test "returns no coordinates if none of chars are passed" do
      # GIVEN
      init = {3, 2}
      width = 5
      height = 3
      outline_char = nil
      fill_char = nil

      # WHEN
      coordinates = Coordinates.rectangle(init, width, height, outline_char, fill_char)

      # THEN
      assert ^coordinates = %{}
    end
  end

  defp in_rectangle_area?({init_x, init_y}, width, height, {{x, y}, _}),
    do: x <= init_x + width - 1 and y <= init_y + height - 1
end
