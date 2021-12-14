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
    |> present()
  end

  def present(total_value) when is_integer(total_value) do
    IO.puts("The total of the risk levels is #{total_value}")
  end

  def analyze_model(model) do
    # model is a tuple of tuples
    %{model: model, low_points: []}
    |> analyze_corners()
    |> analyze_edges()
    |> analyze_interior()
    |> sum_risk_levels()
  end

  def sum_risk_levels(%{low_points: low_points} = puzzle) do
    Enum.reduce(low_points, 0, fn {r, c} = _coordinate, acc -> (acc + 1 + model_value(puzzle, r, c)) end)
  end

  def analyze_corners(puzzle) do
    puzzle
    |> analyze_a_corner(:top, :left)
    |> analyze_a_corner(:top, :right)
    |> analyze_a_corner(:bottom, :left)
    |> analyze_a_corner(:bottom, :right)
  end

  def analyze_a_corner(puzzle, vert, horiz) do
    {r, c, dr, dc} = case {vert, horiz} do
      {:top, :left}     -> {0, 0, 1, 1}
      {:top, :right}    -> {0, model_width(puzzle)-1, 1, -1}
      {:bottom, :left}  -> {model_height(puzzle)-1, 0, -1, 1}
      {:bottom, :right} -> {model_height(puzzle)-1, model_width(puzzle)-1, -1, -1}
    end
    p0 = model_value(puzzle, r,      c     )
    c1 = model_value(puzzle, r + dr, c     )
    c2 = model_value(puzzle, r,      c + dc)
    if p0 < c1 and p0 < c2 do
      add_low_point(puzzle, {r,c})
    else
      puzzle
    end
  end

  def analyze_edges(puzzle) do
    puzzle
    |> analyze_an_edge(:top)
    |> analyze_an_edge(:right)
    |> analyze_an_edge(:bottom)
    |> analyze_an_edge(:left)
  end

  def analyze_an_edge(puzzle, position) do
    {r, c, dr, dc, idr, idc, count} = case position do
      :top    -> {0, 1, 0, 1, 1, 0, model_width(puzzle)-2}
      :right  -> {1, model_width(puzzle)-1, 1, 0, 0, -1, model_height(puzzle)-2}
      :bottom -> {model_height(puzzle)-1, 1, 0, 1, -1, 0, model_width(puzzle)-2}
      :left   -> {1, 0, 1, 0, 0, 1, model_height(puzzle)-2}
    end
    check_edge_points(puzzle, r, c, dr, dc, idr, idc, count)
  end

  def check_edge_points(puzzle, _r, _c, _dr, _dc, _idr, _idc, 0), do: puzzle

  def check_edge_points(puzzle, r, c, dr, dc, idr, idc, count) do
    p0 = model_value(puzzle, r, c)
    n0 = model_value(puzzle, r+dr, c+dc)
    n1 = model_value(puzzle, r-dr, c-dc)
    n2 = model_value(puzzle, r+idr, c+idc)
    if p0 < n0 and p0 < n1 and p0 < n2 do
      add_low_point(puzzle, {r,c})
    else
      puzzle
    end
    |> check_edge_points(r+dr, c+dc, dr, dc, idr, idc, count-1)
  end

  def analyze_interior(puzzle) do
    analyze_interior_rows(puzzle, 1, model_height(puzzle)-2)
  end

  def analyze_interior_rows(puzzle, first, last) when first == last, do: puzzle

  def analyze_interior_rows(puzzle, first, last) when first < last do
    analyze_interior_row_points(puzzle, first, 1, model_width(puzzle) - 2)
    |>analyze_interior_rows(first + 1, last)
  end

  def analyze_interior_row_points(puzzle, _row, first, last) when first == last, do: puzzle

  def analyze_interior_row_points(puzzle, row, first, last) when first < last do
    # do this point at {row, first}
    p0 = model_value(puzzle, row, first)
    n0 = model_value(puzzle, row - 1, first    )
    n1 = model_value(puzzle, row + 1, first    )
    n2 = model_value(puzzle, row    , first - 1)
    n3 = model_value(puzzle, row    , first + 1)
    if p0 < n0 and p0 < n1 and p0 < n2 and p0 < n3 do
      add_low_point(puzzle, {row, first})
    else
      puzzle
    end
    |> analyze_interior_row_points(row, first + 1, last) # do the rest of the points
  end

  def add_low_point(%{model: _model, low_points: low_points} = puzzle, {r,c}) do
    %{puzzle| low_points: (low_points ++ [{r,c}]) }
  end

  def model_value(%{model: model} = _puzzle, row, col) do
    elem(model, row)
    |> elem(col)
  end

  def model_height(%{model: model} = _puzzle) do
    tuple_size(model)
  end

  def model_width(%{model: model} = _puzzle) do
    elem(model, 0)
    |> tuple_size()
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
