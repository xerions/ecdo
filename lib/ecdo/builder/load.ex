defmodule Ecdo.Builder.Load do
  @moduledoc """
  Used to load sources
  """
  import Kernel, except: [apply: 2]
  use Ecdo.Builder.Data

  @doc false
  def apply(ecdo, content) do
    root = ecdo.modules[0]
    put_in_query(ecdo, build(root, ecdo.query, content))
  end

  defp build(model, query, %{preload: list}) when is_list(list) or is_binary(list) do
    list |> tokens |> Enum.reduce(query, fn(el, q) -> build1(model, q, %{preload: el}) end)
  end
  defp build(model, query, %{load: list}), do: build(model, query, %{preload: list})
  defp build(_, query, _), do: query

  defp build1(model, query, %{preload: table}) do
    table = to_atom(table)
    if table in model.__schema__(:associations) do
      from(x in query, preload: ^table)
    else query
    end
  end

  defp to_atom(table) when is_atom(table), do: table
  defp to_atom(table) when is_binary(table), do: String.to_atom(table)
  defp to_atom(table) when is_list(table), do: String.to_atom(to_string(table))
end
