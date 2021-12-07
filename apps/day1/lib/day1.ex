defmodule Day1 do
  @moduledoc """
  Documentation for `Day1`.
  """

  @doc """
  run

  ## Examples

      iex> Day1.run()
      100

  """
  def run() do
    inhalt = read_data()
    ans = solve_problem_1(inhalt)
    IO.puts("The answer is #{ans}")
    ans = solve_problem_2(inhalt)
    IO.puts("The second answer is #{ans}")
  end

  def read_data() do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn a -> String.to_integer(a) end)
  end

  def solve_problem_1([first | rest]) do
    {_, answer} = Enum.reduce(rest, {first, 0}, fn current, {previous, count} -> {current, increment_if_less(count, previous, current)} end)
    answer
  end

  def solve_problem_1([]), do: 0

  def solve_problem_2(l) when length(l) < 4 do
    0
  end

  def solve_problem_2(l) when is_list(l) do
    sz = length(l)
    smooth_vector_0 = Enum.slice(l, 2..sz)
    smooth_vector_1 = Enum.slice(l, 1..sz-1)
    smooth_vector_2 = Enum.slice(l, 0..sz-2)
    Stream.zip([smooth_vector_0, smooth_vector_1, smooth_vector_2])
    |> Enum.map(fn {e0, e1, e2} -> e0 + e1 + e2 end)
    |> solve_problem_1()
  end

  def increment_if_less(count, previous, current) do
    cond do
      previous < current -> count + 1
      true -> count
    end
  end
end
