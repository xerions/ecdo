defmodule Ecdo.Builder.Select do
  use Ecdo.Builder.Data

  @aggr_funs [:count, :avg, :sum, :min, :max]

  def apply(ecdo, content) do
    case build_select(content, ecdo) do
      [] -> ecdo
      select -> put_in_query(ecdo, &(%{&1 | select: select}))
    end
  end

  defp build_select(content, ecdo) do
    select = Map.get(content, :select) || "" 
    select_as = content[:select_as] || :map
    ast = String.split(select, ",") 
          |> add_funs(content) 
          |> Enum.map(&transform(&1, ecdo, select_as))
    case ast do
      [] -> []
      _ -> %SelectExpr{expr: to_expr(ast, select_as)}
    end
  end

  defp transform({fun, arg}, _ecdo, _select_as), do: {fun, nil, [arg]}
  defp transform(value, ecdo, select_as) do
    field_ast = field_ecto(value, ecdo) |> field_ast()
    case select_as do
      is when is in [:map, :keyword] -> {value, field_ast}
      is when is in [:list, :one] -> field_ast
    end
  end

  defp funs(params) do
    Map.keys(params) |> Enum.map(fn(k) ->
      case k in @aggr_funs do
        true -> {k, Map.fetch!(params, k)}
        false -> []
      end
    end) |> :lists.flatten
  end

  defp add_funs([""], content), do: funs(content)
  defp add_funs(select, content), do: select ++ funs(content)

  defp to_expr(ast, :map), do: map_ast(ast)
  defp to_expr([ast], :one), do: ast
  defp to_expr(ast, _), do: ast
end
