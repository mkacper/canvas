defmodule Canvas.DrawerTest do
  use ExUnit.Case
  use Plug.Test

  alias Canvas.{API, Drawer}
  alias Canvas.Drawer.Canvas

  @canvas_path "/api/canvas"

  test "POST #{@canvas_path} creates a new canvas" do
    # WHEN
    {status, resp_body} = request(:post, @canvas_path, nil)

    # THEN
    assert 201 = status
    assert resp_body =~ "Canvas id: "

    <<"Canvas id: ", canvas_id::binary>> = resp_body
    assert {:ok, %Canvas{id: ^canvas_id}} = Drawer.get_canvas(canvas_id)

    # cleanup
    :mnesia.clear_table(Canvas)
  end

  test "GET #{@canvas_path}/:id renders a canvas" do
    # GIVEN
    canvas = Drawer.new_canvas()
    Drawer.save_canvas(canvas)
    apply(Drawer, :draw_rectangle, drawing_fixture_spec() ++ [canvas]) |> Drawer.save_draw()

    # WHEN
    {status, resp_body} = request(:get, Path.join(@canvas_path, canvas.id), nil)

    # THEN
    assert 200 = status
    assert resp_body =~ drawing_fixture()

    # cleanup
    :mnesia.clear_table(Canvas)
    :mnesia.clear_table(Draw)
  end

  test "GET #{@canvas_path}/:id returns not found error when trying to render non existent canvas" do
    # WHEN
    {status, resp_body} = request(:get, Path.join(@canvas_path, "12345"), nil)

    # THEN
    assert 404 = status
    assert resp_body =~ "Canvas not found"
  end

  # Utils

  defp request(method, path, params) do
    {status, _headers, body} =
      Plug.Test.conn(method, path, params)
      |> put_req_header("content-type", "application/json")
      |> API.call(API.init([]))
      |> sent_resp()

    {status, body}
  end

  defp drawing_fixture_spec, do: [{0, 3}, 8, 4, "O", nil]

  defp drawing_fixture, do: File.read!("test/fixtures/drawing")
end
