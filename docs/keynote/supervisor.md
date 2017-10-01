## Supervisor

Can attach child dynamically

A Step counter
```elixir
defmodule StepCounter do
  use GenServer

  def start_link(step, name) do
    IO.puts("Starting #{inspect name} - step: #{inspect step}")
    GenServer.start_link(__MODULE__, [step], name: name)
  end

  def init([step]) do
    {:ok, %{step: step, value: 0}}
  end

  def inc(counter) do
    GenServer.call(counter, :inc, 60000)
  end

  def dec(counter) do
    GenServer.call(counter, :dec, 60000)
  end

  def value(counter) do
    GenServer.call(counter, :value, 60000)
  end

  def crash(counter) do
    GenServer.cast(counter, :crash)
  end

  def handle_call(:inc, from, %{step: step, value: value} = state) do
    new_value = value + step
    {:reply, new_value, %{state | value: new_value}}
  end

  def handle_call(:value, _from, %{value: value} = state) do
    {:reply, value, state}
  end

  def handle_cast(:crash, state) do
    1/0
    {:noreply, state}
  end
end
```

```elixir
defmodule Abacus do
  use Supervisor
  def start_new_counter(step, name) do
    Supervisor.start_child(__MODULE__, [step, name])
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init(_) do
    child = [
      worker(StepCounter, [], restart: :permanent)
    ]
    supervise(child, strategy: :simple_one_for_one)
  end
end
```

```elixir
Abacus.start_link
Supervisor.which_children Abacus
Abacus.start_new_counter(11, :spinal_tap)
Abacus.start_new_counter(666, :the_beast)
Process.whereis(:spinal_tap) |> Process.alive?
Process.whereis(:the_beast) |> Process.alive?

StepCounter.inc :the_beast
StepCounter.inc :the_beast
Supervisor.which_children(Abacus)
StepCounter.crash :the_beast

Supervisor.which_children(Abacus)
Process.exit(pid(""), :exit)
```

Other Example

```elixir
defmodule Executor do
  use GenServer
  def start_link(func, name, next) do
    GenServer.start_link(__MODULE__, [func, name, next], name: name)
  end

  def init([func, name, next]) do
    IO.puts("Start #{inspect name} -> #{inspect next}")
    {:ok, %{func: func, next: next}}
  end

  def go(server, value) do
    GenServer.cast(server, {:go, value})
  end

  # def handle_call({:connect, next}, _from, state) do
  #   {:reply, :ok, %{state | next: next}}
  # end

  def handle_cast({:go, value}, state) do
    IO.puts("Execute value: #{inspect value}")
    state.func.(value) |> pass_to(state.next)
    {:noreply, state}
  end

  defp pass_to(value, nil) do
    IO.puts ">>> End of pipeline <<<"
    IO.puts " ret: #{inspect value}"
    IO.puts ">>> --------------- <<<"
  end

  defp pass_to(value, next) do
    Executor.go(next, value)
  end
end

defmodule PipelineSupervisor do
  use Supervisor

  def add_pipeline(func, name, next) do
    {:ok, pid} = Supervisor.start_child(__MODULE__, worker(Executor, [func, name, next], id: name))
    pid
  end

  def remove_pipeline(name) do
    Supervisor.terminate_child(__MODULE__, name)
    Supervisor.delete_child(__MODULE__, name)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init(_) do
    supervise([], strategy: :rest_for_one)
  end
end
```

```elixir
{:ok, pid} = Executor.start_link(fn n -> n * 2 end, :test, nil)
Executor.go(pid, 3)

PipelineSupervisor.start_link
PipelineSupervisor.add_pipeline(fn n -> n * 2 end, :start, :p1)
PipelineSupervisor.add_pipeline(fn n -> {n/2, n} end, :p1, :p2)
PipelineSupervisor.add_pipeline(fn n -> n * 3 end, :p2, nil)

Supervisor.which_children PipelineSupervisor

Executor.go(:start, 1)
Supervisor.which_children PipelineSupervisor

PipelineSupervisor.remove_pipeline(:p2)

PipelineSupervisor.add_pipeline(fn {n1, n2} -> n1 + n2 end, :p2, nil)

Supervisor.which_children PipelineSupervisor
Executor.go(:start, 1)
Supervisor.which_children PipelineSupervisor
Executor.go(:start, 'a')
Supervisor.which_children PipelineSupervisor
Executor.go(:start, 1)
```

Think to Supervisor as live structure ...
