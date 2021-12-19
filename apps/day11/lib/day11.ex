defmodule Day11 do
  @moduledoc """
  Documentation for `Day11`.
  """

  def run() do
    process("""
    7612648217
    7617237672
    2853871836
    7214367135
    1533365614
    6258172862
    5377675583
    5613268278
    8381134465
    3445428733
    """, 100)
  end

  def example(), do: (example1(); example2();)

  def example2() do
    process("""
    5483143223
    2745854711
    5264556173
    6141336146
    6357385478
    4167524645
    2176841721
    6882881134
    4846848554
    5283751526
    """, 100)
  end

  def example1() do
    process("""
11111
19991
19191
19991
11111
""", 1)
  end

  def process(text, n) do
    puzzle = make_puzzle(text)
    {_puzzle, count} = process_further(puzzle, 0, n, 1)
    IO.puts("Total number of flashes after 100 steps = #{count}")
    count = process_part2(make_puzzle(text), 1)
  end

  def process_further(puzzle, sum_of_flashes, 0, _step), do: {puzzle, sum_of_flashes}

  def process_further(puzzle, sum_of_flashes, n, step) do
    next_puzzle = next_generation(puzzle)
    flash_count = count_zeroes(next_puzzle)
    IO.puts("#{flash_count} simultaneous flashes at step #{step}-----------------------------------")
    process_further(next_puzzle, flash_count + sum_of_flashes, n - 1, step + 1)
  end

  def process_part2(puzzle, step) do
    next_puzzle = next_generation(puzzle)
    flash_count = count_zeroes(next_puzzle)
    IO.puts("#{flash_count} simultaneous flashes at step #{step}-----------------------------------")
    if flash_count < 100 do
      process_part2(next_puzzle, step + 1)
    else
      step
    end
  end

  def count_zeroes(%{core: core} =pz) do
    coords = get_coords(pz)
    length(Enum.filter(coords, fn coord -> 0 == get_core(core, coord) end))
  end

  def anneal(%{core: core} = pz) do
    # IO.inspect(core, label: "anneal")
    # find what octopi are to be lighted up
    enlightened = Enum.filter(get_coords(pz), fn coord -> get_core(core, coord) >= 10 end)
    maybe_anneal_again(pz, enlightened)
  end

  def maybe_anneal_again(%{core: _core} = pz, [] = _light_list), do: pz

  def maybe_anneal_again(%{core: core} = pz, coords) do
    # IO.inspect(core, label: "anneal again")
    # make them so they only get lighted up once this round
    new_core = Enum.reduce(coords, core, fn coord, kore -> set_core(kore, coord, -9999) end)
    # boost neighbors' strength: first find them all (duplicates expected)
    # then energize them. (Energize means add energy)
    all_neighbors = Enum.map(coords, fn coord -> get_neighbor_coords(pz, coord) end)
                    |> List.flatten()
    energize(%{pz| core: new_core}, all_neighbors)
    |> anneal()
  end

  def raise_floor(%{core: core} = pz) do
    new_core  = Enum.filter(get_coords(pz), fn coord -> get_core(core, coord) < 0 end)
                |> Enum.reduce(core, fn coord, kore -> set_core(kore, coord, 0) end)
    %{pz | core: new_core}
  end

  def energize(%{core: _core} = puzzle), do: energize(puzzle, get_coords(puzzle))

  def energize(%{core: core} = puzzle, coords) do
    new_core = Enum.reduce(coords, core, fn coord, kore -> set_core(kore, coord, 1 + get_core(kore, coord)) end)
    %{puzzle| core: new_core}
  end

  def next_generation(puzzle) do
    puzzle
    |> energize()       # add one to each octopus's energy
    |> anneal()         # flash until flashes die out
    |> raise_floor()    # correct any octopus with negative energy
                        # negative energy is a flag so no octopus flashes
                        # twice in the same step
  end

  def get_core(core, {r, c}) do
    elem(core, r)
    |> elem(c)
  end

  def set_core(core, {r, c}, v) do
    row = elem(core, r)
    new_row = put_elem(row, c, v)
    put_elem(core, r, new_row)
  end

  def get_coords(%{core: _core, row_size: r, col_size: c}), do: for r <- 0..r-1, c <- 0..c-1, do: {r,c}

  def get_neighbor_coords(%{core: _core, row_size: r, col_size: c}, {r0, c0}) do
    (for r <- max(0,r0-1)..min(r0+1, r-1), c <- max(0,c0-1)..min(c0+1, c-1), do: {r,c}) -- [{r0, c0}]
  end

  def make_puzzle(text) do
    make_row = fn l -> String.split(l, "", trim: true) |> Enum.map(fn e -> String.to_integer(e) end) |> List.to_tuple() end
    core_puzzle = String.split(text, "\n", trim: true)
                  |> Enum.map(fn l -> make_row.(l) end)
                  |> List.to_tuple()
    row_size = tuple_size(core_puzzle)
    col_size = tuple_size(elem(core_puzzle, 0))
    %{core: core_puzzle, row_size: row_size, col_size: col_size}
  end

  def p2s(%{core: core} = _pz) do
    Enum.map(Tuple.to_list(core), fn r -> Tuple.to_list(r) end )
    |> Enum.map(fn row -> Enum.reduce(row, "", fn elt, acc -> acc <> "#{elt}" end) end)
    |> Enum.reduce("", fn sr, acc -> acc <> sr <> "\n\r" end)
    |> String.replace("0", " ", all: true)
  end
end
