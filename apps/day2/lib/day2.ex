defmodule Day2 do
  @moduledoc """
  Documentation for `Day2`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day2.hello()
      :world

  """
  def run() do
    read_data()
    |> solve()
  end

  def solve(inhalt) do
    ans1= solve_problem_1(inhalt)
    ans2 = solve_problem_2(inhalt)
    IO.puts("The answers are #{ans1} and #{ans2}")
  end

  def test() do
    read_data() |> Enum.take(5) |> IO.inspect(label: "test data")
    |> solve()
  end

  def read_data() do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn a -> String.split(a, " ") end)
    |> Enum.map(fn [a, b] -> {a, String.to_integer(b)} end)
  end

  def solve_problem_1(l)  when is_list(l) when length(l) > 0 do
    %{h: h, v: v} = solve_problem_1(l, %{h: 0, v: 0})
    h * v
  end

  def solve_problem_1([h | t] = _l, %{h: _h, v: _v} = position) do
    new_position = move_1(h, position)
    solve_problem_1(t, new_position)
  end

  def solve_problem_1([], %{h: _h, v: _v} = position), do: position

  def move_1({"up", n}, %{h: _h, v: v} = position), do: %{position | v: v - n}

  def move_1({"down", n}, %{h: _h, v: v} = position), do: %{position | v: v + n}

  def move_1({"forward", n}, %{h: h, v: _v} = position), do: %{position | h: h + n}

  # for problem 2

  def solve_problem_2(l)  when is_list(l) when length(l) > 0 do
    %{h: h, v: v} = solve_problem_2(l, %{h: 0, v: 0, a: 0})
    h * v
  end

  def solve_problem_2([h | t] = _l, %{h: _h, v: _v, a: _a} = position) do
    new_position = move_2(h, position)
    solve_problem_2(t, new_position)
  end

  def solve_problem_2([], %{h: _h, v: _v, a: _a} = position), do: position

  def move_2({"up", n}, %{h: _h, v: _v, a: a} = position), do: %{position | a: a - n}

  def move_2({"down", n}, %{h: _h, v: _v, a: a} = position), do: %{position | a: a + n}

  def move_2({"forward", n}, %{h: h, v: v, a: a} = position), do: %{position | h: h + n, v: v + a * n}

end
