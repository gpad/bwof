```shell
cd ~/workspace/italian-elixir/meetup-milano-30-sept-2017/bwof/_build/prod/rel/bwof

http://localhost:4000/

./bin/bwof start

http://localhost:4000/

```
Press GO!!! -> Number of process increase!!

```shell
./bin/bwof remote_console
tail -f var/log/erlang.log.
```

```elixir
Process.list |> length

l1 = Process.list

# execute some code

l2 = Process.list

leak = l2 -- l1

length leak

Process.info(hd(leak))

leak |> Enum.map(fn pid -> Process.info(pid) end)
leak |> Enum.map(fn pid -> Process.info(pid, :dictionary) end)
leak |> Enum.map(fn pid -> Process.info(pid, :dictionary) end) |>
  Enum.map(fn {_, kl} -> Keyword.get(kl, :"$initial_call") end)

```

```elixir
#enable log

# see log here
# tail -f _build/prod/rel/bwof/var/log/erlang.log.1

Logger.info("Start executor number: #{index}")

l1 = Process.list

# execute some code with crash

l2 = Process.list

leak = l2 -- l1

length(l1)
length(l2)
length(leak)

#why leak is empty??

# Solve in this way
:timer.apply_after(1000, Process, :exit, [self(), :exit])
```
