FROM elixir:1.11

RUN mix local.hex --force
RUN mix local.rebar --force

ARG MIX_ENV=test

WORKDIR /app

COPY mix.exs /app/
COPY mix.lock /app/
COPY config/ /app/config/

RUN mix deps.get
RUN mix deps.compile

COPY bin/ /app/bin/
COPY priv/ /app/priv/
COPY test/ /app/test/
COPY lib/ /app/lib/

RUN MIX_ENV=${MIX_ENV} mix compile

