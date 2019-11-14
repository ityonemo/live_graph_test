defmodule LiveGraphTestWeb.TestGraph do
  use Phoenix.LiveView

  def render(assigns) do

    right = case assigns.points do
      [{{_, _}, {right, _}}] -> right
      _ -> 0
    end

    margin = assigns.margin
    width = assigns.width
    inner_width = width - 2 * margin
    height = assigns.height
    inner_height = height - 2 * margin

    ~L"""
    <svg height="<%= height %>" width="<%= width %>">
      <defs>
        <clipPath id="clipPath">
            <rect x="<%= margin %>" y="<%= margin %>" width="<%= inner_width %>" height="<%= inner_height %>" />
        </clipPath>
      </defs>

      <rect x="<%= margin %>" y="<%= margin %>" width="<%= inner_width %>" height="<%= inner_height %>" class="bound-box"/>
      <g style="clip-path: url(#clipPath);">
        <g id="graph1" class="graphs" phx-update="append"
          transform="matrix(1,0,0,-1,<%= width - margin - right %>,<%= height %>)">
          <%= for {{x1, y1}, {x2, y2}} <- @points do %>
            <path class="graph-line"
              id="<%= name(x1,y1,x2,y2) %>"
              d="M <%= x1 %>,<%= y1 %> L <%= x2 %>,<%= y2 %>"/>
          <% end %>
        </g>
      </g>
    </svg>

    <div class="left-column">
    <form action="#" phx-submit="width">
      <label for="width">width</label>
      <input type="number" name="width" id="width" value="<%= width %>"><br>
    </form>
    <form action="#" phx-submit="height">
      <label for="height">height</label>
      <input type="number" name="height" id="height" value="<%= height %>"><br>
    </form>
    <form action="#" phx-submit="margin">
      <label for="margin">margin</label>
      <input type="number" name="margin" id="margin" value="<%= margin %>"><br>
    </form>
    </div>

    <div class="center-column">
    <form action="#" phx-submit="xspan">
      <label for="xspan">xspan</label>
      <input type="number" name="xspan" id="xspan" value="500"><br>
    </form>
    </div>
    """
  end

  defp name(x1, y1, x2, y2), do: "line-#{x1}-#{y1}-#{x2}-#{y2}"

  def mount(_session, socket) do
    Process.send_after(self(), :ping, 200)
    socket = assign(socket,
      points: [],
      last: {0, Enum.random(0..200)},
      margin: 10,
      width: 520,
      height: 240)
    {:ok, socket, temporary_assigns: [points: []]}
  end

  def handle_info(:ping, socket) do
    Process.send_after(self(), :ping, 200)
    last = {x1, y1} = socket.assigns.last
    next = {x1 + 5, y1 + Enum.random(-20..20)}

    {:noreply, assign(socket, last: next, points: [{last, next}])}
  end

  def handle_event("width", %{"width" => width}, socket) do
    {:noreply, assign(socket, width: String.to_integer(width))}
  end
  def handle_event("height", %{"height" => height}, socket) do
    {:noreply, assign(socket, height: String.to_integer(height))}
  end
  def handle_event("margin", %{"margin" => margin}, socket) do
    {:noreply, assign(socket, margin: String.to_integer(margin))}
  end
end
