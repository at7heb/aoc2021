defmodule Day4 do
  @moduledoc """
  Documentation for `Day4`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day4.hello()
      :world

  """

  def run() do
    inhalt = read_input()
    |> adjust_input()
    |> parse_input()
    solve(inhalt)
    solve_2(inhalt)
  end

  def solve(%{} = game) do
    bingoed_boards = get_winning_boards(game.boards)
    cond do
      length(game.numbers) == 0 ->
        IO.puts("There are *NO* winning boards")
      length(bingoed_boards) == 0 ->
        next_number = hd(game.numbers)
        new_boards = Enum.map(game.boards, fn board-> Bingo.call_number(board, next_number) end)
        solve(%{game | boards: new_boards, numbers: tl(game.numbers), last_number: next_number})
      length(bingoed_boards) == 1 ->
        # IO.inspect(bingoed_boards, label: "bingoed board")
        # IO.inspect(Enum.at(game.boards, hd(bingoed_boards)-1), label: "Bingoed board")
        IO.puts("The winning board is #{bingoed_boards}")
        calculated_answer = calculate_answer(Enum.at(game.boards, hd(bingoed_boards)-1), game.last_number)
        IO.puts("The calculated answer is #{calculated_answer}")
      true ->
        # IO.inspect(bingoed_boards, label: "bingoed boards")
        IO.puts("The winning games are #{bingoed_boards}")
    end
  end

  def solve_2(%{} = game) do
    IO.puts("-----------")
    IO.puts("Part 2")
    Map.put(game, :last_winner, -1)
    |> Map.put(:last_number, -1)
    |> solve_2a()
  end

  def solve_2a(%{} = game) do
    bingoed_boards_0 = get_winning_boards(game.boards)
    cond do
      length(game.numbers) == 0  or length(game.boards) == length(bingoed_boards_0) ->
        solve_2b(game)
      true ->
        next_number = hd(game.numbers)
        new_boards = Enum.map(game.boards, fn board-> Bingo.call_number(board, next_number) end)
        bingoed_boards_1 = get_winning_boards(new_boards)
        game = figure_out_last_winner(game, bingoed_boards_0, bingoed_boards_1, next_number)
        solve_2a(%{game | boards: new_boards, numbers: tl(game.numbers)})
    end
  end

  def solve_2b(%{boards: boards, last_winner: last_winner, last_number: last_number} = _game) do
    answer = calculate_answer(Enum.at(boards, last_winner-1), last_number)
    IO.puts("second problem board = #{last_winner}, number=#{last_number}, answer = #{answer}")
  end

  def figure_out_last_winner(game, bb0, bb1, _number) when length(bb0) == length(bb1), do: game

  def figure_out_last_winner(game, bb0, bb1, number) do
    IO.inspect({bb0, bb1, number}, label: "figure last winner")
    [last_game] = Enum.take(bb1 -- bb0, 1) #pick an undefined one if multiple boards bingoed with one called number
    %{game | last_winner: last_game, last_number: number}
  end

  def calculate_answer(board, number) do
    IO.inspect({board, number}, label: "calculate_answer")
    unmarked = Enum.filter(Map.keys(board.values), fn key -> elem(Map.get(board.values,key),0) == false end)
    Enum.sum(unmarked) * number
  end

  def get_winning_boards(boards) do
    Enum.filter(1..length(boards), fn index  -> Bingo.is_bingo?(Enum.at(boards, index-1)) end)
  end

  def read_input(), do: File.read!("input.txt")

  def adjust_input(text_lines) do
    String.trim(text_lines)
    |> String.split("\n")
    |> Enum.filter(fn l -> String.length(l) > 5 end)
    # |> IO.inspect(label: "lines in parse_input")
  end

  def parse_input(text_list) do
    [numbers] = Enum.slice(text_list, 0..0)
    numbers = Enum.map(String.split(numbers, ","), fn n -> String.to_integer(n) end)
    # make sure the number we call are unique!
    {true} = {numbers == Enum.uniq(numbers)}
    boards_lines = Enum.slice(text_list, 1..-1)
    %{numbers: numbers, boards: [], last_number: -1}
    |> parse_boards(boards_lines)
  end

  def parse_boards(%{} = game, boards_lines) when length(boards_lines) == 0, do: game

  def parse_boards(%{} = game, boards_lines) do
    next_board_lines = Enum.slice(boards_lines, 0..4)
    rest_of_boards_lines = Enum.slice(boards_lines, 5..-1)
    next_board = parse_board(next_board_lines)
    new_boards = game.boards ++ [next_board] #|> IO.inspect
    %{game| boards: new_boards}
    |> parse_boards(rest_of_boards_lines)
  end

  def parse_board([_h|_t] = board_lines) when length(board_lines) == 5 do
    Enum.map(board_lines, fn line -> String.split(line, " ", trim: true) end)
    |> Enum.map(fn list_of_numbers -> parse_board_line(list_of_numbers) end)
    |> Bingo.new()
  end

  def parse_board_line([_h|_t] = board_line) when length(board_line) == 5 do
    Enum.map(board_line, fn val -> String.to_integer(val) end)
  end

  def example() do
    input = """
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
8  2 23  4 24
21  9 14 16  7
6 10  3 18  5
1 12 20 15 19

3 15  0  2 22
9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
2  0 12  3  7
"""
    game = adjust_input(input)
    |> parse_input()
    # |> IO.inspect(label: "parsed input")
    solve(game)

    adjust_input(input)
    |> parse_input()
    |> solve_2()
  end

end
