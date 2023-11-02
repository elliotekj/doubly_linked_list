defmodule DoublyLinkedList do
  defstruct head: nil, tail: nil, nodes: %{}

  alias DoublyLinkedList.Node

  def new, do: %__MODULE__{}

  def insert_head(%__MODULE__{} = dll, data), do: update_head(dll, data)
  def insert_head({%__MODULE__{} = dll, _node}, data), do: update_head(dll, data)

  def insert_tail(%__MODULE__{} = dll, data), do: update_tail(dll, data)
  def insert_tail({%__MODULE__{} = dll, _node}, data), do: update_tail(dll, data)

  defp update_head(%__MODULE__{head: head, tail: tail, nodes: nodes} = dll, data) do
    node = Node.new(data, next: head)
    nodes = nodes |> Map.put(node.__id__, node) |> update_head_pointer(head, node.__id__)

    {%{dll | nodes: nodes, head: node.__id__, tail: tail || node.__id__}, node}
  end

  defp update_tail(%__MODULE__{head: head, tail: tail, nodes: nodes} = dll, data) do
    node = Node.new(data, prev: tail)
    nodes = nodes |> Map.put(node.__id__, node) |> update_tails(tail, node.__id__)

    {%{dll | nodes: nodes, head: head || node.__id__, tail: node.__id__}, node}
  end

  defp update_head_pointer(nodes, nil, _new_head), do: nodes

  defp update_head_pointer(nodes, current_head, new_head) do
    Map.update!(nodes, current_head, fn node -> %{node | prev: new_head} end)
  end

  defp update_tails(nodes, nil, _new_tail), do: nodes

  defp update_tails(nodes, current_tail, new_tail) do
    Map.update!(nodes, current_tail, fn node -> %{node | next: new_tail} end)
  end
end

# TODO
# - insert_before
# - insert_after
# - insert_beginning
# - insert_end
# - remove
