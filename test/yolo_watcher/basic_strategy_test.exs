defmodule YoloWatcher.BasicStrategyTest do
  use ExUnit.Case

  alias YoloWatcher.BasicStrategy

  describe "parse_card" do
    test "parses a card string" do
      for s <- ["H", "D", "C", "S"] do
        assert BasicStrategy.parse_card("A#{s}" ) == 11
        assert BasicStrategy.parse_card("K#{s}") == 10
        assert BasicStrategy.parse_card("Q#{s}") == 10
        assert BasicStrategy.parse_card("J#{s}") == 10
        assert BasicStrategy.parse_card("10#{s}") == 10
        assert BasicStrategy.parse_card("9#{s}") == 9
        assert BasicStrategy.parse_card("8#{s}") == 8
        assert BasicStrategy.parse_card("7#{s}") == 7
        assert BasicStrategy.parse_card("6#{s}") == 6
        assert BasicStrategy.parse_card("5#{s}") == 5
        assert BasicStrategy.parse_card("4#{s}") == 4
        assert BasicStrategy.parse_card("3#{s}") == 3
        assert BasicStrategy.parse_card("2#{s}") == 2
      end
    end
  end

  describe "basic strategy" do
    test "best strategy for player hand and dealer upcard" do
      assert BasicStrategy.best_strategy(["AS", "AS"], "2S") == {:split, "Always split Aces."}
      assert BasicStrategy.best_strategy(["AS", "AS"], "3S") == {:split, "Always split Aces."}
      assert BasicStrategy.best_strategy(["AS", "AS"], "4S") == {:split, "Always split Aces."}
      assert BasicStrategy.best_strategy(["AS", "AS"], "5S") == {:split, "Always split Aces."}
      assert BasicStrategy.best_strategy(["AS", "AS"], "6S") == {:split, "Always split Aces."}
      assert BasicStrategy.best_strategy(["AS", "AS"], "7S") == {:split, "Always split Aces."}
      assert BasicStrategy.best_strategy(["AS", "AS"], "8S") == {:split, "Always split Aces."}
      assert BasicStrategy.best_strategy(["AS", "AS"], "9S") == {:split, "Always split Aces."}
      assert BasicStrategy.best_strategy(["AS", "AS"], "10S") == {:split, "Always split Aces."}
      assert BasicStrategy.best_strategy(["AS", "AS"], "JS") == {:split, "Always split Aces."}
      assert BasicStrategy.best_strategy(["AS", "AS"], "QS") == {:split, "Always split Aces."}
      assert BasicStrategy.best_strategy(["AS", "AS"], "KS") == {:split, "Always split Aces."}
      assert BasicStrategy.best_strategy(["AS", "AS"], "AS") == {:split, "Always split Aces."}
    end
    
    test "always stand on soft 20" do
      assert BasicStrategy.best_strategy(["AS", "9S"], "2S") == {:stand, "Always stand on soft 20."}
      assert BasicStrategy.best_strategy(["AS", "9S"], "3S") == {:stand, "Always stand on soft 20."}
      assert BasicStrategy.best_strategy(["AS", "9S"], "4S") == {:stand, "Always stand on soft 20."}
      assert BasicStrategy.best_strategy(["AS", "9S"], "5S") == {:stand, "Always stand on soft 20."}
      assert BasicStrategy.best_strategy(["AS", "9S"], "6S") == {:stand, "Always stand on soft 20."}
      assert BasicStrategy.best_strategy(["AS", "9S"], "7S") == {:stand, "Always stand on soft 20."}
      assert BasicStrategy.best_strategy(["AS", "9S"], "8S") == {:stand, "Always stand on soft 20."}
      assert BasicStrategy.best_strategy(["AS", "9S"], "9S") == {:stand, "Always stand on soft 20."}
      assert BasicStrategy.best_strategy(["AS", "9S"], "10S") == {:stand, "Always stand on soft 20."}
      assert BasicStrategy.best_strategy(["AS", "9S"], "JS") == {:stand, "Always stand on soft 20."}
      assert BasicStrategy.best_strategy(["AS", "9S"], "QS") == {:stand, "Always stand on soft 20."}
      assert BasicStrategy.best_strategy(["AS", "9S"], "KS") == {:stand, "Always stand on soft 20."}
      assert BasicStrategy.best_strategy(["AS", "9S"], "AS") == {:stand, "Always stand on soft 20."}
    end

    test "soft 19" do
      assert BasicStrategy.best_strategy(["AS", "8S"], "2S") == {:stand, "Always stand on soft 19."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "3S") == {:stand, "Always stand on soft 19."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "4S") == {:stand, "Always stand on soft 19."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "5S") == {:stand, "Always stand on soft 19."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "6S") == {:stand, "Always stand on soft 19."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "6S", dd: true) ==  {:double, "Double on 19 against dealer 6."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "7S") == {:stand, "Always stand on soft 19."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "8S") == {:stand, "Always stand on soft 19."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "9S") == {:stand, "Always stand on soft 19."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "10S") == {:stand, "Always stand on soft 19."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "JS") == {:stand, "Always stand on soft 19."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "QS") == {:stand, "Always stand on soft 19."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "KS") == {:stand, "Always stand on soft 19."}
      assert BasicStrategy.best_strategy(["AS", "8S"], "AS") == {:stand, "Always stand on soft 19."}


    end
  end

end
