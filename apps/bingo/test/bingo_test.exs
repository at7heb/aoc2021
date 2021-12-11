defmodule BingoTest do
  use ExUnit.Case
  doctest Bingo

  test "creates the game" do
    g = Bingo.new([[1,2,3,4,5],[6,7,8,9,10],[11,12,13,14,15],[16,17,18,19,20],[21,22,23,24,25]])
    assert is_struct(g)
  end

  test "Cannot solve with 4 numbers" do
    assert Bingo.new([[1,2,3,4,5],[6,7,8,9,10],[11,12,13,14,15],[16,17,18,19,20],[21,22,23,24,25]])
        |> Bingo.call_number(1)
        |> Bingo.call_number(2)
        |> Bingo.call_number(3)
        |> Bingo.call_number(4)
        |> Bingo.is_bingo?() == false
  end

  test "Can solve with 5 numbers (horizontal)" do
    assert Bingo.new([[1,2,3,4,5],[6,7,8,9,10],[11,12,13,14,15],[16,17,18,19,20],[21,22,23,24,25]])
        |> Bingo.call_number(1)
        |> Bingo.call_number(2)
        |> Bingo.call_number(3)
        |> Bingo.call_number(4)
        |> Bingo.call_number(5)
        |> Bingo.is_bingo?() == true
  end

  test "Can solve with 5 numbers (vertical)" do
    assert Bingo.new([[1,2,3,4,5],[6,7,8,9,10],[11,12,13,14,15],[16,17,18,19,20],[21,22,23,24,25]])
        |> Bingo.call_number(1)
        |> Bingo.call_number(6)
        |> Bingo.call_number(11)
        |> Bingo.call_number(16)
        |> Bingo.call_number(21)
        |> Bingo.is_bingo?() == true
  end

  test "Can solve with 5 numbers (horizontal and vertical)" do
    g = Bingo.new([[1,2,3,4,5],[6,7,8,9,10],[11,12,13,14,15],[16,17,18,19,20],[21,22,23,24,25]])
        |> Bingo.call_number(2)
        |> Bingo.call_number(3)
        |> Bingo.call_number(4)
        |> Bingo.call_number(5)
        |> Bingo.call_number(6)
        |> Bingo.call_number(11)
        |> Bingo.call_number(16)
        |> Bingo.call_number(21)
    assert false == Bingo.is_bingo?(g)
    assert true == Bingo.is_bingo?(Bingo.call_number(g,1))
  end

  test "create game with non-unique number" do
    g = Bingo.new([[1,2,3,4,5],[6,7,8,9,10],[11,12,13,14,15],[16,17,18,19,20],[21,22,23,24,1]])
  end
end
