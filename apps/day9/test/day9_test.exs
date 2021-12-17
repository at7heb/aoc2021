defmodule Day9Test do
  use ExUnit.Case
  doctest Day9

  test "UL corner" do
    assert Day9.process("""
      19999
      99999
      99999
      99999
      99999
    """) == 2
  end

  test "UR corner" do
    assert Day9.process("""
      99991
      99999
      99999
      99999
      99999
    """) == 2
  end

  test "LL corner" do
    assert Day9.process("""
      99999
      99999
      99999
      99999
      19999
    """) == 2
  end

  test "LR corner" do
    assert Day9.process("""
      99999
      99999
      99999
      99999
      99991
    """) == 2
  end

  test "ULH edge" do
    assert Day9.process("""
      91999
      99999
      99999
      99999
      99999
    """) == 2
  end

  test "URH corner" do
    assert Day9.process("""
      99919
      99999
      99999
      99999
      99999
    """) == 2
  end

  test "LUV edge" do
    assert Day9.process("""
      99999
      19999
      99999
      99999
      99999
    """) == 2
  end

  test "RUV edge" do
    assert Day9.process("""
      99999
      99991
      99999
      99999
      99999
    """) == 2
  end

  test "LLV edge" do
    assert Day9.process("""
      99999
      99999
      99999
      19999
      99999
    """) == 2
  end

  test "RLV edge" do
    assert Day9.process("""
      99999
      99999
      99999
      99991
      99999
    """) == 2
  end

  test "LLH edge" do
    assert Day9.process("""
      99999
      99999
      99999
      99999
      91999
    """) == 2
  end

  test "LRH edge" do
    assert Day9.process("""
      99999
      99999
      99999
      99999
      99919
    """) == 2
  end

  test "no low spots" do
    assert Day9.process("""
      99999
      99999
      99999
      99999
      99999
    """) == 0
  end

  test "UL line" do
    assert Day9.process("""
      99999
      91999
      99999
      99999
      99999
    """) == 2
  end

  test "mid liner" do
    assert Day9.process("""
      99999
      99999
      99919
      99999
      99999
    """) == 2
  end

  test "bottom line" do
    assert Day9.process("""
      99999
      99999
      99999
      99999
      99199
    """) == 2
  end
end
