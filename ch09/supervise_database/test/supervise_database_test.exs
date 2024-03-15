defmodule SuperviseDatabaseTest do
  use ExUnit.Case
  doctest SuperviseDatabase

  test "greets the world" do
    assert SuperviseDatabase.hello() == :world
  end
end
