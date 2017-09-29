defmodule Executor do
  use GenServer
  require Logger

  def start_link(index) do
    GenServer.start_link(__MODULE__, [index], [])
  end

  def init([index]) do
    {:ok, %{}}
  end

end
