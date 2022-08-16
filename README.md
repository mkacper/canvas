# Notes from the author of the project

Before moving on to the details of the project I'd like to highlight a few
key, from my perspective, things that I hope allow to better understand
this implementation, decisions I made here and in general this project as
a whole.

I consider this project in its current shape to be a quickly written Proof
of Concept rather than a production ready service. Given time limitations
I've done my best to deliver good enough thing. My main focus was on
providing something that works end to end at
the cost of polishing every little detail.

Key things to keep in mind when looking at this project:

- function specs and documentation is missing,
- not enough tests, especially for corner cases,
- `mnesia` is used as a storage (in a dirty way) and that's not the best
    choice for production but good enough for PoC (I was looking for
    something quick and easy to use),
- the module with algorithm implementation should be better tested, not only
    based on fixtures,
- web layer should be spread across router and controller abstractions
    instead of being packed into a single module

What's more, I left some comments in the code explaining it's certain
parts.

I hope you'll like my app!

---

# Canvas

The service exposes an HTTP API that allows to:
- create a canvas
- apply drawings to a canvas
- render a canvas

## HTTP API endpoints

1. Create a canvas
- path: `/api/canvas`
- method: `POST`
- response codes:
    - `201` - canvas created successfully (canvas id is returned)

2. Get a canvas
- path: `/api/canvas/{canvas_id}` - replace `{canvas_id}` with your canvas
    id (returned by the above endpoint)
- method: `GET`
- response codes:
    - `200` - canvas returned successfully
    - `404` - canvas does not exist

3. Apply a drawing to a canvas
- path: `/api/canvas/{canvas_id}/drawings` - replace `{canvas_id}` with your canvas
    id (returned by the endpoint from point no 1)
- method: `POST`
- exemplary body parameters:
    - rectangle drawing
      ```json
      {
        "type": "rectangle",
        "init_point":  [3, 2],
        "width": 5,
        "height": 8,
        "outline_char": "@",
        "fill_char": null
      }
      ```
      > NOTE: `null` value for `outline_char` or `fill_char` means this
      > field will not be used e.g. a rectangle will not be filled.

      > NOTE: One of either `outline_char` or `fill_char` MUST always be
      set to value different than `null`.
    - flood fill drawing
      ```json
      {
        "type": "flood_fill",
        "init_point":  [3, 2],
        "fill_char": "-"
      }
      ```
- response codes:
    - `201` - drawing successfully added
    - `400` - bad request
    - `404` - canvas not found

## Requirements

* Elixir 1.11.2
* Erlang 23.2.3

## Running application locally

Go with one of the ways described below to have the application up and running
on port `4000`.

### Using docker (preferred way)

Run the below commands:

```bash
cd $PROJECT_ROOT_DIR # go to the project root directory
docker build -t canvas . # tested with docker 20.10.5
docker run -p 4000:4000 -d canvas
```

> NOTE: When running on Ubuntu docker commands will most probably require
to be called as a root user.

### Using elixir releases

Run the below commands:

```bash
cd $PROJECT_ROOT_DIR # go to the project root directory
mix deps.get
mix release
_build/dev/rel/canvas/bin/canvas start
```

## Example of interacting with the service API

Run the below commands in the specified order to "draw" such a picture:

```text
--------------......------------
--------------......------------
--------------......------------
OOOOOOOO------......------------
O      O------......------------
O    XXXXX----......------------
OOOOOXXXXX----------------------
-----XXXXX----------------------
--------------------------------
--------------------------------
```

1. Create a canvas:

```bash
curl -i -XPOST -H "Content-Type: application/json" http://localhost:4000/api/canvas
# Response:
# Canvas id: 56043694
CANVAS=your-canvas-id # assign canvas id to a variable

```

2. Create drawings:

```bash
curl -i -H "Content-Type: application/json" \
-d '{"type":"rectangle", "init_point": [14,0], "width": 7, "height": 6, "outline_char": null, "fill_char": "."}' \
http://localhost:4000/api/canvas/$CANVAS/drawings

curl -i -H "Content-Type: application/json" \
-d '{"type":"rectangle", "init_point": [0,3], "width": 8, "height": 4, "outline_char": "O", "fill_char": null}' \
http://localhost:4000/api/canvas/$CANVAS/drawings

curl -i -H "Content-Type: application/json" \
-d '{"type":"rectangle", "init_point": [5,5], "width": 5, "height": 3, "outline_char": "X", "fill_char": "X"}' \
http://localhost:4000/api/canvas/$CANVAS/drawings

curl -i -H "Content-Type: application/json" \
-d '{"type":"flood_fill", "init_point": [0,0], "fill_char": "-"}' \
http://localhost:4000/api/canvas/$CANVAS/drawings
```

3. Render the canvas:

```bash
curl -i -XGET -H "Content-Type: application/json" http://localhost:4000/api/canvas/$CANVAS
```
