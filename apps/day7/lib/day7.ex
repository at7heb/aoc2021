defmodule Day7 do
  @moduledoc """
  Documentation for `Day7`.
  """

  @doc """
  Hello world.
  """
  def run() do
    get_input()
    |> process(:first)
    |> present()

    get_input()
    |> process(:second)
    |> present()
  end

  def present({n, nx, x, xx} = _answer) do
    IO.puts("minimum cost = #{n}, position #{nx}")
    IO.puts("Incidently, maximum cost = #{x}, position #{xx}")
  end

  def get_input() do
    File.read!("input.txt")
    |> transform_input()
  end

  def transform_input(s) do
    s
    |> String.trim()
    |> String.split(",")
    |> Enum.map(fn e -> String.to_integer(e) end)
    |> Enum.sort()
  end

  def get_input(s) do
    s
    |> transform_input()
  end

  def process(list_of_coordinates, variant) do
    p_vector = make_position_vector(list_of_coordinates)
    c_vector = make_cost_vector(length(p_vector), variant)
    costs = calculate_costs(p_vector, c_vector)
    {min, max} = Enum.min_max(costs)
    min_position = Enum.find_index(costs, fn v -> v == min end)
    max_position = Enum.find_index(costs, fn v -> v == max end)
    {min, min_position, max, max_position}
  end

  def make_position_vector(l) do
    {0, max} = Enum.min_max(l)
    vector_length = 1 + max
    proto_vector = Enum.map(1..vector_length, fn _v -> 0 end)
    Enum.reduce(l, proto_vector, fn e, v -> List.replace_at(v, e, 1 + Enum.at(v, e, :i)) end)
  end

  def make_cost_vector(size, :first) do
    Enum.map(1..(2 * size - 1), fn v -> abs(size - v) end)
  end

  def make_cost_vector(size, :second) do
    ff = fn n -> div(n*(n+1),2) end
    Enum.map(1..(2 * size - 1), fn v -> ff.(abs(size - v)) end)
  end

  def calculate_costs(pv, ccv) do
    n = length(pv)
    Enum.map(0..(n-1), fn dest -> dot_product(pv, sliced(dest, n, ccv))end)
  end

  def sliced(offset, len, source) do
    Enum.slice(source, len - 1 - offset, len)
  end

  def dot_product(a, b) do
    Enum.zip(a,b)
    |> Enum.reduce(0, fn {a0, b0}, dp -> dp + a0 * b0 end)
  end

  def example() do
    get_input("16,1,2,0,4,2,7,1,2,14")
    |> process(:first)
    |> present()

    get_input("16,1,2,0,4,2,7,1,2,14")
    |> process(:second)
    |> present()
  end

  def info() do
    info = get_input()
    IO.puts("Length = #{length(info)}")
    {min, max} = Enum.min_max(info)
    IO.puts("Min and max: #{min} #{max}")
    IO.puts("Length of uniqued info: #{length(Enum.uniq(info))}")
  end
end
