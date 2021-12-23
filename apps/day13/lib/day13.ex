defmodule Day13 do
  @moduledoc """
  Documentation for `Day13`.
  """

  def run() do
    File.read!("input.txt")
    |> process(1)
    |> count_dots()
    |> present_dot_count()

    File.read!("input.txt")
    |> process(12)
    |> present_dots()
  end

  def present_dots(%{dots: dots}) do
    {xmin, xmax, ymin, ymax} = minmax(dots)
    IO.inspect({xmin, xmax, ymin, ymax}, label: "xmin ... ymax")
    Enum.reduce(ymin..ymax, "", fn y, acc -> acc <> present_dots_row(dots, y, xmin, xmax) end)
    |> IO.puts()
  end

  def present_dots_row(dots, y, xmin, xmax) do
    Enum.reduce(xmin..xmax, "", fn x, acc -> acc <> present_dot({x,y} in dots) end) <> "\n\r"
  end

  def present_dot(false), do: " "
  def present_dot(true), do: "*"

  def minmax(dots) do
    {xmin, xmax} = Enum.min_max(Enum.map(dots, fn {x, _y} -> x end))
    {ymin, ymax} = Enum.min_max(Enum.map(dots, fn {_x, y} -> y end))
    {xmin, xmax, ymin, ymax}
  end

  def process(txt, n) do
    txt
    |> String.trim()
    |> String.split("\n", trim: true)
    |> parse()
    |> execute_folds(n)
  end

  def execute_folds(%{} = state, 0), do: state

  def execute_folds(%{folds: [first|rest]} = state, n) do
    execute_fold(%{state | folds: rest}, first)
    |> execute_folds(n - 1)
  end

  def execute_fold(%{} = state, fold) do
    # fold is like "fold along x=655"
    [direction, coord] = String.split(fold, "=")
    coord = String.to_integer(coord)
    execute_fold(state, direction, coord)
  end

  def execute_fold(%{} = state, "fold along x", value) do
    general_fold(state, value, &fold_by_x/2)
  end

  def execute_fold(%{} = state, "fold along y", value) do
    general_fold(state, value, &fold_by_y/2)
  end

  def general_fold(%{dots: dots} = state, value, fold_function) do
    new_dots = Enum.map(dots, fn coord -> fold_function.(coord, value) end) |> Enum.uniq()
    %{state | dots: new_dots}
  end

  def fold_by_x({x,y}, value) when x < value, do: {x, y}
  def fold_by_x({x,y}, value) when x > value, do: {2 * value - x, y}

  def fold_by_y({x,y}, value) when y < value, do: {x, y}
  def fold_by_y({x,y}, value) when y > value, do: {x, 2 * value - y}

  def count_dots(%{dots: dots}), do: length(dots)

  def present_dot_count(x), do: IO.puts("There are #{x} dots")

  def parse(list_of_lines) do
    # return %{dots: dots, folds: folds}
    # where dots is a list of tuples {x,y}
    # where folds is a list of "fold along {x|y}=42" text lines
    coords =
      Enum.filter(list_of_lines, fn line -> String.contains?(line, ",") end)
      |> Enum.map(fn txt -> String.split(txt, ",") end)
      |> Enum.map(fn [txt_x, txt_y] -> {String.to_integer(txt_x), String.to_integer(txt_y)} end)
    folds =
      Enum.filter(list_of_lines, fn line -> String.contains?(line, "fold along") end)
    %{dots: coords, folds: folds}
  end
end
