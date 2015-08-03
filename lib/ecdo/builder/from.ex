defmodule Ecdo.Builder.From do
  @moduledoc """
  Used to build `from` sources
  """
  import Kernel, except: [apply: 2]
  import Ecto.Query

  def apply(%Ecdo{sources: sources, modules: modules, count: count} = ecdo, {name, model}),
    do: %{ecdo | sources: Map.put(sources, name, count),
                 modules: Map.put(modules, count, model),
                 count: count + 1,
                 query: from(c in model)}
  def apply(ecdo, sources) when is_list(sources),
    do: Enum.reduce(sources, ecdo, &apply(&2, &1))
  def apply(%Ecdo{} = ecdo, model),
    do: %{ecdo | query: from(c in model)}
end
