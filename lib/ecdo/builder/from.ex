defmodule Ecdo.Builder.From do
  @moduledoc """
  Used to build `from` sources
  """
  import Kernel, except: [apply: 2]
  import Ecto.Query

  @doc false
  def apply(%Ecdo{sources: sources, modules: modules, count: count} = ecdo, {name, model}),
    do: %{ecdo | sources: Map.put(sources, name, count),
                 modules: Map.put(modules, count, model),
                 count: count + 1,
                 query: from(c in model)}
  def apply(%Ecdo{sources: sources, modules: modules, count: count} = ecdo, model),
    do: %{ecdo | sources: Map.put(sources, model.__schema__(:source), count),
                 modules: Map.put(modules, count, model),
                 count: count + 1,
                 query: from(c in model)}
end
