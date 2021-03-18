defmodule Canvas.API do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  alias Canvas.Drawer

  post "/api/canvas/" do
    canvas = Drawer.new_canvas()
    :ok = Drawer.save_canvas(canvas)
    send_resp(conn, 201, "Canvas id: #{canvas.id}")
  end

  get "/api/canvas/:canvas_id" do
    case Drawer.get_canvas(canvas_id) do
      {:error, :canvas_not_found} ->
        send_resp(conn, 404, "Canvas not found")

      {:ok, canvas} ->
        canvas_bin =
          canvas
          |> Drawer.apply_drawings()
          |> Drawer.to_binary()

        send_resp(conn, 200, canvas_bin)
    end
  end

  post "/api/canvas/:canvas_id/drawings" do
    with {:ok, params} <- validate_params(conn.body_params),
         {:ok, canvas} <- Drawer.get_canvas(canvas_id) do
      :ok =
        case params do
          %{"type" => "rectangle"} ->
            Drawer.draw_rectangle(
              params["init_point"],
              params["width"],
              params["height"],
              params["outline_char"],
              params["fill_char"],
              canvas
            )

          %{"type" => "flood_fill"} ->
            Drawer.flood_fill(
              params["init_point"],
              params["fill_char"],
              canvas
            )
        end
        |> Drawer.save_draw()

      send_resp(conn, 201, "Drawing added successfully")
    else
      {:error, :bad_request} ->
        send_resp(conn, 400, "Bad request")

      {:error, :canvas_not_found} ->
        send_resp(conn, 404, "Canvas not found")
    end
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp validate_params(
         %{
           "type" => "rectangle",
           "init_point" => [x, y],
           "width" => width,
           "height" => height,
           "outline_char" => outline_char,
           "fill_char" => fill_char
         } = params
       )
       when is_integer(x) and
              is_integer(y) and
              is_integer(width) and
              is_integer(height) and
              (not is_nil(outline_char) or not is_nil(fill_char)) and
              ((is_binary(outline_char) and byte_size(outline_char) == 1) or is_nil(outline_char)) and
              ((is_binary(fill_char) and byte_size(fill_char) == 1) or is_nil(fill_char)),
       do: {:ok, %{params | "init_point" => {x, y}}}

  defp validate_params(
         %{
           "type" => "flood_fill",
           "init_point" => [x, y],
           "fill_char" => fill_char
         } = params
       )
       when is_integer(x) and
              is_integer(y) and
              not is_nil(fill_char),
       do: {:ok, %{params | "init_point" => {x, y}}}

  defp validate_params(_), do: {:error, :bad_request}
end
