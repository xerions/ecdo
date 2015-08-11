defmodule Ecdo.Builder.Join do
  @moduledoc """
  Used to build `join` sources
  """
  import Kernel, except: [apply: 2]
  import Ecto.Query
  use Ecdo.Builder.Data

  @join_direction  [:left_join, :right_join, :full_join, :join]
  @mapping  [left_join: :left, right_join: :right, full_join: :full_join, join: :inner]

  @doc false
  def apply(ecdo, query) do
    Map.keys(query)
    |> Enum.filter(fn(k) -> k in @join_direction end)
    |> Enum.reduce(ecdo, &build(&1, &2, query))
  end

  defp build(direction, ecdo, params) do
    root = ecdo.modules[0]
    associations = root.__schema__(:associations) |> Enum.map(&Atom.to_string(&1))
    Map.get(params, direction)
    |> tokens
    |> Stream.filter(&(&1 in associations))
    |> Enum.map(&String.to_atom/1)
    |> Enum.reduce(ecdo, fn(table, ecdo) ->
                           join_exp = %Ecto.Query.JoinExpr{
                                       assoc: {0, table},
                                       on: %Ecto.Query.QueryExpr{expr: :true, params: []},
                                       qual: @mapping[direction]}
                            %{ecdo | sources: Map.put(ecdo.sources, Atom.to_string(table), ecdo.count),
                                     modules: Map.put(ecdo.modules, ecdo.count, assoc(root, table)),
                                     count: ecdo.count + 1,
                                     query: Map.put(ecdo.query, :joins, get(ecdo.query, :joins) ++ [join_exp])}
                         end)
  end

  defp assoc(root, table), do: root.__schema__(:association, table).related
end
