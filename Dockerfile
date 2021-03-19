FROM elixir:1.11.2-alpine as build

WORKDIR /tmp/canvas

COPY . .

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

RUN MIX_ENV=prod mix release

FROM alpine

RUN apk update && \
    apk add --no-cache \
    ncurses-libs

RUN addgroup -S canvas && adduser -S canvas -G canvas

WORKDIR /home/canvas

COPY --from=build /tmp/canvas/_build/prod/rel/canvas ./

RUN chown -R canvas:canvas .

USER canvas

EXPOSE 4000

CMD ["bin/canvas", "start"]

