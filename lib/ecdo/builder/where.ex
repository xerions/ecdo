defmodule Ecdo.Builder.Where do
  @moduledoc """
  Analyse where conditions and add to a query
  """
  use Ecdo.Builder.Data

  require Record
  Record.defrecordp :params, [dot: false, values: [], count: 0, last: nil, operator: :default]

  @doc false
  def apply(ecdo, %{where: where}), do: put_in_query(ecdo, &(%{&1 | wheres: build(where, ecdo)}))
  def apply(ecdo, _), do: ecdo

  def build(where, ecdo) when is_binary(where) do
    {:ok, conditions} = Code.string_to_quoted(where)
    conditions |> List.wrap |> build_ast(ecdo)
  end
  def build(where, ecdo) when is_list(where) do
    Enum.map(where, &build_conditions(&1, ecdo))
  end

  @like_functions [:like, :ilike]
  @type_operators [:==, :>, :<, :!=, :>=, :<=]
  @allowed_operations [:not, :or, :and | @type_operators]
  @allowed_operations_with_funs @like_functions ++ @allowed_operations

  defp build_conditions({op, _, _} = opspec, ecdo) when op in @allowed_operations_with_funs do
    %QueryExpr{expr: op_ast(opspec, ecdo)}
  end
  defp build_conditions(where, ecdo) when is_binary(where), 
    do: List.first build(where, ecdo)

  defp op_ast({op, left, right}, ecdo) do
    # Build from condition list an AST
    field_ast = case is_binary(left) do
      true -> field_ecto(left, ecdo) |> field_ast()
      false -> op_ast(left, ecdo)
    end
    quote do: unquote(op)(unquote_splicing([field_ast, op_ast(right, ecdo)]))
  end
  defp op_ast(other, _ecdo), do: other

  defp build_ast([ast], ecdo) do
    {expr, params(values: values)} = Macro.prewalk(ast, params(), &to_ecto_ast(&1, &2, ecdo))
    [%QueryExpr{expr: expr, params: Enum.reverse(values)}]
  end

  defp to_ecto_ast({op, _, _} = opast, params, _ecdo) when op in @allowed_operations,
    do: {opast, params(params, operator: :default)}
  defp to_ecto_ast({op, _, _} = opast, params, _ecdo) when op in @like_functions,
    do: {opast, params(params, operator: :function)}
  defp to_ecto_ast({{:., _, _} = field, _, _}, params(operator: operator) = params, ecdo) do
    # We ignore the outer AST, because field_ast add wrapper back
    {field, _type, _index} = field_spec = field_ecto(field, ecdo)
    # Next element in form of {atom, _, nil} is a first part of atom.value call, and should be ignored
    {field_ast(field_spec, operator == :default), params(params, last: field, dot: true)}
  end
  defp to_ecto_ast({_, _, nil} = other, params(dot: true) = params, _ecdo), do: {other, params(params, dot: false)}
  # If it is not a part of atom.value (dot: false), than it should be transformed to field
  defp to_ecto_ast({field_name, _, nil}, params(dot: false, operator: operator) = params, ecdo) do
    {field, _type, _index} = field_spec = field_name |> to_string() |> field_ecto(ecdo)
    # We do not need to set type, if operator is like, we set operator to :function, if we see like
    {field_ast(field_spec, operator == :default), params(params, last: field)}
  end
  defp to_ecto_ast(string, params(operator: :default, last: field, values: values) = params, ecdo) when is_binary(string) do
    {_, _, count} = field_ecto([string], ecdo)
    # as string i our parameter, we should replace it with name of the field and count
    new_params = params(params, last: nil, count: count, values: [{string, {count, field}} | values])
    {param_ast(count), new_params}
  end
  defp to_ecto_ast(other, acc, _ecdo) do
    {other, acc}
  end
end
