defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end

  def store(worker_pid, key, data) do
    GenServer.cast(worker_pid, {:store, key, data})
  end

  def get(worker_pid, key) do
    GenServer.call(worker_pid, {:get, key})
  end

  @impl GenServer
  def init(db_folder) do
    IO.puts("Starting database worker. Persistence directory is #{db_folder}")
    File.mkdir_p(db_folder)
    {:ok, %{db_folder: db_folder}}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, state) do
    state.db_folder
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))

    IO.inspect("#{inspect(self())}: storing #{inspect(key)}")

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    data =
      case File.read(file_name(state.db_folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    IO.inspect("#{inspect(self())}: fetching #{inspect(key)}")

    {:reply, data, state}
  end

  defp file_name(db_folder, key) do
    path = Path.join(db_folder, to_string(key))
    IO.puts("persistence file name is #{path}")
    path
  end
end
