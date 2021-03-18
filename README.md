# Canvas

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `canvas` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:canvas, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/canvas](https://hexdocs.pm/canvas).

```
curl -i -H "Content-Type: application/json" \
-d '{"type":"rectangle", "init_point": [14,0], "width": 7, "height": 6, "outline_char": null, "fill_char": "."}' \
http://localhost:4000/api/canvas/87724173/drawings

curl -i -H "Content-Type: application/json" \
-d '{"type":"rectangle", "init_point": [0,3], "width": 8, "height": 4, "outline_char": "O", "fill_char": null}' \
http://localhost:4000/api/canvas/87724173/drawings

curl -i -H "Content-Type: application/json" \
-d '{"type":"rectangle", "init_point": [5,5], "width": 5, "height": 3, "outline_char": "X", "fill_char": "X"}' \
http://localhost:4000/api/canvas/87724173/drawings

curl -i -H "Content-Type: application/json" \
-d '{"type":"flood_fill", "init_point": [0,0], "fill_char": "-"}' \
http://localhost:4000/api/canvas/87724173/drawings
```
