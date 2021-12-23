defmodule Day13 do
  @moduledoc """
  Documentation for `Day13`.
  """

  def run() do
    File.read!("input.txt")
    |> String.trim()
    |> process()
  end

  def process(txt) do
    txt
    |> String.split("\n", trim: true)
    |> parse()
    |> execute_folds(1)
    |> count_dots()
    |> present_dot_count()
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
