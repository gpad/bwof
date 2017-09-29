defmodule BwofWeb.PageController do
  use BwofWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", number_of_process: :erlang.system_info(:process_count)
  end
end
