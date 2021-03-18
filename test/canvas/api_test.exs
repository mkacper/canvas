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

  describe "Test drawing endpoint:" do
    setup do
      canvas = Drawer.new_canvas()
      Drawer.save_canvas(canvas)
      {:ok, canvas: canvas}
    end

    test "POST #{@canvas_path}/:id/drawings creates a rectangle drawing", %{canvas: canvas} do
      [{x, y}, width, height, outline_char, fill_char] = drawing_fixture_spec()

      params = %{
        type: "rectangle",
        init_point: [x, y],
        width: width,
        height: height,
        outline_char: outline_char,
        fill_char: fill_char
      }

      # WHEN
      {status, resp_body} =
        request(:post, Path.join(@canvas_path, "#{canvas.id}/drawings"), params)

      # THEN
      assert 201 = status
      assert resp_body =~ "Drawing added successfully"

      {200, canvas_bin} = request(:get, Path.join(@canvas_path, "#{canvas.id}"), nil)
      assert canvas_bin =~ drawing_fixture()

      # cleanup
      :mnesia.clear_table(Canvas)
      :mnesia.clear_table(Draw)
    end

    test "POST #{@canvas_path}/:id/drawings returns not found error when passed canvas id does not exist" do
      [{x, y}, width, height, outline_char, fill_char] = drawing_fixture_spec()

      params = %{
        type: "rectangle",
        init_point: [x, y],
        width: width,
        height: height,
        outline_char: outline_char,
        fill_char: fill_char
      }

      # WHEN
      {status, resp_body} = request(:post, Path.join(@canvas_path, "12345/drawings"), params)

      # THEN
      assert 404 = status
      assert resp_body =~ "Canvas not found"
    end

    @rectangle_drawing_params %{
      type: "rectangle",
      init_point: [1, 2],
      width: 2,
      height: 2,
      outline_char: "@",
      fill_char: "O"
    }

    for {error, params} <- [
          {:unknown_type, %{@rectangle_drawing_params | type: "wrong_type"}},
          {:width_not_integer, %{@rectangle_drawing_params | width: "1"}},
          {:outline_and_fill_chars_null,
           %{@rectangle_drawing_params | outline_char: nil, fill_char: nil}},
          {:outline_char_not_string, %{@rectangle_drawing_params | outline_char: 1}},
          {:outline_char_too_long, %{@rectangle_drawing_params | outline_char: "@@"}}
        ] do
      test "POST #{@canvas_path}/:id/drawings returns bad request error when" <>
             " trying to create a rectangle drawing with bad params (#{error})",
           %{canvas: canvas} do
        # WHEN
        {status, resp_body} =
          request(
            :post,
            Path.join(@canvas_path, "#{canvas.id}/drawings"),
            unquote(Macro.escape(params))
          )

        # THEN
        assert 400 = status
        assert resp_body =~ "Bad request"
      end
    end
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
