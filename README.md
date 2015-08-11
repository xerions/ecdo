Ecdo [![Build Status](https://travis-ci.org/xerions/ecdo.svg)](https://travis-ci.org/xerions/ecdo) [![Coverage Status](https://coveralls.io/repos/xerions/ecdo/badge.svg?branch=master&service=github)](https://coveralls.io/github/xerions/ecdo?branch=master)
====

Like an [ecto](https://github.com/elixir-lang/ecto), but dynamic. EcDo.
Ecto is a domain specific language for writing queries and interacting with databases in Elixir.
Ecdo is a dynamic interface for ecto.

Ecdo was build for accessing it from erlang(elixir need to be in path)
or simplify building dynamic interface, for example API.

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

# Example of use:

Weather.Api.json ~S({"where": "weather.temp_lo > 25", "limit": 10})
```

Due to some direct manipulations with ecto intern AST, ecdo aims to have always close to 100% of test cover.

## Usage

You need to add both Ecdo and the database adapter as a dependency to your `mix.exs` file. The supported databases and their adapters are:

Database                | Ecto Adapter           | Dependency
:---------------------- | :--------------------- | :-------------------
PostgreSQL              | Ecto.Adapters.Postgres | [postgrex][postgrex]
MySQL                   | Ecto.Adapters.MySQL    | [mariaex][mariaex]
MSSQL                   | Tds.Ecto               | [tds_ecto][tds_ecto]
SQLite3                 | Sqlite.Ecto            | [sqlite_ecto][sqlite_ecto]

[postgrex]: http://github.com/ericmj/postgrex
[mariaex]: http://github.com/xerions/mariaex
[tds_ecto]: https://github.com/livehelpnow/tds_ecto
[sqlite_ecto]: https://github.com/jazzyb/sqlite_ecto

For example, if you want to use MySQL, add to your `mix.exs` file:

```elixir
defp deps do
  [{:mariaex, ">= 0.0.0"},
   {:ecdo, "~> 0.1.0"}]
end
```

and update your applications list to include both projects:

```elixir
def application do
  [applications: [:mariaex, :ecdo]]
end
```
