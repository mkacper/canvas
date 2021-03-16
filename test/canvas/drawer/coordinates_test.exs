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
      assert ^coordinates = rectangle_coordinates_fixture()
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

  describe "flood_fill/3" do
    test "returns correct coordinates" do
      # GIVEN
      init = {3, 2}
      width = 5
      height = 3
      outline_char = "@"
      fill_char = "X"
      rectangle_coordinates = Coordinates.rectangle(init, width, height, outline_char, fill_char)

      # WHEN
      coordinates = Coordinates.flood_fill({0, 0}, "-", rectangle_coordinates, 8)

      # THEN
      assert ^coordinates = flood_fill_coordinates_fixture()
    end

    test "returns coordinates in appropriate format" do
      # GIVEN
      init = {3, 2}
      width = 5
      height = 3
      outline_char = "@"
      fill_char = "X"
      flood_fill_char = "-"
      max_coordinate = 8
      rectangle_coordinates = Coordinates.rectangle(init, width, height, outline_char, fill_char)

      # WHEN
      coordinates =
        Coordinates.flood_fill({0, 0}, flood_fill_char, rectangle_coordinates, max_coordinate)

      # THEN
      assert Enum.all?(coordinates, fn {_, char} ->
               char in [outline_char, fill_char, flood_fill_char]
             end)

      assert Enum.all?(
               coordinates,
               &in_rectangle_area?({0, 0}, max_coordinate + 1, max_coordinate + 1, &1)
             )
    end
  end

  # Helpers

  defp in_rectangle_area?({init_x, init_y}, width, height, {{x, y}, _}),
    do: x <= init_x + width - 1 and y <= init_y + height - 1

  # Fixtures

  defp rectangle_coordinates_fixture do
    %{
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

  defp flood_fill_coordinates_fixture do
    %{
      {3, 3} => "@",
      {7, 6} => "-",
      {7, 8} => "-",
      {4, 0} => "-",
      {2, 1} => "-",
      {2, 2} => "-",
      {6, 4} => "@",
      {0, 0} => "-",
      {2, 0} => "-",
      {6, 3} => "X",
      {5, 7} => "-",
      {8, 0} => "-",
      {6, 1} => "-",
      {0, 2} => "-",
      {4, 5} => "-",
      {7, 0} => "-",
      {2, 7} => "-",
      {5, 1} => "-",
      {0, 7} => "-",
      {7, 1} => "-",
      {8, 7} => "-",
      {3, 1} => "-",
      {5, 6} => "-",
      {6, 2} => "@",
      {8, 2} => "-",
      {1, 3} => "-",
      {6, 8} => "-",
      {1, 8} => "-",
      {5, 4} => "@",
      {7, 4} => "@",
      {3, 5} => "-",
      {7, 2} => "@",
      {0, 3} => "-",
      {2, 8} => "-",
      {1, 0} => "-",
      {7, 5} => "-",
      {7, 7} => "-",
      {3, 4} => "@",
      {4, 7} => "-",
      {1, 5} => "-",
      {5, 8} => "-",
      {3, 0} => "-",
      {3, 7} => "-",
      {4, 1} => "-",
      {5, 2} => "@",
      {2, 4} => "-",
      {1, 2} => "-",
      {1, 4} => "-",
      {6, 7} => "-",
      {4, 2} => "@",
      {3, 6} => "-",
      {1, 6} => "-",
      {8, 8} => "-",
      {2, 3} => "-",
      {8, 1} => "-",
      {8, 4} => "-",
      {5, 3} => "X",
      {1, 7} => "-",
      {0, 6} => "-",
      {2, 6} => "-",
      {8, 5} => "-",
      {6, 6} => "-",
      {6, 0} => "-",
      {3, 8} => "-",
      {6, 5} => "-",
      {5, 5} => "-",
      {1, 1} => "-",
      {8, 6} => "-",
      {3, 2} => "@",
      {4, 6} => "-",
      {0, 8} => "-",
      {4, 3} => "X",
      {2, 5} => "-",
      {0, 5} => "-",
      {8, 3} => "-",
      {0, 4} => "-",
      {4, 4} => "@",
      {4, 8} => "-",
      {5, 0} => "-",
      {0, 1} => "-",
      {7, 3} => "@"
    }
  end
end
