defmodule Ecdo do
  @moduledoc """
  Provides the Query function.

  Queries are used to retrieve and manipulate data in a repository (see
  Ecto.Repo). Although this module provides a complete API, supporting
  expressions like `where`, `select` and so forth.
  """
  defstruct [sources: %{}, modules: %{}, count: 0, param: nil, query: %Ecto.Query{}]

  @doc """
  Ecdo is dynamic query interface to ecto. It implements `Ecto.Queryable` protocol, and can be
  mixed and used with other ecto queries.

  Let's see an example:

      defmodule Weather do
        use Ecto.Model

        # weather is the DB table
        schema "weather" do
          field :city,    :string
          field :temp_lo, :integer
          field :temp_hi, :integer
          field :prcp,    :float, default: 0.0
        end
      end

  ## Query

  Ecdo simplify you to write dinamic query engines and send
  them to the repository, which translates them to the underlying database.

  Let's see an example:

      import Ecdo, only: [query: 2]

      query {"w", Weather}, %{where: "w.prcp > 0"}

      # Returns %Weather{} structs matching the query
      Repo.all(query)

  For easy of use, keywords can be as binaries or as atoms. select can be defined as
  list (`["w.id", "w.name"]`) or as string (`"w.id, w.name"`). All existing functionality
  is build to be easy used from CLI, as all of arguments can be unparsed strings. Ecdo take
  care of it.

  The supported keywords are:

    * `:distinct`
    * `:where`
    * `:order_by`
    * `:offset`
    * `:limit`
    * `:join`
    * `:select`
    * `:preload`

  Let's see more examples:

      query {"w", Weather}, %{where: "w.prcp > 0", distinct: true}

      query {"w", Weather}, %{"where" => "w.prcp > 0", "order_by" => "w.id"}

      query {"w", Weather}, %{where: "w.prcp > 0", limit: 10, offset: 10}

      query {"w", Weather}, %{where: "w.prcp > 0", select: "w.prpc"}

      query {"w", Weather}, %{where: "w.prcp > 0", preload: ["city"]}

      query {"w", Weather}, %{where: "w.prcp > 0 and city.id < 10", join: "city"}

      query {"w", Weather}, %{where: "w.prcp > 0 and city.id < 10", join: "city, foobar"}

  """
  def query(source, query) do
    query = Map.keys(query) |> Enum.reduce(%{}, &check_string(&1, query, &2))
    %Ecdo{} |> Ecdo.Builder.From.apply(source)
            |> Ecdo.Builder.Join.apply(query)
            |> Ecdo.Builder.Where.apply(query)
            |> Ecdo.Builder.Select.apply(query)
            |> Ecdo.Builder.OrderBy.apply(query)
            |> Ecdo.Builder.QueryExpr.apply(query)
            |> Ecdo.Builder.Load.apply(query)
  end

  @keys [:where, :select, :select_as, :count, :avg, :sum, :min, :max, :limit, :offset, :distinct,
         :order_by, :load, :preload, :left_join, :right_join, :full_join, :join]
  for key <- @keys do
    defp check_string(unquote(key), %{unquote(key) => value}, acc),
      do: Map.put(acc, unquote(key), value)
    defp check_string(unquote(to_string(key)), %{unquote(to_string(key)) => value}, acc),
      do: Map.put(acc, unquote(key), value)
  end
  defp check_string(_key, _, acc), do: acc
end

defimpl Ecto.Queryable, for: Ecdo do
  def to_query(ecdo), do: ecdo.query
end
