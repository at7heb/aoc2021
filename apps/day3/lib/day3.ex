defmodule Day3 do
  @moduledoc """
  Documentation for `Day3`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day3.test()
      The answers are 253 and 1485

  """
  def run() do
    read_data()
    |> solve()
  end

  def test(n \\ 5) do
    {number_of_bits, _number_of_diagnostics, reports} = read_data()
    {number_of_bits, n, Enum.take(reports, n)}
    |> IO.inspect(label: "test data")
    |> solve()
  end

  def example() do
    number_of_bits = 5
    number_of_reports = 12
    reports = [0b00100, 0b11110, 0b10110, 0b10111, 0b10101, 0b01111, 0b00111, 0b11100, 0b10000, 0b11001, 0b00010, 0b01010]
    {number_of_bits, number_of_reports, reports}
    |> solve()
  end

  def read_data() do
    lines = File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    number_of_bits = String.length(hd(lines))
    reports = Enum.map(lines, fn a -> String.to_integer(a,2) end)
    {number_of_bits, length(reports), reports}
  end

  def solve(inhalt) do
    ans1 = solve_problem_1(inhalt)
    ans2 = solve_problem_2(inhalt)
    IO.puts("The answers are #{ans1} and #{ans2}")
  end

  def solve_problem_1({w,h,d} = _inhalt), do: solve_problem_1(w, h, d, 0, "", "")

  def solve_problem_1(width, _height, _list, stage, partial_gamma, partial_epsilon) when width == stage do
    # IO.inspect({partial_gamma, partial_epsilon, stage}, label: "problem 1")
    String.to_integer(partial_gamma, 2) * String.to_integer(partial_epsilon, 2)
  end

  def solve_problem_1(width, height, list, stage, partial_gamma, partial_epsilon) when width > stage do
    # IO.inspect({partial_gamma, partial_epsilon, stage}, label: "problem 1")
    count_1s = Enum.reduce(list, 0, fn diagnostic, count -> count + rem(diagnostic, 2) end)
    count_0s = height - count_1s
    # IO.inspect({height, count_1s, count_0s}, label: "counts")
    new_list = Enum.map(list, fn diagnostic -> div(diagnostic, 2) end)
    if count_1s == count_0s do IO.inspect({count_1s, count_0s, stage}, label: "counts are the same") end
    new_digit_g = if count_1s > count_0s do "1" else "0" end
    new_digit_e = if count_1s > count_0s do "0" else "1" end
    solve_problem_1(width, height, new_list, stage + 1, new_digit_g <> partial_gamma, new_digit_e <> partial_epsilon)
  end

  def solve_problem_2({w,_h,d} = _inhalt), do: generator_rating(d, pow(2, w-1)) * scrubber_rating(d, pow(2, w-1))

  def pow(b,e) do
    div(Enum.reduce(0..e, 1, fn _v, a -> a*b end), b)
  end

  def generator_rating(d, m), do: search(:more, d, m)

  def scrubber_rating(d, m), do: search(:less, d, m)

  def search(_criterion, d, _m) when length(d) == 1, do: hd(d)

  def search(criterion, d, m) do
    list_of_1s = Enum.filter(d, fn datum -> rem(div(datum, m), 2) == 1 end)
    list_of_0s = Enum.filter(d, fn datum -> rem(div(datum, m), 2) == 0 end)
    new_list = select(criterion, list_of_1s, list_of_0s)
    search(criterion, new_list, div(m,2))
  end

  def select(:more, l1s, l0s) do
    if length(l1s) >= length(l0s) do
      l1s
    else
      l0s
    end
  end

  def select(:less, l1s, l0s) do
    # IO.inspect({l0s, l1s}, label: "select :less")
    if length(l0s) <= length(l1s) do
      l0s
    else
      l1s
    end
  end
end
