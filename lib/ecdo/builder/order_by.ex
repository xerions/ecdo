defmodule Ecdo.Builder.OrderBy do
  @moduledoc """
  Used to build 'order_by'
  """

  use Ecdo.Builder.Data
  import Ecto.Query

  def apply(ecdo, %{order_by: order_by}) do
    order_by |> tokens |> Enum.reduce(ecdo, &build(&2, &1))
  end
  def apply(ecdo, _query), do: ecdo

  def build(ecdo, order_by_content) do
    [field | next] = String.split(order_by_content, ":")
    direction = case next do
      [] -> :asc
      [direction] -> direction |> String.to_atom
    end
    field_ast = field_ecto(field, ecdo) |> field_ast()
    query_expr = %Ecto.Query.QueryExpr{expr: [{direction, field_ast}], params: []}
    %{ecdo | query: Map.put(ecdo.query, :order_bys, get(ecdo.query, :order_bys) ++[query_expr])}
  end

  def quoted_expr(direction, index, field) do
    {direction, {{:., [], [{:&, [], [index]}, field]}, [], []}}
  end
end
