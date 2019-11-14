defmodule LiveGraphTestWeb.PageController do
  use LiveGraphTestWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
