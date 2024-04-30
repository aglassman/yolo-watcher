defmodule YoloWatcher.BasicStrategy do
  @moduledoc """
  This module contains functions that are used to determine the best strategy for playing blackjack.

  Based off Basic Strategy from https://www.blackjackapprenticeship.com/blackjack-strategy-charts/
  """

  @type action :: :hit | :stand | :double | :split | :split_and_double | :surrender

  @points %{
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "10" => 10,
    "J" => 10,
    "Q" => 10,
    "K" => 10,
    "A" => 11
  }

  @doc """
  Given a rank and suit, return the best strategy to play using Blackjack Basic Strategy.

  Cards are represented as strings with the rank followed by the suit. For example, the Ace of Spades is "AS".

  ## Opts
  * :ls - Whether or not late surrender is allowed. Defaults to false.
  * :das - Whether or not double after split is allowed. Defaults to false.
  * :dd - Whether or not double down is allowed. Defaults to false.
  """
  @spec best_strategy(player_hand :: list(String.t()), dealer_upcard :: String.t()) :: {action, String.t()}
  def best_strategy(player_hand, dealer_upcard, opts \\ []) do
    allow_surrender? = Keyword.get(opts, :ls, false)
    double_after_split? = Keyword.get(opts, :das, false)
    double_down? = Keyword.get(opts, :dd, false)

    player = player_hand |> Enum.map(&parse_card/1) |> Enum.sort(:desc)
    dealer = parse_card(dealer_upcard)

    Enum.find(
      [
        surrender(player, dealer, allow_surrender?),
        split(player, dealer, double_after_split?),
        soft(player, dealer, double_down?),
        hard(player, dealer, double_down?),
      ],
      &(is_tuple(&1))
    )

  end

  def parse_card(card_string) do
    rank = case String.graphemes(card_string) do
      ["1", "0" | _] -> "10"
      [rank | _] ->  rank
    end
    @points[rank]
  end

  def surrender([a, b], dealer, true) when  (a + b == 16 and dealer >= 9) or (a + b == 15 and dealer == 10), do: :surrender
  def surrender(_, _, _), do: nil

  def split([11, 11], _dealer, _das), do: {:split, "Always split Aces."}
  def split([9, 9], dealer, _das) when dealer in [2, 3, 4, 5, 6, 8, 9], do: {:split, "Split 9s except against 7, 10, or Ace."}
  def split([8, 8], _dealer, _das), do: {:split, "Always split 8s."}
  def split([7, 7], dealer, _das) when dealer < 8, do: {:split, "Split 7s against dealer 2-7."}
  def split([6, 6], 2, true), do: {:split_and_double, "Split 6s against dealer 2 with double after split."}
  def split([6, 6], dealer, _das) when dealer in [3, 4, 5, 6], do: {:split, "Split 6s against dealer 3-6."}
  def split([4, 4], dealer, true) when dealer in [5, 6], do: {:split_and_double, "Split 4s against dealer 5 or 6 with double after split."}
  def split([x, x], dealer, true) when x in [2, 3] and dealer in [2, 3], do: {:split_and_double, "Split 2s and 3s against dealer 2 or 3 with double after split."}
  def split([x, x], dealer, _das) when x in [2, 3] and dealer in [4, 5, 6, 7], do: {:split, "Split 2s and 3s against dealer 4-7."}
  def split(_, _, _), do: nil

  def soft([11, 9], _dealer, _dd), do: {:stand, "Always stand on soft 20."}
  def soft([11, 8], 6, true), do: {:double, "Double on 19 against dealer 6."}
  def soft([11, 8], _dealer, _dd), do: {:stand, "Always stand on soft 19."}
  def soft([11, 7], dealer, true) when dealer < 7, do: {:double, "Double on soft 18 against dealer 2-6."}
  def soft([11, 7], dealer, _dd) when dealer < 9, do: {:stand, "Stand on soft 18 against dealer 2-8."}
  def soft([11, 6], dealer, true) when dealer in [3, 4, 5, 6], do: {:double, "Double on soft 17 against dealer 3-6."}
  def soft([11, x], dealer, true) when x in [4, 5] and dealer in [4, 5, 6], do: {:double, "Double on soft #{11 + x} against dealer 4-6."}
  def soft([11, x], dealer, true) when x in [2, 3] and dealer in [5, 6], do: {:double, "Double on soft #{11 + x} against dealer 5 or 6."}
  def soft([11, x], dealer, _dd), do: {:hit, "Always hit on soft #{11 + x} against dealer #{dealer}."}
  def soft(_, _, _), do: nil

  def hard([a, b], _dealer, _dd) when (a + b) >= 17, do: {:stand, "Always stand on hard 17 or higher."}
  def hard([a, b], dealer, _dd) when (a + b) > 12 and dealer < 7, do: {:stand, "Stand on hard 13-16 against dealer 2-6."}
  def hard([a, b], dealer, _dd) when (a + b) == 12 and dealer in [4, 5, 6], do: {:stand, "Stand on hard 12 against dealer 4-6."}
  def hard([a, b], _dealer, true) when (a + b) == 11, do: {:double, "Double on hard 11."}
  def hard([a, b], dealer, true) when (a + b) == 10 and dealer < 10, do: {:double, "Double on hard 10 against dealer 2-9."}
  def hard([a, b], dealer, true) when (a + b) == 9 and (dealer in [3, 4, 5, 6]), do: {:double, "Double on hard 9 against dealer 3-6."}
  def hard([a, b], _, _), do: {:hit, "Always hit on hard #{a + b} or lower."}

end