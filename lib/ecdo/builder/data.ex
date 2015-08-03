defmodule Ecdo.Builder.Data do
  defmacro __using__(_) do
    quote do
      alias Ecto.Query.SelectExpr
      alias Ecto.Query.JoinExpr
      alias Ecto.Query.QueryExpr
      import Ecto.Query
      import Ecdo.Builder.Data
    end
  end

  def put_in_query(%{query: query} = ecdo, fun) when is_function(fun), do: %{ecdo | query: fun.(query)}
  def put_in_query(%{query: query} = ecdo, value), do: %{ecdo | query: value}

  def field_ecto(strings, %{sources: sources, modules: modules}) when is_list(strings) do
    {index, field} = case strings do
      [field]      -> {0, field}
      [key, field] -> {sources[key], field}
    end
    field = String.to_atom(field)
    type = modules[index].__schema__(:type, field)
    # May be not cast to atom?
    {field, type, index}
  end
  def field_ecto(string, ecdo) when is_binary(string),
    do: String.split(string, ".") |> field_ecto(ecdo)
  def field_ecto({:., _, [model, value]}, ecdo),
    do: [Macro.to_string(model), to_string(value)] |> field_ecto(ecdo)

  def field_ast({field, type, index}) do
    ast = (quote do: (&unquote(index)).unquote(field))
    type = if Ecto.Type.primitive?(type) do type else type.type end
    put_elem(ast, 1, [ecto_type: type])
  end

  def param_ast(count) do
    quote do: ^unquote(count)
  end

  def map_ast(list) do
    quote do: %{unquote_splicing(list)}
  end
end
