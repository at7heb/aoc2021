defmodule Day5 do
  @moduledoc """
  Documentation for `Day5`.
  """

  @doc """
  run.

  """
  def run() do
    get_input()
    |> process()
  end

  def get_input(), do: File.read!("input.txt")

  def process(text) do
    quads = convert_to_quads(text)
    no_diagonals(quads)
    |> make_canonical()
    |> fill_in_map()
    |> count_danger_points()

    fill_in_map(quads)
    |> count_danger_points()
  end

  def convert_to_quads(text) do
    String.trim(text)
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> String.split(x, ~r{[- ,>]}, trim: true) end)
    |> Enum.map(fn [x0,y0,x1,y1] = _x -> {gi(x0), gi(y0), gi(x1), gi(y1)} end)
  end

  defp gi(x), do: String.to_integer(x)

  def no_diagonals(quads) do
    Enum.filter(quads, fn line_segment -> is_horizontal(line_segment) or is_vertical(line_segment) end)
  end

  def is_horizontal({_, y0, _, y1}), do: y0 == y1

  def is_vertical({x0, _, x1, _}), do: x0 == x1

  def make_canonical(quads) when is_list(quads) do
    Enum.map(quads, fn quad -> make_canonical(quad) end)
  end

  def make_canonical({x0, y0, x1, y1}) when x0 > x1, do: {x1, y1, x0, y0}

  def make_canonical({x0, y0, x1, y1}) when y0 > y1, do: {x1, y1, x0, y0}

  def make_canonical(quad), do: quad

  def fill_in_map(quads) do
    Enum.reduce(quads, %{}, fn quad, count_map -> add_counts_for_line(quad, count_map) end)
  end

  def add_counts_for_line({x0, y0, x1, y1}, count_map) do
    # actually 1 less than line length, but I don't add 1 here and then
    # subtract one in the 0..line_length range
    line_length = max(abs(x0 - x1), abs(y0 - y1))
    x_increment = increment(x0, x1)
    y_increment = increment(y0, y1)
    Enum.reduce(0..line_length, count_map,
          fn incr, map -> Map.put(map, {x0 + incr * x_increment, y0 + incr * y_increment},
          1 + Map.get(map, {x0 + incr * x_increment, y0 + incr * y_increment}, 0)) end)
  end

  def increment(a, b) do
    cond do
      a  < b -> 1
      a == b -> 0
      a  > b -> -1
    end
  end

  # def add_counts_for_line({x0, y0, x1, y1}, count_map) when y0 == y1 do
  #   Enum.reduce(x0..x1, count_map, fn x, map -> Map.put(map, {x, y0}, 1 + Map.get(map, {x, y0}, 0)) end)
  # end

  def count_danger_points(map) do
    # IO.inspect(map, label: "count danger points")
    Enum.filter(Map.keys(map), fn k -> Map.get(map, k) > 1 end)
    |> length()
    |> IO.inspect(label: "Count of danger points")
    :ok
  end

  def example() do
    input_text = """
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
"""
    process(input_text)
  end
end
