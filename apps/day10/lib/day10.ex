defmodule Day10 do
  @moduledoc """
  Documentation for `Day10`.
  """

  def run() do
    processed = File.read!("input.txt")
    |> process()
    processed
    |> calculate_scores()
    |> present()

    processed
    |> calculate_part2_scores()
    |> present_2()
  end

  def example() do
    processed = process("""
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
""")
    processed
    |> calculate_scores()
    |> present()

    processed
    |> calculate_part2_scores()
    |> present_2()
  end

  def process(s) do
    s
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> analyze_line(line) end)
  end

  def analyze_line(line) do
    String.codepoints(line)
    |> analyze_line([], line)
  end

  def analyze_line([], [], line), do: {:ok, line} |> IO.inspect()

  def analyze_line([], state, line), do: {:incomplete, state, line} |> IO.inspect

  def analyze_line([first| rest] = _code_points, state, line) when is_list(state) do
    cond do
      String.contains?("([{<", first) -> analyze_line(rest, [first | state], line)
      String.contains?(")]}>", first) -> analyze_or_error_stop(first, rest, state, line)
      true                           -> {:illegal, "unexpected character #{first}"} |> IO.inspect()
    end
  end

  def analyze_or_error_stop(_first, {} = _, state, line), do: {:incomplete, state, line}

  def analyze_or_error_stop(first, rest, [state_first|state_rest] = _state, line) do
    case first <> state_first do
      ")(" -> analyze_line(rest, state_rest, line)
      "><" -> analyze_line(rest, state_rest, line)
      "][" -> analyze_line(rest, state_rest, line)
      "}{" -> analyze_line(rest, state_rest, line)
      _    -> {:error, first, line} |> IO.inspect()
    end

  end

  def calculate_scores(line_results) do
    #line results are {:ok, "(())"}
    # or {:error, ">", "(()>"}
    # and maybe {:incomplete, ["("], "(()"}
    line_results
    |> Enum.filter(fn tuple -> elem(tuple, 0) == :error end) |> IO.inspect()
    |> Enum.map(fn tuple -> point_value(elem(tuple, 1)) end) |> IO.inspect()
    |> Enum.sum()
  end

  def calculate_part2_scores(line_results) do
    #line results are {:ok, "(())"}
    # or {:error, ">", "(()>"}
    # and maybe {:incomplete, "(()"}
    line_results
    |> Enum.filter(fn tuple -> elem(tuple, 0) == :incomplete end) |> IO.inspect(label: "tuples")
    |> Enum.map(fn tuple -> completion_score(elem(tuple, 1), 0) end) |> IO.inspect(label: "scores")
    |> Enum.sort()
  end

  def completion_score([], value), do: value

  def completion_score([first|rest], value) do
    completion_score(rest, value * 5 + point_value_2(first))
  end

  def point_value(str) do
    case str do
      ")" ->     3
      "]" ->    57
      "}" ->  1197
      ">" -> 25137
      _   -> -9_999_999_999
    end
  end

  def point_value_2(str) do
    case str do
      "(" ->     1
      "[" ->     2
      "{" ->     3
      "<" ->     4
      _   -> -9_999_999_999
    end
  end

  def present(value) do
    IO.puts("The syntax error score is #{value}")
    value
  end

  def present_2(values) do
    count = length(values)
    selected = div(count,2) # select middle of an odd # in zero-based
    [value] = Enum.slice(values, selected, 1)
    IO.puts("The completion score = #{value}")
  end
end
