defmodule DoublyLinkedList do
  defstruct head: nil, tail: nil, nodes: %{}

  alias DoublyLinkedList.Node

  def new, do: %__MODULE__{}

  def insert_head(%__MODULE__{} = dll, data), do: update_head(dll, data)
  def insert_head({%__MODULE__{} = dll, _node}, data), do: update_head(dll, data)

  def insert_tail(%__MODULE__{} = dll, data), do: update_tail(dll, data)
  def insert_tail({%__MODULE__{} = dll, _node}, data), do: update_tail(dll, data)

  def insert_before(%__MODULE__{} = dll, before_node_id, data) when is_binary(before_node_id) do
    # TODO Handle raise
    before_node = Map.fetch!(dll.nodes, before_node_id)
    insert_before(dll, before_node, data)
  end

  def insert_before(%__MODULE__{} = dll, %Node{} = before_node, data) do
    case Map.get(dll.nodes, before_node.prev) do
      nil -> update_head(dll, data)
      after_node -> update_inbetween(dll, after_node, before_node, data)
    end
  end

  def insert_after(%__MODULE__{} = dll, after_node_id, data) when is_binary(after_node_id) do
    # TODO Handle raise
    after_node = Map.fetch!(dll.nodes, after_node_id)
    insert_after(dll, after_node, data)
  end

  def insert_after(%__MODULE__{} = dll, %Node{} = after_node, data) do
    case Map.get(dll.nodes, after_node.next) do
      nil -> update_tail(dll, data)
      before_node -> update_inbetween(dll, after_node, before_node, data)
    end
  end

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

  defp update_inbetween(%__MODULE__{} = dll, %Node{} = after_node, %Node{} = before_node, data) do
    node = Node.new(data, prev: after_node.__id__, next: before_node.__id__)

    nodes =
      dll.nodes
      |> Map.put(after_node.__id__, %{after_node | next: node.__id__})
      |> Map.put(node.__id__, node)
      |> Map.put(before_node.__id__, %{before_node | prev: node.__id__})

    {%{dll | nodes: nodes}, node}
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
