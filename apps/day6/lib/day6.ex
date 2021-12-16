defmodule Day6 do
  @moduledoc """
  Documentation for `Day6`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day6.hello()
      :world

  """
  def run() do
    get_input()
    |> process()
    |> present()
  end

  def present({a1, a2} = _answer) do
    IO.puts("There are now #{a1} langernfish")
    IO.puts("Later there are #{a2} lanternfish")
  end

  def get_input(), do: File.read!("input.txt")

  def process(text) do
    answer1 = split(text)
    |> make_into_model()
    |> age_model(80)

    answer2 = split(text)
    |> make_into_model()
    |> age_model(256)
    {answer1, answer2}
  end

  def split(text), do: String.split(text, ",", trim: true)

  def make_into_model(fish_list) do
    fish_list = Enum.map(fish_list, fn fish_age -> String.to_integer(fish_age) end)
    IO.inspect(fish_list, label: "fish list into model")
    Enum.reduce(0..6,
      Tuple.duplicate(0,9),
      fn age, tuple -> put_elem(tuple, age, length(Enum.filter(fish_list, fn fish_age -> fish_age == age end))) end)
    |> IO.inspect(label: "model from fish list")
  end

  def age_model(population, n) when n == 0, do: Enum.sum(Tuple.to_list(population))

  def age_model({p0,p1,p2,p3,p4,p5,p6,p7,p8} = population, n) do
    if n > 60 do
      IO.inspect({n, population})
    end
    next_days_population = {p1, p2, p3, p4, p5, p6, p0+p7, p8, p0}
    age_model(next_days_population, n - 1)
  end

  def generate_new_fish(population) do
    number_of_babies = length(Enum.filter(population, fn x -> x == 0 end))
    List.duplicate(6, number_of_babies)
  end

  def example() do
    process("3,4,3,1,2")
    |> present
  end
end
