defmodule Day12 do
  @moduledoc """
  Documentation for `Day12`.
  """
  def run() do
    process("""
  end-MY
  MY-xc
  ho-NF
  start-ho
  NF-xc
  NF-yf
  end-yf
  xc-TP
  MY-qo
  yf-TP
  dc-NF
  dc-xc
  start-dc
  yf-MY
  MY-ho
  EM-uh
  xc-yf
  ho-dc
  uh-NF
  yf-ho
  end-uh
  start-NF
  """)
  end

  def process(txt) do
    txt
    |> parse()                  # get the node pairs
    |> normalize()              # make two pairs unless start or end
    |> make_edges()             # convert to map from node to a list of nodes
    |> find_paths()             # find them
    |> IO.inspect(label: "after find_paths")
    |> present_paths()          # show them/whatever for debugging
    |> present_paths_count()    # the answer
  end

  def parse(txt) do
    txt
    |> String.split("\n", trim: true)               # make list of nodes/edge
    |> Enum.map(fn x -> String.split(x, "-") end)   # make list of [node1, node2]
  end

  def normalize(node_pair_list) do
    node_pair_list    # make sure "start" is always node1
                      # make sure "end" is always node2
                      # make sure other edges are bi-directoional
    |> Enum.map(fn [n1, n2] = _node_pair -> normalize_one_node_pair(n1, n2) end)
    |> List.flatten() # bi-directional edges are lists of two node pair lists
  end

  def normalize_one_node_pair("end", n), do: {n, "end"}
  def normalize_one_node_pair(n, "end"), do: {n, "end"}
  def normalize_one_node_pair(n, "start"), do: {"start", n}
  def normalize_one_node_pair("start", n), do: {"start", n}
  def normalize_one_node_pair(n1, n2), do: [{n1, n2}, {n2, n1}]

  def make_edges(node_pair_list) do
    # return map from node to a list of reachable nodes
    # m-n input will results in %{"m": ["n"], "n": ["m"]}
    # adding m-o results in %{"m": ["n", "o"], "n": ["m"], "o": ["m"]}
    node_pair_list
    |> Enum.reduce(%{}, fn pair, edge_map -> add_edge(edge_map, pair) end)
  end

  def add_edge(edge_map, {n1, n2}) do
    cond do
      Map.has_key?(edge_map, n1) ->
        Map.put(edge_map, n1, [n2 | Map.get(edge_map, n1)])
      true ->
        Map.put(edge_map, n1, [n2])
    end
  end

  def find_paths(edge_map) do
    # work on current path, save discovered paths in known_paths
    # the current path is a list with the most recent node first
    # so "start" will always be at the end of the current path
    # since all we have to do with discovered paths is count them,
    # they are also in order ["end", ..., "start]
    # IO.inspect("find paths_0")
    find_paths_1(%{edge_map: edge_map, current_path: ["start"], paths: []})
  end

  def find_paths_1(%{edge_map: edge_map, current_path: [this_node | _previous_nodes] = path} = state) do
    # IO.inspect("find_paths_1")
    reachable_nodes = Map.get(edge_map, this_node)  # search from each reachable node
    IO.inspect(reachable_nodes, label: :fp1_reachable_nodes)
    if reachable_nodes == [] or reachable_nodes == nil do
      state # |> IO.inspect(label: "fp1 nothing reachable")
    else
      new_edge_map = prune_edge_map(edge_map, this_node)
      new_state = %{state | edge_map: new_edge_map}
      reachable_nodes
      |> Enum.reduce(new_state,
          fn node, state -> find_paths_2(%{state| edge_map: new_edge_map, current_path: [node | path]}) end)
      # |> IO.inspect(label: "fp1 worked through nodes")
    end
  end

  def find_paths_2(%{current_path: ["end" | _rest] = current_path, paths: paths} = state),
    do: (IO.inspect("find_paths_2a"); %{state| paths: [current_path | paths]})
    # if the current node is "end", we have a path. add it to paths and return.

  def find_paths_2(%{} = state) do
    # refactor opportunity.
    # find a path to "end", which is what find_paths_1() does
    # IO.inspect(state.current_path, label: "find_paths_2b")
    cond do
      length(state.current_path) > 200 -> IO.puts("error, loop-------------------------------------------------------------------------------------------")
      true -> find_paths_1(state)
    end
  end

  def prune_edge_map(edge_map, node) do
    if String.downcase(node) == node do
      edge_map
        |> Map.delete(node)
        |> prune_edge_map_for_destination(node)
    else
      edge_map
    end
end

  def prune_edge_map_for_destination(edge_map, node) do
    Map.keys(edge_map)
    |> Enum.reduce(edge_map, fn key, edge_map -> modify_map_for_key_destination(edge_map, key, node) end)
  end

  def modify_map_for_key_destination(edge_map, key, node) do
    cond do
      Map.get(edge_map, key) == [node] ->
        Map.delete(edge_map, key)
      true ->
        Map.replace(edge_map, key, Map.get(edge_map, key) -- [node])
    end
  end

  def present_paths(x), do: IO.inspect(x, label: "the paths")
  def present_paths_count(x) do
    IO.puts("The number of paths is #{length(x.paths)}")
    IO.puts("The number of paths is #{length(Enum.uniq(x.paths))}")
  end
end
