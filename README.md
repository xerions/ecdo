Ecdo [![Build Status](https://travis-ci.org/xerions/ecdo.svg)](https://travis-ci.org/xerions/ecdo) [![Coverage Status](https://coveralls.io/repos/xerions/ecdo/badge.svg?branch=master&service=github)](https://coveralls.io/github/xerions/ecdo?branch=master)
====

Like an [ecto](https://github.com/elixir-lang/ecto), but dynamic. EcDo.
Ecto is a domain specific language for writing queries and interacting with databases in Elixir.
Ecdo is a dynamic interface for ecto.

Dynamic interface to ecto functionallity. Ecdo was build for accessing it from erlang(elixir need to be in path)
or simplify building dynamic interface, like API.

Example of using from erlang:

```
'Elixir.Ecdo':query({<<"weather">>, 'Elixir.Weather'}, #{<<"where">> => [{'==', <<"weather.id">>, 1}]})
'Elixir.Ecdo':query({<<"weather">>, 'Elixir.Weather'}, #{<<"where">> => <<"weather.id == 1">>})
```

Example of use from elixir:

```elixir
Ecdo.query {"weather", Weather}, %{"where" => "weather.id == 1"}
```

Simple example of building API:

```elixir
defmodule Weather.Api do
  def json(json) do
    map = Poison.decode! json
    # may be restrict something
    Ecdo.query({"weather", Weather}, map) |> Repo.all
  end
end

Weather.Api.json ~S({"where": "weather.temp_lo > 25", "limit": 10})
```
