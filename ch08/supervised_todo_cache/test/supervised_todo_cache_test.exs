defmodule SupervisedTodoCacheTest do
  use ExUnit.Case
  doctest SupervisedTodoCache

  test "greets the world" do
    assert SupervisedTodoCache.hello() == :world
  end
end
