defmodule Day9 do
  @moduledoc """
  Documentation for `Day9`.
  """

  def run() do
    File.read!("input.txt")
    |> process()
  end

  def example() do
    input = """
2199943210
3987894921
9856789892
8767896789
9899965678
"""
    process(input)
  end

  def process(input) do
    String.trim(input)
    |> String.split("\n", trim: true)    #list of lines
    |> make_model()
    |> analyze_model()
  end

  def analyze_model(model) do
    # model is a tuple of tuples
    %{model: model, low_points: %{}}
    |> analyze_corners()
    |> analyze_edges()
    |> analyze_interior()
  end

  def analyze_corners(puzzle) do
    puzzle
    |> analyze_a_corner(:top, :left)
    |> analyze_a_corner(:top, :right)
    |> analyze_a_corner(:bottom, :left)
    |> analyze_a_corner(:bottom, :right)
  end

  def analyze_a_corner(puzzle, vert, horiz) do
    puzzle
  end

  def analyze_edges(puzzle) do
    puzzle
    |> analyze_an_edge(:top)
    |> analyze_an_edge(:rigght)
    |> analyze_an_edge(:bottom)
    |> analyze_an_edge(:left)
  end

  def analyze_an_edge(puzzle, position) do
    puzzle
  end

  def analyze_interior(puzzle) do
    puzzle
  end

  def model_value(%{model: model} = _puzzle, row, col) do
    elem(model, row)
    |> elem(col)
  end

  def make_model(list_of_lines) do
    Enum.reduce(list_of_lines, {}, fn line, tupl -> Tuple.append(tupl, model_line(line)) end)
  end

  def model_line(line) do
    String.split(line, "", trim: true)
    |> Enum.map(fn d -> String.to_integer(d) end)
    |> Enum.reduce({}, fn val, tupl -> Tuple.append(tupl, val) end)
  end
end
