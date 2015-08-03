defmodule Ecdo.Builder.Select do
  use Ecdo.Builder.Data

  def apply(ecdo, %{select: string} = content),
    do: put_in_query(ecdo, &(%{&1 | select: build_select(string, content[:select_as] || :map, ecdo)}))
  def apply(ecdo, _),
    do: ecdo

  defp build_select(select, select_as, ecdo) do
    ast = String.split(select, ",") |> Enum.map(fn(value) ->
      field_ast = field_ecto(value, ecdo) |> field_ast()
      case select_as do
        is when is in [:map, :keyword] ->
          {value, field_ast}
        is when is in [:list, :one] ->
          field_ast
      end
    end)
    %SelectExpr{expr: to_expr(ast, select_as)}
  end

  defp to_expr(ast, :map), do: map_ast(ast)
  defp to_expr([ast], :one), do: ast
  defp to_expr(ast, _), do: ast
end
