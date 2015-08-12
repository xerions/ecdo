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
    assert inspect(from(w in Weather, where: like(w.name, "aa"))) == inspect(query({"w", Weather}, %{where: [{:like, "w.name", "aa"}]}).query)

    assert inspect(from(w in Weather, where: w.temp_lo == 20)) == inspect(query({"w", Weather}, %{where: [{:==, "w.temp_lo", 20}]}).query)
    assert inspect(from(w in Weather, where: w.temp_lo == 20)) == inspect(query(Weather, %{where: [{:==, "temp_lo", 20}]}).query)
    assert inspect(from(w in Weather, where: w.temp_lo == 20)) == inspect(query(Weather, %{where: [{:==, "weather.temp_lo", 20}]}).query)
    assert inspect(from(w in Weather, where: w.temp_lo == 20)) == inspect(query({"w", Weather}, %{"where" => "w.temp_lo == 20"}).query)
    assert inspect(from(w in Weather, where: w.temp_lo == 20)) == inspect(query({"w", Weather}, %{"where" => "w.temp_lo == 20", unknow_key: 1}).query)
    assert inspect(from(w in Weather, where: w.temp_lo == 20)) == inspect(query({"w", Weather}, %{"where" => "w.temp_lo == 20", "unknow_key" => 1}).query)

    assert inspect(from(w in Weather, where: like(w.name,"abc") or like(w.name, "fff") or like(w.name, "ccc"))) 
           == inspect(query({"w", Weather}, %{"where" => [{:or, {:or, {:like, "w.name", "abc"}, {:like, "w.name", "fff"}},
                                                           {:like, "w.name", "ccc"}}]}).query)
  end
end
