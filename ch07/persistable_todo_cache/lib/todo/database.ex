defmodule Todo.Database do
  use GenServer

  @db_folder ".persist"

  def start(worker_pool_size) do
    GenServer.start(__MODULE__, worker_pool_size, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  @impl GenServer
  @spec init(any()) :: {:ok, any()}
  def init(worker_pool_size) do
    File.mkdir_p!(@db_folder)

    state =
      Enum.reduce(0..worker_pool_size, %{}, fn i, state ->
        worker_pid = start_worker(i)
        state = Map.put(state, i, worker_pid)
        state
      end)

    IO.puts("Database workers PIDs")
    IO.inspect(state)

    {:ok, {worker_pool_size, state}}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, {worker_pool_size, state}) do
    worker_hash = :erlang.phash2(key, worker_pool_size)
    worker_pid = Map.get(state, worker_hash)
    IO.inspect(state, label: "This is the current state")
    IO.inspect(worker_pid, label: "This is the PID of the worker")
    IO.puts("Worker for key #{key} (hash: #{worker_hash})")
    {:reply, worker_pid, {worker_pool_size, state}}
  end

  defp start_worker(i) do
    {:ok, pid} = Todo.DatabaseWorker.start("#{@db_folder}/worker_dir_#{i}")
    pid
  end
end
