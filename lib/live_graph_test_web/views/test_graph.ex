defmodule LiveGraphTestWeb.TestGraph do
  use Phoenix.LiveView

  def render(assigns) do

    {x, y} = case assigns.points do
      [{{_, _}, point}] -> point
      _ -> {0, 0}
    end

    margin = 10
    left_margin = margin
    right_margin = margin
    top_margin = margin
    bottom_margin = margin

    width = assigns.width
    inner_width = width - left_margin - right_margin
    height = assigns.height
    inner_height = height - top_margin - bottom_margin

    x_scale = case assigns.x_span do
      :auto -> 1
      x_span -> width / x_span
    end

    x_displacement = width - right_margin - x * x_scale
    y_displacement = height

    ~L"""
    <div>new point: (<%= x %>,<%= y %>) </div>
    <svg height="<%= height %>" width="<%= width %>">
      <defs>
        <clipPath id="clipPath">
          <rect x="<%= left_margin %>" y="<%= top_margin %>" width="<%= inner_width %>" height="<%= inner_height %>" />
        </clipPath>
      </defs>

      <rect x="<%= left_margin %>" y="<%= top_margin %>" width="<%= inner_width %>" height="<%= inner_height %>" class="bound-box"/>
      <g style="clip-path: url(#clipPath);">
        <g id="graph1" class="graphs" phx-update="append"
          transform="matrix(<%= x_scale %>,0,0,-1,<%= x_displacement %>,<%= y_displacement %>)">
          <%= for {{x1, y1}, {x2, y2}} <- @points do %>
            <path class="graph-line"
              id="<%= name(x1,y1,x2,y2) %>"
              d="M <%= x1 %>,<%= y1 %> L <%= x2 %>,<%= y2 %>"/>
          <% end %>
        </g>
      </g>
    </svg>

    <div class="column">
    <h2> Graph Settings </h2>
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

    <div class="column">
    <h2> X-Axis Settings </h2>
    <form action="#" submit="">
      <input type="radio" phx-click="x_span_auto" <%= if @x_span == :auto, do: "checked" %>>
        auto<br>
      <input type="radio" <%= unless @x_span == :auto, do: "checked" %>>
        <input id="x-span" type="number" value="<%= @x_span %>" phx-keydown="x_span">
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
      width: 520,
      height: 240,
      x_span: 520)
    {:ok, socket, temporary_assigns: [points: []]}
  end

  def handle_info(:ping, socket) do
    Process.send_after(self(), :ping, 200)
    last = {x1, y1} = socket.assigns.last
    next = {x1 + 5,
      (y1 + Enum.random(-20..20))
      |> max(-10)
      |> min(250)}

    {:noreply, assign(socket, last: next, points: [{last, next}])}
  end

  def handle_event("width", %{"width" => width}, socket) do
    {:noreply, assign(socket, width: String.to_integer(width))}
  end
  def handle_event("height", %{"height" => height}, socket) do
    {:noreply, assign(socket, height: String.to_integer(height))}
  end
  def handle_event("x_span_auto", _, socket) do
    socket |> IO.inspect(label: "103")
    {:noreply, assign(socket, x_span: :auto)}
  end
  def handle_event("x_span", %{"code" => "Enter", "value" => v}, socket) do
    {:noreply, assign(socket, x_span: String.to_integer(v))}
  end
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end
end
