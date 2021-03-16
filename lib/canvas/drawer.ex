defmodule Canvas.Drawer do
  @moduledoc """
  Provides an API for performing drawing operations on a canvas.
  """

  def to_binary(canvas) do
    for y <- 0..31 do
      Enum.join(for x <- 0..31 do
        Map.get(canvas, {x, y}, " ")
      end ++ ["\n"])
    end
  end
end
