defmodule DoublyLinkedList do
  defstruct head: nil, tail: nil, nodes: %{}

  alias DoublyLinkedList.Node

  def new, do: %__MODULE__{}

  def insert_head(%__MODULE__{head: head, tail: tail, nodes: nodes} = dll, data) do
    node = Node.new(data, next: head)
    nodes = nodes |> Map.put(node.__id__, node) |> update_head_pointer(head, node.__id__)

    {%{dll | nodes: nodes, head: node.__id__, tail: tail || node.__id__}, node}
  end

  def insert_head({%__MODULE__{} = dll, _node}, data), do: insert_head(dll, data)

  def insert_tail(%__MODULE__{head: head, tail: tail, nodes: nodes} = dll, data) do
    node = Node.new(data, prev: tail)
    nodes = nodes |> Map.put(node.__id__, node) |> update_tails(tail, node.__id__)

    {%{dll | nodes: nodes, head: head || node.__id__, tail: node.__id__}, node}
  end

  def insert_tail({%__MODULE__{} = dll, _node}, data), do: insert_tail(dll, data)

  def insert_before(%__MODULE__{} = dll, before_node_id, data) when is_binary(before_node_id) do
    # TODO Handle raise
    before_node = Map.fetch!(dll.nodes, before_node_id)
    insert_before(dll, before_node, data)
  end

  def insert_before(%__MODULE__{} = dll, %Node{} = before_node, data) do
    case Map.get(dll.nodes, before_node.prev) do
      nil -> insert_head(dll, data)
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
      nil -> insert_tail(dll, data)
      before_node -> update_inbetween(dll, after_node, before_node, data)
    end
  end

  def remove_head(%__MODULE__{} = dll) do
    case Map.get(dll.nodes, dll.head) do
      %{next: nil} ->
        new()

      old_head ->
        new_head = Map.get(dll.nodes, old_head.next)

        nodes =
          dll.nodes
          |> Map.delete(dll.head)
          |> Map.put(new_head.__id__, %{new_head | prev: nil})

        %{dll | nodes: nodes, head: new_head.__id__}
    end
  end

  def remove_head({%__MODULE__{} = dll, _node}), do: remove_head(dll)

  def remove_tail(%__MODULE__{} = dll) do
    case Map.get(dll.nodes, dll.tail) do
      %{prev: nil} ->
        new()

      old_tail ->
        new_tail = Map.get(dll.nodes, old_tail.prev)

        nodes =
          dll.nodes
          |> Map.delete(dll.tail)
          |> Map.put(new_tail.__id__, %{new_tail | next: nil})

        %{dll | nodes: nodes, tail: new_tail.__id__}
    end
  end

  def remove_tail({%__MODULE__{} = dll, _node}), do: remove_tail(dll)

  def remove_before(%__MODULE__{} = dll, before_node_id) when is_binary(before_node_id) do
    with %{prev: prev} = before_node when prev != nil <- Map.get(dll.nodes, before_node_id),
         %{prev: prev} = old_prev_node when prev != nil <- Map.get(dll.nodes, before_node.prev),
         new_prev_node <- Map.get(dll.nodes, old_prev_node.prev) do
      nodes =
        dll.nodes
        |> Map.delete(old_prev_node.__id__)
        |> Map.put(new_prev_node.__id__, %{new_prev_node | next: before_node_id})
        |> Map.put(before_node_id, %{before_node | prev: new_prev_node.__id__})

      %{dll | nodes: nodes}
    else
      %{__id__: id, prev: nil} when id == before_node_id -> dll
      # FIXME Double access for removing head
      %{prev: nil, next: next} when next == before_node_id -> remove_head(dll)
    end
  end

  def remove_before(%__MODULE__{} = dll, %Node{} = before_node) do
    remove_before(dll, before_node.__id__)
  end

  # TODO
  # - remove before
  # - remove after
  # - update
  # - get a fresh copy of the node before using its attributes

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
