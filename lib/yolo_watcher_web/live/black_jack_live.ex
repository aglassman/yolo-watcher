defmodule YoloWatcherWeb.BlackJackLive do
  @moduledoc """
  This module contains the LiveView for the blackjack detection page.

  Detections are received via the YoloWatcher.PubSub, "detection" topic.

  Detections are fifo, and only the last 50 are kept.

  The buffer can be reset, and collection can be paused and resumed.
  """
  use Phoenix.LiveView

  alias YoloWatcherWeb.BlackJackLive.Components

#  @width 640
  @height 480
  @detection_buffer 50

  def mount(_, _, socket) do
    if connected?(socket) do
      :ok = Phoenix.PubSub.subscribe(YoloWatcher.PubSub, "detection")
    end

    {:ok, assign(socket, collecting: true, detections: [], analysis: analysis(:default))}
  end

  def handle_info({:new_detection, _, detection}, socket) do
    if socket.assigns.collecting do
      detections = [detection | socket.assigns.detections] |> Enum.take(@detection_buffer)

      current_analysis = analysis(detections)

      {:noreply, assign(socket, detections: detections, analysis: current_analysis)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("reset", _value, socket) do
    {:noreply, assign(socket, detections: [], analysis: analysis(:default))}
  end

  def handle_event("pause", _value, socket) do
    {:noreply, assign(socket, collecting: false)}
  end

  def handle_event("resume", _value, socket) do
    {:noreply, assign(socket, collecting: true)}
  end

  def format_point(x, y), do: "(#{trunc(Float.round(x, 2))}, #{trunc(Float.round(y, 2))})"
  def format_conf(conf), do: trunc((conf || 0) * 100)
  def tf(float), do: Float.round(float, 2)

  def card_path(class_name) do
    [rank, suit] =
      case String.graphemes(class_name) do
        ["1", "0", suit] -> ["10", suit]
        card -> card
      end

    suit =
      case suit do
        "H" -> "hearts"
        "D" -> "diamonds"
        "C" -> "clubs"
        "S" -> "spades"
      end

    rank =
      case rank do
        "A" -> "ace"
        "K" -> "king"
        "Q" -> "queen"
        "J" -> "jack"
        _ -> rank
      end

    "/images/cards/#{rank}_of_#{suit}.png"
  end

  def analysis(:default) do
    %{
      total_detections: 0,
      distinct_detections: 0,
      frequencies: []
    }
  end

  @doc """
  Given a list of detections, perform a basic aggregation.

  Output:
  ```
  %{
    total_detections: total_detections, # The total number of detections.
    distinct_detections: distinct_detections, # The number of unique card types detected.
    frequencies: frequencies # List of unique card types and their counts.
  }
  ```

  Each unique card will have a value in the frequencies list, sorted by count, descending.
  ```
  %{
     count: count, # The number of detections for card type.
     points: points, # List of the points for detections of the card type.
     avg_x: tx / count, # Average x position of the card derived from the points.
     avg_y: ty / count, # Average y position of the card derived from the points.
     average_confidence: Enum.sum(confs) / count, # Average confidence of the detections.
     max_confidence: Enum.max(confs), # Maximum confidence of the detections.
     min_confidence: Enum.min(confs) # Minimum confidence of the detections.
   }
  ```

  """
  def analysis(detections) do
    total_detections = Enum.count(detections)

    frequencies =
      detections
      |> Enum.reduce(%{}, fn detection, acc ->
        class = detection["cls_n"]

        Map.update(
          acc,
          class,
          %{
            count: 1,
            confidences: [detection["conf"]],
            points: [detection["xyxy"]]
          },
          &%{
            &1
            | count: &1.count + 1,
              confidences: [detection["conf"] | &1.confidences],
              points: [detection["xyxy"] | &1.points]
          }
        )
      end)
      |> Enum.map(fn {class, %{count: count, confidences: confs, points: points}} ->
        {tx, ty} = Enum.reduce(points, {0, 0}, fn [x1, y1 | _], {x, y} -> {x + x1, y + y1} end)

        {class,
         %{
           count: count,
           points: points,
           avg_x: tx / count,
           avg_y: ty / count,
           average_confidence: Enum.sum(confs) / count,
           max_confidence: Enum.max(confs),
           min_confidence: Enum.min(confs)
         }}
      end)
      |> Enum.sort_by(fn {_, %{count: count}} -> count end, :desc)

    distinct_detections = Enum.count(frequencies)

    %{
      total_detections: total_detections,
      distinct_detections: distinct_detections,
      frequencies: frequencies
    }
  end

  defp key_func({_class, %{avg_y: y}}) do
    if y >= @height / 2 do
      :player
    else
      :dealer
    end
  end

  defp key_func(_) do
    true
  end

  @doc """
  Given a list of detections, suggest a strategy based on the detections.

  First, the detections are analyzed using the `analysis/1` function.
  The unique card types are then grouped by their position on the screen.

  Player cards are assumed to be in the top half of the screen, and dealer cards are assumed to be in the bottom half.

  The top two player cards and the top dealer card are selected based on the maximum confidence.

  Finally, the selected cards are used to suggest a strategy.
  """
  def suggest_strategy(detections) do
    %{
      frequencies: frequencies
    } = analysis(detections)

    {player_side_cards, dealer_side_cards} =
      case Enum.group_by(frequencies, &key_func/1) do
        %{
          player: p,
          dealer: d
        } ->
          {p, d}

        _ ->
          {[], []}
      end

    player_cards =
      player_side_cards
      |> Enum.sort_by(fn {_, %{max_confidence: x}} -> x end, :desc)
      |> Enum.take(2)

    dealer_cards =
      dealer_side_cards
      |> Enum.sort_by(fn {_, %{max_confidence: x}} -> x end, :desc)
      |> Enum.take(1)

    case {player_cards, dealer_cards} do
      {[{player_a, _}, {player_b, _}], [{dealer, _}]} ->
        {action, action_text} =
          YoloWatcher.BasicStrategy.best_strategy([player_a, player_b], dealer)

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
