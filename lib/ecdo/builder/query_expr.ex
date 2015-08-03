defmodule Ecdo.Builder.QueryExpr do
  @moduledoc """
  Add to query limit, offset and disticts
  """
  use Ecdo.Builder.Data
  @supported_expr [limit: :integer, distincts: :string, offset: :integer]

  @doc false
  def apply(ecdo, content) do
    put_in_query ecdo, fn(query) -> Enum.reduce(@supported_expr, query, &expr(&2, content, &1)) end
  end

  defp expr(query, content, {query_field, type}) do
    case content[query_field] do
      nil   -> query
      value -> Map.put(query, query_field, %QueryExpr{expr: cast(value, type)})
    end
  end

  defp cast(value, :integer) when is_integer(value), do: value
  defp cast(value, :integer), do: String.to_integer(value)
  defp cast(value, :string), do: value
end
