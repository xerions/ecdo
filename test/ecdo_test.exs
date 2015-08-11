defmodule City do
  use Ecto.Model

  schema "city" do
    field :name, :string
    field :country, :string
    has_many :weathers, Weather
  end
end

defmodule Weather do
  use Ecto.Model

  schema "weather" do
    belongs_to :city, City
    field :name, :string
    field :temp_lo, :integer
    field :temp_hi, :integer
    field :meta,    :map
    field :prcp,    :float, default: 0.0
    timestamps
  end
end

import Ecto.Query
import Ecdo

defmodule EcdoTest do
  use ExUnit.Case
  doctest Ecdo

  test "basic query check" do
    assert from(w in Weather) == query({"w", Weather}, %{}).query
    # basic list interface
    assert inspect(from(w in Weather, where: w.temp_lo == 20)) == inspect(query({"w", Weather}, %{where: [{:==, "w.temp_lo", 20}]}).query)
    assert inspect(from(w in Weather, where: w.temp_lo == 20)) == inspect(query(Weather, %{where: [{:==, "temp_lo", 20}]}).query)
    assert inspect(from(w in Weather, where: w.temp_lo == 20)) == inspect(query(Weather, %{where: [{:==, "weather.temp_lo", 20}]}).query)
    assert inspect(from(w in Weather, where: w.temp_lo == 20)) == inspect(query({"w", Weather}, %{"where" => "w.temp_lo == 20"}).query)
    assert inspect(from(w in Weather, where: w.temp_lo == 20)) == inspect(query({"w", Weather}, %{"where" => "w.temp_lo == 20", unknow_key: 1}).query)
    assert inspect(from(w in Weather, where: w.temp_lo == 20)) == inspect(query({"w", Weather}, %{"where" => "w.temp_lo == 20", "unknow_key" => 1}).query)
  end
end
