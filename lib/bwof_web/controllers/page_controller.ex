defmodule BwofWeb.PageController do
  use BwofWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
