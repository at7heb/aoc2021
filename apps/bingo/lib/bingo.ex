defmodule Bingo do
  @moduledoc """
  This is the Bingo Game. The game is a struct, with a value map, a row count map, and a column count map
  The value map maps the value to its coordinates. For this game, the coordinates are 1..5
  The row count map maps a row number to the count of marked numbers in the row.
  The column count map is similar.

  When a number is called, use the value map to see if that number is on the board. If it is, then use
  its coordinates to identify the row and column where the number is on the board.
  Increment the correct row and column counts.

  To determinae if it is a winner, search through the row and column counts to find a value of 5. If there is one,
  then the board is a winner.

  The functions are new, call_number, is_winner?
  """

  defstruct values: %{}, row_counts: %{}, column_counts: %{}

  @doc """
  new.

  Given a list of 5 lists, where each sub-list has 5 number, create the values map of the game.
  Also set the row and column count maps to zero counts

  """
  def new(list_of_lists) do
    g = %__MODULE__{}
    r_counts = Enum.reduce(1..5, %{}, fn ndx, count_map -> Map.put_new(count_map, ndx, 0) end)
    c_counts = Enum.reduce(1..5, %{}, fn ndx, count_map -> Map.put_new(count_map, ndx, 0) end)
    values   = Enum.reduce(1..5, %{}, fn row_number, v_map -> new_row(v_map, list_of_lists, row_number) end)
    %__MODULE__{values: values, row_counts: r_counts, column_counts: c_counts}
  end

  def new_row(%{} = v_map, rows_values, row_index) when is_list(row_values) when length(row_values) == 5 do
    row_values = Enum.at(rows_values, row_index-1)
    Enum.reduce(1..5, v_map,
        fn column_index, v -> Map.put(v, Enum.at(row_values, column_index-1), {row_index, column_index}) end)
  end

  def call_number(%__MODULE__{} = g, number) when is_integer(number) do
    call_number_aux(g, Map.get(g.values, number))
  end

  def call_number_aux(%__MODULE__{} = g, nil), do: g

  def call_number_aux(%__MODULE__{} = g, {row_index, column_index}) do
    rc_new = 1 + Map.get(g.row_counts, row_index)
    cc_new = 1 + Map.get(g.column_counts, column_index)
    rcs_new = Map.put(g.row_counts, row_index, rc_new)
    ccs_new = Map.put(g.column_counts, column_index, cc_new)
    %{g| row_counts: rcs_new, column_counts: ccs_new}
  end

  def is_winner?(%__MODULE__{row_counts: row_counts, column_counts: column_counts} = _g) do
    Enum.reduce(1..5, false, fn index, rv -> rv or (Map.get(row_counts, index) == 5) or (Map.get(column_counts, index) == 5) end)
  end
end
