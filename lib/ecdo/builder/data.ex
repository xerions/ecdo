defmodule Ecdo.Builder.Data do
  @moduledoc """
  Different helpers, to transform string or other structure to ecto query.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      alias Ecto.Query.SelectExpr
      alias Ecto.Query.JoinExpr
      alias Ecto.Query.QueryExpr
      import Ecto.Query
      import Ecdo.Builder.Data
    end
  end

  @doc """
  Replace query in `Ecdo` or apply a fun on it.

  Example:

      iex> Ecdo.Builder.Data.put_in_query ecdo, fn(query) -> from x in query, limit: 10 end
  """
  def put_in_query(%{query: query} = ecdo, fun) when is_function(fun), do: %{ecdo | query: fun.(query)}
  def put_in_query(%{query: _query} = ecdo, value), do: %{ecdo | query: value}

  @doc """
  Parse field to intermediate structure, where it possible to get some additional
  information about this field.

  Output format: {`field name`, `type`, `index in sources`}

  Example:

      iex> Ecdo.Builder.Data.field_ecto("w.id", ecdo)
      {:id, :integer, 0}
  """
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

  @doc """
  Transform intermediate format, which gives `field_ecto` function to an AST.
  """
  def field_ast({field, type, index}, with_type? \\ true) do
    ast = (quote do: (&unquote(index)).unquote(field))
    type = if Ecto.Type.primitive?(type) do type else type.type end
    if with_type?,
      do: put_elem(ast, 1, [ecto_type: type]),
      else: ast
  end

  @doc """
  As parameters will be saved for ecto in form of count (0, 1) it put count
  to an appropriate AST, which ecto waits.
  """
  def param_ast(count) do
    quote do: ^unquote(count)
  end

  @doc """
  Transform AST of keyword to map.
  """
  def map_ast(list) do
    quote do: %{unquote_splicing(list)}
  end

  @doc """
  Get from map a value. If value is nil or there is no key in this map, it returns empty
  list.
  """
  def get(map, key), do: Map.get(map, key) || []

  @doc """
  Parse string to otkens.

  Example:

      iex> Ecdo.Builder.Data.tokens("abc.a, abc.b")
      ["abc.a", "abc.b"]
  """
  def tokens(string) when is_binary(string) do
    string |> String.split(",") |> Enum.map(&String.strip/1)
  end
  def tokens(list) when is_list(list), do: list
end
