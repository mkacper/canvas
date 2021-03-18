defmodule Canvas.API do
  use Plug.Router

  plug :match
  plug :dispatch

  alias Canvas.Drawer

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

  match _ do
    send_resp(conn, 404, "oops")
  end
end
