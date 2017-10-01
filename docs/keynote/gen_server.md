## Keep the state in the process (slide)

```elixir
defmodule Counter do
  use GenServer

  def new() do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], [])
    pid
  end

  def init(_) do
    {:ok, %{count: 0, value: 0}}
  end

  def inc_of(counter, value) do
    GenServer.call(counter, {:inc_of, value})
  end

  def value(counter) do
    GenServer.call(counter, :value)
  end

  def count(counter) do
    GenServer.call(counter, :count)
  end

  def handle_call({:inc_of, value}, _from, state) do
    state = %{state | count: state.count + 1, value: state.value + value}
    {:reply, :ok, state}
  end

  def handle_call(:value, _from, state) do
    {:reply, state.value, state}
  end

  def handle_call(:count, _from, state) do
    {:reply, state.count, state}
  end
end

# slightly different
c = Counter.new
Counter.inc_of(c, 12)
Counter.inc_of(c, 13)
Counter.inc_of(c, 42)

Counter.value(c)
Counter.count(c)
```
The state is inside the process

## “Share” state between other processes (slide)
- Synchronize access to state

```elixir
defmodule ContIncrementer do
  def go(module, counter) do
    module.inc_of(counter, :crypto.rand_uniform(1, 100))
    :timer.sleep(:crypto.rand_uniform(1, 1000))
    go(module,counter)
  end
end

counter = Counter.new

pid1 = spawn(fn -> ContIncrementer.go(Counter, counter) end)
pid2 = spawn(fn -> ContIncrementer.go(Counter, counter) end)

Process.alive?(pid1)
Process.alive?(pid2)

Counter.value(counter)
Counter.count(counter)
```

## But it’s a Bottleneck (slide)

```elixir
defmodule SlowCounter do
  use GenServer

  def new() do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], [])
    pid
  end

  def init(_) do
    {:ok, %{count: 0, value: 0}}
  end

  def inc_of(counter, value) do
    GenServer.call(counter, {:inc_of, value}, 60000)
  end

  def value(counter) do
    GenServer.call(counter, :value, 60000)
  end

  def count(counter) do
    GenServer.call(counter, :count, 60000)
  end

  def handle_call({:inc_of, value}, _from, state) do
    :timer.sleep(10000) #wait 10 sec
    state = %{state | count: state.count + 1, value: state.value + value}
    {:reply, :ok, state}
  end

  def handle_call(:value, _from, state) do
    {:reply, state.value, state}
  end

  def handle_call(:count, _from, state) do
    {:reply, state.count, state}
  end
end

sc = SlowCounter.new

# it's still fast
SlowCounter.count(sc)
SlowCounter.value(sc)

pid3 = spawn(fn -> ContIncrementer.go(SlowCounter, sc) end)

# Not so fast ...
SlowCounter.count(sc)
SlowCounter.value(sc)
```

## Spawn & Reply (slide)
We can spawn a new worker so we can free the gen server to better respond to work

```elixir
defmodule SlowButReponsiveCounter do
  use GenServer

  def new() do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], [])
    pid
  end

  def init(_) do
    {:ok, %{count: 0, value: 0}}
  end

  def inc_of(counter, value) do
    GenServer.call(counter, {:inc_of, value}, 60000)
  end

  def value(counter) do
    GenServer.call(counter, :value, 60000)
  end

  def count(counter) do
    GenServer.call(counter, :count, 60000)
  end

  def handle_call({:inc_of, value}, from, state) do
    parent = self()
    spawn_link(fn ->
      :timer.sleep(10000) #wait 10 sec
      GenServer.call(parent, {:update_state, value})
      GenServer.reply(from, :ok)
    end)
    {:noreply, state}
  end

  def handle_call({:update_state, value}, _from, state) do
    state = %{state | count: state.count + 1, value: state.value + value}
    {:reply, :ok, state}
  end

  def handle_call(:value, _from, state) do
    {:reply, state.value, state}
  end

  def handle_call(:count, _from, state) do
    {:reply, state.count, state}
  end
end

sbrc = SlowButReponsiveCounter.new

# fast get but the inc is still slow
SlowButReponsiveCounter.count(sbrc)
SlowButReponsiveCounter.value(sbrc)
SlowButReponsiveCounter.inc_of(sbrc, 42)


pid4 = spawn(fn -> ContIncrementer.go(SlowButReponsiveCounter, sbrc) end)

Process.alive? pid4

# The get still fast
SlowButReponsiveCounter.count(sbrc)
SlowButReponsiveCounter.value(sbrc)

```


## END!


Do you want use ETS ... ?!?

## ETS - how to to use it for don't loose it

ETS to read from extern and synchronize the write?!?
http://learnyousomeerlang.com/ets
http://erlang.org/doc/man/ets.html

http://steve.vinoski.net/blog/2011/03/23/dont-lose-your-ets-tables/
http://steve.vinoski.net/blog/2013/05/08/implementation-of-dont-lose-your-ets-tables/
https://github.com/DeadZen/etsgive
https://github.com/zsoci/ETSHandler
