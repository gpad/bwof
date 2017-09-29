defmodule BwofWeb.ExecutionController do
  use BwofWeb, :controller

  def create(conn, %{"count" => count, "crash" => crash}) do
    start_process(count)
    if crash do
      1 / 0
    end
    redirect(conn, to: page_path(conn, :index))
  end

  def create(conn, %{"count" => count}) do
    start_process(count)
    redirect(conn, to: page_path(conn, :index))
  end

  defp start_process(count) when is_binary(count) do
    {n, ""} = Integer.parse(count)
    start_process(n)
  end
  defp start_process(count) when is_number(count) do
    (1..count) |> Enum.each(fn n -> Executor.start_link(n) end)
  end
end
