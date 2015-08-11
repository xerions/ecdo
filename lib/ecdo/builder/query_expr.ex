defmodule Ecdo.Builder.QueryExpr do
  @moduledoc """
  Add to query limit, offset and disticts
  """
  use Ecdo.Builder.Data
  import Ecto.Query
  @supported_expr [:limit, :distinct, :offset]

  @doc false
  def apply(ecdo, content) do
    put_in_query ecdo, fn(query) -> Enum.reduce(@supported_expr, query, &expr(&2, content, &1)) end
  end

  defp expr(query, content, query_field) do
    case content[query_field] do
      nil   -> query
      value -> eval(query, query_field, value)
    end
  end

  # don't generate code for distinct with true and false because it works incorrectly
  defp eval(query, :distinct, true), do: from(x in query, distinct: true)
  defp eval(query, :distinct, false), do: from(x in query, distinct: false)
  for key <- @supported_expr do
    defp eval(query, unquote(key), value), do: from(x in query, [{unquote(key), ^value}])
  end
end
