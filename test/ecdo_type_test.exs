defmodule Ecdo.Integration.TypeTest do
  use Ecto.Integration.Case

  import Ecto.Query
  import Ecdo

  alias Ecto.Integration.Post
  alias Ecto.Integration.Tag
  alias Ecto.Integration.Custom
  alias Ecto.Integration.TestRepo, as: Repo
  alias Ecto.Integration.PoolRepo

  test "primitive types" do
    integer  = 1
    float    = 0.1
    text     = <<0,1>>
    uuid     = "00010203-0405-0607-0809-0a0b0c0d0e0f"
    datetime = %Ecto.DateTime{year: 2014, month: 1, day: 16,
                              hour: 20, min: 26, sec: 51, usec: 0}

    Repo.insert!(%Post{text: text, public: true, visits: integer, uuid: uuid,
                       counter: integer, inserted_at: datetime, intensity: float})

    # ID
    assert [1] = Repo.all query([{"p", Post}], %{where: [{:==, "p.counter", integer}], select: "p.counter", select_as: :one})
    assert [1] = Repo.all query([{"p", Post}], %{where: "p.counter == 1", select: "p.counter", select_as: :one})
    assert [1] = Repo.all query([{"p", Post}], %{where: "counter == 1", select: "p.counter", select_as: :one})

    # Integers
    assert [1] = Repo.all query([{"p", Post}], %{where: [{:==, "p.visits", integer}], select: "p.visits", select_as: :one})
    assert [1] = Repo.all query([{"p", Post}], %{where: "p.visits == 1", select: "p.visits", select_as: :one})

    # Floats
    assert [0.1] = Repo.all query([{"p", Post}], %{where: [{:==, "p.intensity", float}], select: "p.intensity", select_as: :one})
    assert [0.1] = Repo.all query([{"p", Post}], %{where: "p.intensity == 0.1", select: "p.intensity", select_as: :one})

    # Booleans
    assert [true] = Repo.all query([{"p", Post}], %{where: [{:==, "p.public", true}], select: "p.public", select_as: :one})
    assert [true] = Repo.all query([{"p", Post}], %{where: "p.public == true", select: "p.public", select_as: :one})

    # Binaries
    assert [^text] = Repo.all query([{"p", Post}], %{where: [{:==, "p.text", <<0,1>>}], select: "p.text", select_as: :one})
    # Do not work
   # assert [^text] = Repo.all query([{"p", Post}], %{where: "p.text == <<0,1>>", select: "p.text", select_as: :one})

    # UUID
    assert [^uuid] = Repo.all query([{"p", Post}], %{where: "p.uuid == \"#{uuid}\"", select: "p.uuid", select_as: :one})

    # Datetime
    assert [^datetime] = Repo.all query([{"p", Post}], %{where: "p.inserted_at == \"#{Ecto.DateTime.to_iso8601(datetime)}\"", select: "p.inserted_at", select_as: :one})
  end

#  test "binary id type" do
#    assert %Custom{} = custom = Repo.insert!(%Custom{})
#    bid = custom.bid
#    assert [^bid] = Repo.all(from c in Custom, select: c.bid)
#    assert [^bid] = Repo.all(from c in Custom, select: type(^bid, :binary_id))
#  end
#
  test "composite types in select" do
    assert %Post{} = Repo.insert!(%Post{title: "1", text: "hai"})

    assert [["1", "hai"]] == Repo.all query([{"p", Post}], %{select: "p.title,p.text", select_as: :one})

    assert [[{"p.title", "1"}, {"p.text", "hai"}]] == Repo.all query([{"p", Post}], %{select: "p.title,p.text", select_as: :keyword})

    assert [%{"p.title" => "1", "p.text" => "hai"}] == Repo.all query([{"p", Post}], %{select: "p.title,p.text", select_as: :map})

    #assert [%Post{}] == Repo.all query([{"p", Post}], %{select: "p"})
    # TODO: define, if we need such complex case
    #assert [%{:title => "1", 3 => "hai", "text" => "hai"}] ==
    #       Repo.all(from p in Post, select: %{
    #         :title => p.title,
    #         "text" => p.text,
    #         3 => p.text
    #       })
  end

  @tag :map_type
  test "map type" do
    post1 = Repo.insert!(%Post{meta: %{"foo" => "bar", "baz" => "bat"}})
    post2 = Repo.insert!(%Post{meta: %{foo: "bar", baz: "bat"}})

    assert Repo.all(query([{"p", Post}], %{where: "p.id == #{post1.id}", select: "p.meta", select_as: :one})) ==
           [%{"foo" => "bar", "baz" => "bat"}]

    assert Repo.all(query([{"p", Post}], %{where: "p.id == #{post2.id}", select: "p.meta", select_as: :one})) ==
           [%{"foo" => "bar", "baz" => "bat"}]
  end

  @tag :decimal_type
  test "decimal type" do
    decimal = Decimal.new("1.0")

    Repo.insert!(%Post{cost: decimal})

    assert [^decimal] = Repo.all query([{"p", Post}], %{where: "p.cost == 1.0", select: "p.cost", select_as: :one})
    assert [^decimal] = Repo.all query([{"p", Post}], %{where: "p.cost == 1", select: "p.cost", select_as: :one})
    assert [^decimal] = Repo.all query([{"p", Post}], %{where: [{:==, "p.cost", 1.0}], select: "p.cost", select_as: :one})
    assert [^decimal] = Repo.all query([{"p", Post}], %{where: [{:==, "p.cost", 1}], select: "p.cost", select_as: :one})

  end
end
