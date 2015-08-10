defmodule Ecdo do
  @moduledoc """
  Provides the Query function.

  Queries are used to retrieve and manipulate data in a repository (see
  Ecto.Repo). Although this module provides a complete API, supporting
  expressions like `where`, `select` and so forth.
  """
  @derive [Access]
  defstruct [sources: %{}, modules: %{}, count: 0, param: nil, query: %Ecto.Query{}]

  def query(sources \\ [], query) do
    query = Map.keys(query) |> Enum.reduce(%{}, &check_string(&1, query, &2))
    %Ecdo{} |> Ecdo.Builder.From.apply(sources)
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
