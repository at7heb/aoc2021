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
    answer = get_input()
    |> process()
    IO.puts("There are now #{answer} langernfish")
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

  def make_into_model(fish_list), do: Enum.map(fish_list, fn age -> String.to_integer(age) end)

  def age_model(population, n), do: age_model(population, [], [], n)

  def age_model(population, wait0, wait1, n) when n == 0, do: length(population) + length(wait0) + length(wait1)

  def age_model(population, wait0, wait1, n) do
    if n > 60 do
      IO.inspect({n, population})
    end
    new_fish = generate_new_fish(population)
    next_days_population = Enum.map(population, fn x -> rem(x+6, 7) end)
    age_model(next_days_population ++ wait0, wait1, new_fish, n - 1)
  end

  def generate_new_fish(population) do
    number_of_babies = length(Enum.filter(population, fn x -> x == 0 end))
    List.duplicate(6, number_of_babies)
  end

  def example() do
    answer = process("3,4,3,1,2")
    IO.puts("There are now #{answer} langernfish")
  end
end
