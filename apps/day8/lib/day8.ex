defmodule Day8 do
  @moduledoc """
  Documentation for `Day8`.
  """

  def run() do
    get_input()
    |> process(:first)
    |> present()

    get_input()
    |> process(:second)
    |> present()
  end

  def present({c2, c3, c4, c7} = _answer) do
    IO.puts("#{c2} occurrences of 1")
    IO.puts("#{c3} occurrences of 7")
    IO.puts("#{c4} occurrences of 4")
    IO.puts("#{c7} occurrences of 8")
    IO.puts("#{c2 + c3 + c4 + c7} occurences of 1, 4, 7, and 8")
    IO.puts("")
  end

  def present(v) when is_integer(v) do
    IO.puts("The sum of the readings is #{v}")
  end

  def get_input() do
    File.read!("input.txt")
    |> transform_input()
  end

  def get_input(s) do
    s
    |> transform_input()
  end

  def transform_input(s) do
    # handle lines like
    #febacg aecb bgfedca bfagde cdgfb fgbce ebg be efcga dcegaf | dgeafb ceba cfeabg cbae
    #aegbd gdafbc dae gadcb fadgcbe fagedc adbgce ea ceba fgbed | gdfeac cbae ceab dcbfeag

    # note ceba and cbae are the same 4 segments, so put segments into canonical order.
    s
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, "|") end)
    |> Enum.map(fn [c10, c4] = _line -> [String.split(c10, " ", trim: true), String.split(c4, " ", trim: true)] end)
    |> Enum.map(fn [a,b] = _line -> [Enum.map(a, fn p -> make_canonical(p) end), Enum.map(b, fn p -> make_canonical(p) end)] end )
    |> Enum.sort()
  end

  def make_canonical(segment_codes), do: List.to_string(Enum.sort(String.to_charlist(segment_codes)))

  def process(data, :first) do
    frequencies =
    Enum.map(data, fn [_a, b] = _n -> b end)
    |> List.flatten()
    |> Enum.map(fn x -> String.length(x) end)
    |> Enum.frequencies() |> IO.inspect(label: "frequencies")
    {frequencies[2], frequencies[3], frequencies[4], frequencies[7]}
  end

  def process(data, :second) do
    make_deductions(data)
    |> apply_deductions(data)
    # |> IO.inspect(label: "deductions applied")
    |> Enum.map(fn [th, h, te, o] = _l -> (1000*th + 100*h + 10*te + o) end)
    |> IO.inspect(label: "the 4 digit values")
    |> Enum.sum()
    |> IO.inspect(label: "the sum")
  end

  def make_deductions(data) do
    data
    |> Enum.map(fn [a, _b] = _ -> a end)  # we don't need the values, just the 10 patterns
    |> Enum.map(fn a -> make_deduction(a) end)
  end

  def make_deduction(ten_patterns) do
    Enum.map(["a","b","c","d","e","f","g"], fn let -> make_signature(let, ten_patterns) end)
    |> Enum.reduce(%{}, fn signature, map -> add_mapping(signature, map) end)
  end

  def make_signature(let, ten_patterns) do
    Enum.reduce(2..7, {let}, fn len, tupl -> Tuple.append(tupl, length(find_letter_in_pattern_by_size(let, ten_patterns, len))) end)
  end

  def find_letter_in_pattern_by_size(letter, patterns, size) do
    Enum.filter(patterns, fn pat -> (size == String.length(pat) and String.contains?(pat, letter)) end)
  end

  def add_mapping({original_letter,_,_,_,_,_,_} = signature, map) do
    translated_letter =
      case signature do
        {_,0,1,0,3,3,1} -> "a"
        {_,0,0,1,1,3,1} -> "b"
        {_,1,1,1,2,2,1} -> "c"
        {_,0,0,1,3,2,1} -> "d"
        {_,0,0,0,1,2,1} -> "e"
        {_,1,1,1,2,3,1} -> "f"
        {_,0,0,0,3,3,1} -> "g"
      end
    Map.put(map, original_letter, translated_letter)
  end

  def apply_deductions(map, data) do
    Enum.zip(map, Enum.map(data, fn [_, digit_codes] = _datum -> digit_codes end))
    |> Enum.map(fn {map, digit_codes} -> translate_using_map(digit_codes, map) end)
    |> Enum.map(fn digit_codes -> translate_codes_to_digits(digit_codes) end)
  end

  def translate_using_map(digit_codes, map) do
    # IO.inspect({digit_codes, map}, label: "translate_using_map")
    # translate_one_code_letter = fn code_letter -> (IO.inspect(List.to_string([code_letter]), label: "translate_using_map"); Map.get(map, List.to_string([code_letter]), "z")) end
    translate_one_code_letter = fn code_letter -> Map.get(map, List.to_string([code_letter]), "z") end
    translate_code_letters = fn letters -> List.to_string(Enum.map(String.to_charlist(letters), fn c -> List.to_string([translate_one_code_letter.(c)]) end)) end
    Enum.map(digit_codes, fn one_code -> translate_code_letters.(one_code) end)
  end

  def translate_codes_to_digits(digit_codes) do
    # IO.inspect(digit_codes, label: "translate_codes_to_digits")
    Enum.map(digit_codes, fn digit_code -> translate_code_to_digit(digit_code) end)
    # |> IO.inspect(label: "rv from trans_codes_to_digits")
  end

  def translate_code_to_digit(single_code) do
    # IO.inspect(single_code, label: "translate_code_to_digit")
    case make_canonical(single_code) do
      "abcefg"  -> 0
      "cf"      -> 1
      "acdeg"   -> 2
      "acdfg"   -> 3
      "bcdf"    -> 4
      "abdfg"   -> 5
      "abdefg"  -> 6
      "acf"     -> 7
      "abcdefg" -> 8
      "abcdfg"  -> 9
    end
  end

  def example() do
    inhalt = """
    be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb |fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec |fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef |cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega |efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga |gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf |gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf |cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd |ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg |gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc |fgae cfgab fg bagce
"""
    get_input(inhalt)
    |> process(:first)
    |> present()

    get_input(inhalt)
    |> process(:second)
    |> present()

  end
end
