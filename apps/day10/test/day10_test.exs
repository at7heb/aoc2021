defmodule Day10Test do
  use ExUnit.Case
  doctest Day10

  test "null string" do
    assert Day10.process("") == []
  end

  test "balanced strings" do
    assert hd(Day10.process("()")) == {:ok, "()"}
    assert hd(Day10.process("[]")) == {:ok, "[]"}
    assert hd(Day10.process("{}")) == {:ok, "{}"}
    assert hd(Day10.process("<>")) == {:ok, "<>"}
  end

  test "incomplete" do
    assert hd(Day10.process("(")) == {:incomplete, "("}
    assert hd(Day10.process("[")) == {:incomplete, "["}
    assert hd(Day10.process("{")) == {:incomplete, "{"}
    assert hd(Day10.process("<")) == {:incomplete, "<"}
  end

  test "error" do
    assert {:error, ")", "{)"} == hd(Day10.process("{)"))
  end
end
