defmodule DoublyLinkedList do
  defstruct head: nil, tail: nil, nodes: %{}

  alias DoublyLinkedList.Node

  def new, do: %__MODULE__{}

  def insert_head(%__MODULE__{head: head, tail: tail, nodes: nodes} = dll, data) do
    node = Node.new(data, next: head)
    nodes = nodes |> upsert_node(node) |> update_head_pointer(head, node.id)

    {%{dll | nodes: nodes, head: node.id, tail: tail || node.id}, node}
  end

  def insert_head({%__MODULE__{} = dll, _node}, data), do: insert_head(dll, data)

  def insert_tail(%__MODULE__{head: head, tail: tail, nodes: nodes} = dll, data) do
    node = Node.new(data, prev: tail)
    nodes = nodes |> upsert_node(node) |> update_tail_pointer(tail, node.id)

    {%{dll | nodes: nodes, head: head || node.id, tail: node.id}, node}
  end

  def insert_tail({%__MODULE__{} = dll, _node}, data), do: insert_tail(dll, data)

  def insert_before(%__MODULE__{} = dll, before_node_id, data) when is_binary(before_node_id) do
    with before_node when not is_nil(before_node) <- get_node(dll.nodes, before_node_id),
         %{prev: prev} when not is_nil(prev) <- before_node,
         after_node <- get_prev_node(dll.nodes, before_node) do
      update_inbetween(dll, after_node, before_node, data)
    else
      nil -> {dll, nil}
      %{prev: nil} -> insert_head(dll, data)
    end
  end

  def insert_before(%__MODULE__{} = dll, %Node{} = before_node, data) do
    insert_before(dll, before_node.id, data)
  end

  def insert_after(%__MODULE__{} = dll, after_node_id, data) when is_binary(after_node_id) do
    with after_node when not is_nil(after_node) <- get_node(dll.nodes, after_node_id),
         %{next: next} when not is_nil(next) <- after_node,
         before_node <- get_next_node(dll.nodes, after_node) do
      update_inbetween(dll, after_node, before_node, data)
    else
      nil -> {dll, nil}
      %{prev: nil} -> insert_tail(dll, data)
    end
  end

  def insert_after(%__MODULE__{} = dll, %Node{} = after_node, data) do
    insert_after(dll, after_node.id, data)
  end

  def remove_head(%__MODULE__{} = dll) do
    case get_node(dll.nodes, dll.head) do
      %{next: nil} ->
        new()

      old_head ->
        new_head = get_next_node(dll.nodes, old_head)
        nodes = dll.nodes |> delete_node(dll.head) |> upsert_node(%{new_head | prev: nil})

        %{dll | nodes: nodes, head: new_head.id}
    end
  end

  def remove_head({%__MODULE__{} = dll, _node}), do: remove_head(dll)

  def remove_tail(%__MODULE__{} = dll) do
    case get_node(dll.nodes, dll.tail) do
      %{prev: nil} ->
        new()

      old_tail ->
        new_tail = get_prev_node(dll.nodes, old_tail)
        nodes = dll.nodes |> delete_node(dll.tail) |> upsert_node(%{new_tail | next: nil})

        %{dll | nodes: nodes, tail: new_tail.id}
    end
  end

  def remove_tail({%__MODULE__{} = dll, _node}), do: remove_tail(dll)

  def remove_before(%__MODULE__{} = dll, before_node_id) when is_binary(before_node_id) do
    with %{prev: prev} = before_node when prev != nil <- get_node(dll.nodes, before_node_id),
         %{prev: prev} = old_prev_node when prev != nil <- get_prev_node(dll.nodes, before_node),
         new_prev_node <- get_prev_node(dll.nodes, old_prev_node) do
      nodes =
        dll.nodes
        |> delete_node(old_prev_node)
        |> upsert_node(%{new_prev_node | next: before_node_id})
        |> upsert_node(%{before_node | prev: new_prev_node.id})

      %{dll | nodes: nodes}
    else
      %{id: id, prev: nil} when id == before_node_id -> dll
      %{prev: nil, next: next} when next == before_node_id -> remove_head(dll)
    end
  end

  def remove_before(%__MODULE__{} = dll, %Node{} = before_node) do
    remove_before(dll, before_node.id)
  end

  def remove_after(%__MODULE__{} = dll, after_node_id) when is_binary(after_node_id) do
    with %{next: next} = after_node when next != nil <- get_node(dll.nodes, after_node_id),
         %{next: next} = old_next_node when next != nil <- get_next_node(dll.nodes, after_node),
         new_next_node <- get_next_node(dll.nodes, old_next_node) do
      nodes =
        dll.nodes
        |> delete_node(old_next_node)
        |> upsert_node(%{new_next_node | prev: after_node_id})
        |> upsert_node(%{after_node | next: new_next_node.id})

      %{dll | nodes: nodes}
    else
      %{id: id, next: nil} when id == after_node_id -> dll
      %{prev: prev, next: nil} when prev == after_node_id -> remove_tail(dll)
    end
  end

  def remove_after(%__MODULE__{} = dll, %Node{} = after_node) do
    remove_after(dll, after_node.id)
  end

  def get(%__MODULE__{} = dll, node_id) when is_binary(node_id), do: get_node(dll.nodes, node_id)
  def get(%__MODULE__{} = dll, %Node{} = node), do: get_node(dll.nodes, node)

  def update(%__MODULE__{} = dll, node_id, data) when is_binary(node_id) do
    case get_node(dll.nodes, node_id) do
      nil ->
        nil

      node ->
        nodes = dll.nodes |> upsert_node(%{node | data: data})
        %{dll | nodes: nodes}
    end
  end

  def update(%__MODULE__{} = dll, %Node{} = node, data) do
    update(dll, node.id, data)
  end

  defp get_node(nodes, node_id) when is_binary(node_id), do: Map.get(nodes, node_id)
  defp get_node(nodes, %Node{id: id}), do: Map.get(nodes, id)

  defp get_prev_node(nodes, node_id) when is_binary(node_id) do
    node = get_node(nodes, node_id)
    get_prev_node(nodes, node)
  end

  defp get_prev_node(_nodes, %Node{prev: nil}), do: nil
  defp get_prev_node(nodes, %Node{prev: prev_id}), do: get_node(nodes, prev_id)

  defp get_next_node(nodes, node_id) when is_binary(node_id) do
    node = get_node(nodes, node_id)
    get_next_node(nodes, node)
  end

  defp get_next_node(_nodes, %Node{next: nil}), do: nil
  defp get_next_node(nodes, %Node{next: next_id}), do: get_node(nodes, next_id)

  defp upsert_node(nodes, %Node{id: id} = node), do: Map.put(nodes, id, node)

  defp delete_node(nodes, node_id) when is_binary(node_id), do: Map.delete(nodes, node_id)
  defp delete_node(nodes, %Node{id: id}), do: Map.delete(nodes, id)

  defp update_inbetween(%__MODULE__{} = dll, %Node{} = after_node, %Node{} = before_node, data) do
    node = Node.new(data, prev: after_node.id, next: before_node.id)

    nodes =
      dll.nodes
      |> upsert_node(%{after_node | next: node.id})
      |> upsert_node(node)
      |> upsert_node(%{before_node | prev: node.id})

    {%{dll | nodes: nodes}, node}
  end

  defp update_head_pointer(nodes, nil, _new_head), do: nodes

  defp update_head_pointer(nodes, current_head, new_head) do
    Map.update!(nodes, current_head, fn node -> %{node | prev: new_head} end)
  end

  defp update_tail_pointer(nodes, nil, _new_tail), do: nodes

  defp update_tail_pointer(nodes, current_tail, new_tail) do
    Map.update!(nodes, current_tail, fn node -> %{node | next: new_tail} end)
  end
end
