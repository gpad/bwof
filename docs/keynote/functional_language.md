## Immutability (slide)

```elixir
m = %{a: 1, b: 2}
m = %{m | a: 2}

# Is map changed?
# It is a functional language?
```

```ruby
m = {a: 1, b: 2}
m[:a] = 10
m

p = m
m[:a] = 14
m
p
```

```elixir
m = %{a: 1, b: 2}
m
p = m
m = Map.put(m, :a, 12)
m
p
```

## Operator

```elixir
{:ok, yesterday} = Date.new(2017, 9, 29)
is_map(yesterday)
Map.keys(yesterday)
Map.values(yesterday)

{:ok, today} = Date.new(2017, 9, 30)
is_map(today)
Map.keys(today)
Map.values(today)

yesterday < today

{:ok, tomorrow} = Date.new(2017, 10, 1)
is_map(tomorrow)
Map.keys(tomorrow)
Map.values(tomorrow)

today < tomorrow

# Why???
```
[8.11  Term Comparisons](http://erlang.org/doc/reference_manual/expressions.html#id81316])

## Where do i put my state (slide)

```ruby

class Counter
  def initialize()
    @value = 0
    @count = 0
  end

  def inc_of(value)
    @value = @value + value
    @count = @count + 1
  end

  def value()
    @value
  end

  def count()
    @count
  end
end

counter = Counter.new
counter.value
counter.count

counter.inc_of 12
counter.inc_of 13
counter.inc_of 42

counter.value
counter.count

```

```elixir
defmodule Counter do
  def new() do
    %{count: 0, value: 0}
  end

  def inc_of(state, value) do
    %{state | count: state.count + 1, value: state.value + value}
  end

  def value(state) do
    state.value
  end

  def count(state) do
    state.count
  end
end

c = Counter.new
Counter.inc_of(c, 12)
Counter.inc_of(c, 13)
Counter.inc_of(c, 42)

Counter.value(c)
Counter.count(c)

c = Counter.inc_of(c, 12)
c = Counter.inc_of(c, 13)
c = Counter.inc_of(c, 42)

Counter.value(c)
Counter.count(c)
```


```elixir
defmodule Incrementer do
  def go(counter) do
    Counter.inc_of(counter, :crypto.rand_uniform(1, 100))
  end
end

c = Counter.new
c = Incrementer.go(c)
```

Suppose we have two processes that want increment same counter?

```elixir
defmodule ContIncrementer do
  def go(counter) do
    Counter.inc_of(counter, :crypto.rand_uniform(1, 100))
    :timer.sleep(:crypto.rand_uniform(1, 1000))
    go(counter)
  end
end

counter = Counter.new

pid1 = spawn(fn -> ContIncrementer.go(counter) end)
pid2 = spawn(fn -> ContIncrementer.go(counter) end)

Process.alive?(pid1)
Process.alive?(pid2)

counter
Counter.value(counter)
Counter.count(counter)
```

**Use GenServer**
