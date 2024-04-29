defmodule YoloWatcherWeb.BlackJackLive do
  use Phoenix.LiveView

  alias YoloWatcherWeb.BlackJackLive.Components

  def mount(_, _, socket) do

    if connected?(socket) do
      :ok = Phoenix.PubSub.subscribe(YoloWatcher.PubSub, "detection")
    end

    {:ok, assign(socket, collecting: true, detections: [], frequencies: %{})}
  end

  def handle_info({:new_detection, _, detection}, socket) do
    if socket.assigns.collecting do
      detections = [detection | socket.assigns.detections] |> Enum.take(200)

      frequencies = detections
                    |> Enum.frequencies_by(&(&1["cls_n"]))
                    |> Enum.sort_by(fn {_, count} -> count end, :desc)

      {:noreply, assign(socket, detections: detections, frequencies: frequencies)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("reset", _value, socket) do
    {:noreply, assign(socket, detections: [], frequencies: %{})}
  end

  def handle_event("pause", _value, socket) do
    {:noreply, assign(socket, collecting: false)}
  end

  def handle_event("resume", _value, socket) do
    {:noreply, assign(socket, collecting: true)}
  end

  def format_point(x, y), do: "(#{trunc(Float.round(x, 2))}, #{trunc(Float.round(y, 2))})"
  def format_conf(conf), do: trunc((conf || 0) * 100)

  def card_path(class_name) do
    [rank, suit] = case String.graphemes(class_name) do
      ["1", "0", suit] -> ["10", suit]
      card -> card
    end
    suit = case suit do
      "H" -> "hearts"
      "D" -> "diamonds"
      "C" -> "clubs"
      "S" -> "spades"
    end
    rank = case rank do
      "A" -> "ace"
      "K" -> "king"
      "Q" -> "queen"
      "J" -> "jack"
      _ -> rank
    end
    "/images/cards/#{rank}_of_#{suit}.png"
  end

  def suggest_strategy(frequencies) do
    case frequencies do
      [{player_a, _}, {player_b, _}, {dealer, _} | _] ->
        {action, action_text} = YoloWatcher.BasicStrategy.best_strategy([player_a, player_b], dealer)
        %{
          player: [player_a, player_b],
          dealer: dealer,
          action: action,
          action_text: action_text
        }

      _ ->
        nil
    end
  end

end