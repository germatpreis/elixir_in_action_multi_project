defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache_pid} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache_pid, "bob")

    assert bob_pid != Todo.Cache.server_process(cache_pid, "alice")
    assert bob_pid == Todo.Cache.server_process(cache_pid, "bob")
  end

  test "to-do operations" do
    # given
    {:ok, cache_pid} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache_pid, "bob")

    # when
    Todo.Server.add_entry(bob_pid, %{date: ~D[2024-01-01], title: ~c"Dentist"})
    entries = Todo.Server.entries(bob_pid, ~D[2024-01-01])

    # then (use pattern matching to assert that the list of entries
    # has exactly one element with the expected fields)
    assert [%{date: ~D[2024-01-01], title: ~c"Dentist"}] = entries
  end
end
