defmodule Day9 do
  @moduledoc """
  Documentation for `Day9`.
  """

  def run() do
    File.read!("input.txt")
    |> process()
  end

  def example() do
    process("""
2199943210
3987894921
9856789892
8767896789
9899965678
""")

    process("""
2199943210
3987892921
9856789892
8767896789
9899965678
""")
  end

  def process(input) do
    solution = String.trim(input)
              |> String.split("\n", trim: true)    #list of lines
              |> Enum.map(fn l -> String.trim(l) end)
              |> make_model()
              |> analyze_model()
    present(sum_risk_levels(solution))

    solution
    |> part_2()
  end

  def part_2(puzzle) do
    # a basin is a list of points
    Map.put(puzzle, :basins, [])
    |> analyze_basins()
    |> present_2()
  end

  def analyze_basins(%{model: _topo, low_points: [], basins: _basins} = puzzle), do: puzzle.basins

  def analyze_basins(%{model: topo, low_points: [low_point|rest_of_low_points], basins: basins} = puzzle) do
    next_basin = create_basin(topo, low_point)
    %{puzzle| low_points: rest_of_low_points, basins: [next_basin | basins] }
    |> analyze_basins()
  end

  def show_lines(list_of_lines) do
    _ = Enum.map(list_of_lines, fn l -> IO.puts(l) end)
  end

  def present(total_value) when is_integer(total_value) do
    IO.puts("The total of the risk levels is #{total_value}")
    total_value
  end

  def present_2(basins) when is_list(basins) do
    # basins is a list of maps: {center: {r,c}, points: [list of points]}
    answer =
          Enum.sort(basins, fn b1, b2 -> length(b1.points) >= length(b2.points) end)
          |> Enum.take(3)
          # |> IO.inspect(label: "3 basins")
          |> Enum.map(fn basin -> length(basin.points) end)
          |> IO.inspect(label: "Basin sizes")
          |> Enum.product()
    IO.puts("The product of the area of the three largest basins is #{answer}")
  end

  def create_basin(topo, {r,c} = _low_point) do
    %{drain: {r,c}, points: []}
    |> add_points_to_basin( [{r,c}], topo)
  end

  def add_points_to_basin(basin, [], _topo), do: %{basin| points: Enum.uniq(basin.points)}

  def add_points_to_basin(basin, [point | rest_of_points], topo) do
    new_points = generate_neighbors(point, topo) #|> IO.inspect(label: "neighbors")
    |> Enum.filter(fn neighbor -> ((topo_value(topo,point) < topo_value(topo, neighbor)) and
                                   (topo_value(topo, neighbor) != 9) ) end)
    new_basin = %{basin| points: [point|basin.points]}
    add_points_to_basin(new_basin, new_points ++ rest_of_points, topo)
  end

  def generate_neighbors({r,c} = _point, topo) do
    {max_r, max_c} = max_coordinate(topo)
    cond do
      r - 1 >= 0 -> [{r-1,c}]
      true -> []
    end
    ++
    cond do
      c - 1 >= 0 -> [{r, c-1}]
      true -> []
    end
    ++
    cond do
      r + 1 <= max_r -> [{r+1, c}]
      true -> []
    end
    ++
    cond do
      c + 1 <= max_c -> [{r, c+1}]
      true -> []
    end
  end

  def analyze_model(model) do
    # model is a tuple of tuples
    %{model: model, low_points: []}
    |> analyze_corners()
    |> analyze_edges()
    |> analyze_interior()
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

  def analyze_interior_rows(puzzle, first, last) when first > last, do: puzzle

  def analyze_interior_rows(puzzle, first, last) when first <= last do
    analyze_interior_row_points(puzzle, first, 1, model_width(puzzle) - 2)
    |>analyze_interior_rows(first + 1, last)
  end

  def analyze_interior_row_points(puzzle, _row, first, last) when first > last, do: puzzle

  def analyze_interior_row_points(puzzle, row, first, last) when first <= last do
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
    topo_value(model, {row, col})
  end

  def max_coordinate(topo) do
    {tuple_size(topo) - 1, tuple_size(elem(topo,0)) - 1}
  end

  def topo_value(topo, {row, col} = _location) when is_tuple(topo) do
    elem(topo, row)
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
