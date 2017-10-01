# BEAM way of life

Example program for [Beam way of life](https://www.slideshare.net/gpadovani/beam-way-of-life-80337975) that was presented [here](http://www.italian-elixir.org/).

The examples can be found in [docs/keynote](https://github.com/gpad/bwof/docs/keynote).

# Application

To start your this application:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

You can execute this to run it as release in production:

```shell
$ MIX_ENV=prod mix release --env=prod && cd _build/prod/rel/bwof && ./bin/bwof console
```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
