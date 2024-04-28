defmodule YoloWatcherWeb.BlackJackLive do
  use Phoenix.LiveView

  def mount(_, _, socket) do

    if connected?(socket) do
      :ok = Phoenix.PubSub.subscribe(YoloWatcher.PubSub, "detection")
    end

    {:ok, assign(socket, detections: [], frequencies: %{})}
  end

  def handle_info({:new_detection, _, detection}, socket) do

    detections = [detection | socket.assigns.detections]

    frequencies = Enum.frequencies_by(detections, &(&1["cls_n"]))

    {:noreply, assign(socket, detections: detections, frequencies: frequencies)}
  end

  def format_point(x, y), do: "(#{trunc(Float.round(x, 2))}, #{trunc(Float.round(y, 2))})"
  def format_conf(conf), do: trunc((conf || 0) * 100)

  @doc """
  a detection is a map with the following keys:
  "xyxy" - a list of 4 integers representing the bounding box of the detection (x1, y1, x2, y2)
  "conf" - a float representing the confidence of the detection
  "cls_id" - an integer representing the class id of the detection
  "cls_n" - a string representing the class name of the detection
  """
  def render(assigns) do
    ~H"""
    <div>
      <div class="bg-gray-800 text-white p-4">
        <h1 class="text-2xl font-bold">YOLO - BlackJack Watcher</h1>
      </div>
      <div class="flex space-x-8 p-8">
        <div>
          <h2 class="text-lg font-bold">Latest Detections</h2>
          <div class="min-w-md p-4">
            <ul>
              <!-- list the last 10 matches in a nice format -->
              <%= for %{"xyxy" => [x1, y1, x2, y2]} = detection <- Enum.take(assigns.detections, 10) do %>
                <li class="p-4 border border-gray-300 rounded-lg mb-4">
                  <div class="flex justify-between">
                    <div>
                      <p class="text-lg font-bold"><%= detection["cls_n"] %></p>
                      <p class="text-sm text-gray-500">Confidence: <%= format_conf(detection["conf"]) %></p>
                    </div>
                    <div>
                      <p class="text-sm text-gray-500">x1: <%= "p1: #{format_point(x1, y1)}" %></p>
                      <p class="text-sm text-gray-500">x1: <%= "p1: #{format_point(x2, y2)}" %></p>
                    </div>
                  </div>
                </li>
              <% end %>
            </ul>
          </div>
        </div>
        <div>
          <h2 class="text-lg font-bold">Frequencies</h2>
          <div class="min-w-md p-4">
            <ul>
              <!-- list the frequencies of the classes in a nice format -->
              <%= for {cls_n, count} <- Enum.sort_by(@frequencies, fn {_, count} -> count end, :desc) do %>
                <li class="p-4 border border-gray-300 rounded-lg mb-4">
                  <div class="flex justify-between">
                    <div>
                      <p class="text-lg font-bold"><%= cls_n %></p>
                      <p class="text-sm text-gray-500">Count: <%= count %></p>
                    </div>
                  </div>
                </li>
              <% end %>
            </ul>
          </div>
        </div>
      </div>
    </div>
    """
  end
end