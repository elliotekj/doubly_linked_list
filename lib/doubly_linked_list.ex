defmodule DoublyLinkedList do
  @moduledoc """
  A fast, ammortised O(log n) doubly linked list implementation.

  A doubly linked list is a type of linked list in which each node contains
  three elements: a data value, a pointer to the next node in the list, and a
  pointer to the previous node. This two-way linkage allows traversal of the
  list in both directions, forward and backward, which is a significant
  advantage over a singly linked list that can only be traversed in one
  direction.

  A new doubly linked list can be constructed using `new/0`:

  ```
  iex> dll = DoublyLinkedList.new()
  #DoublyLinkedList<[]>
  ```

  Many types of insertion and deletion are supported, the most basic being
  `insert_head/2`, `insert_tail/2`, `remove_head/1` and `remove_tail/2` which
  will insert and remove at the head and tail of the doubly linked list
  respectively:

  ```
  iex> dll = DoublyLinkedList.new()
  #DoublyLinkedList<[]>

  iex> {dll, node} = DoublyLinkedList.insert_tail(dll, "tail value")
  {#DoublyLinkedList<["tail value"]>, #DoublyLinkedNode<"tail value">}

  iex> {dll, node} = DoublyLinkedList.insert_head(dll, "head value")
  {#DoublyLinkedList<["head value", "tail value"]>, #DoublyLinkedNode<"head value">}

  iex> dll = DoublyLinkedList.remove_tail(dll)
  #DoublyLinkedList<["head value"]>

  iex> dll = DoublyLinkedList.remove_head(dll)
  #DoublyLinkedList<[]>
  ```

  Node data can be updated with `update/3`:

  ```
  iex> dll = DoublyLinkedList.new()
  #DoublyLinkedList<[]>

  iex> {dll, node} = DoublyLinkedList.insert_tail(dll, "tail value")
  {#DoublyLinkedList<["tail value"]>, #DoublyLinkedNode<"tail value">}

  iex> dll = DoublyLinkedList.update(dll, node, "new tail value")
  #DoublyLinkedList<["new tail value"]>
  ```

  There are two options for traversal. `DoublyLinkedList` implements the
  Enumerable protocol so `Enum.map/2`, `Enum.member?/2`,
  [etc](https://hexdocs.pm/elixir/1.12/Enum.html#functions) are supported; there
  are also the built-in `find_from_head/2` and `find_from_tail/2` functions.
  `find_from_tail/2` is of particular interest as it traverses the list in
  reverse. Note that traversal methods are O(n).

  ```
  iex> dll = DoublyLinkedList.new()
  iex> {dll, node} = DoublyLinkedList.insert_tail(dll, 1)
  iex> {dll, node} = DoublyLinkedList.insert_tail(dll, 2)
  {#DoublyLinkedList<[1, 2]>, #DoublyLinkedNode<2>}

  iex> Enum.map(dll, fn v -> v * 2 end)
  [2, 4]
  ```
  """

  alias DoublyLinkedList.Node

  defstruct head: nil, tail: nil, nodes: %{}

  @type t :: %__MODULE__{
          head: String.t(),
          tail: String.t(),
          nodes: %{optional(String.t()) => Node.t()}
        }

  @doc "Construct a new list."
  @spec new :: t()
  def new, do: %__MODULE__{}

  @doc "Insert a node at the head of the list."
  @spec insert_head(t(), term()) :: {t(), Node.t()}
  def insert_head(%__MODULE__{head: head, tail: tail, nodes: nodes} = dll, data) do
    node = Node.new(data, next: head)
    nodes = nodes |> upsert_node(node) |> update_head_pointer(head, node.id)

    {%{dll | nodes: nodes, head: node.id, tail: tail || node.id}, node}
  end

  @spec insert_head({t(), Node.t()}, term()) :: {t(), Node.t()}
  def insert_head({%__MODULE__{} = dll, _node}, data), do: insert_head(dll, data)

  @doc "Insert a node at the tail of the list."
  @spec insert_tail(t(), term()) :: {t(), Node.t()}
  def insert_tail(%__MODULE__{head: head, tail: tail, nodes: nodes} = dll, data) do
    node = Node.new(data, prev: tail)
    nodes = nodes |> upsert_node(node) |> update_tail_pointer(tail, node.id)

    {%{dll | nodes: nodes, head: head || node.id, tail: node.id}, node}
  end

  @spec insert_tail({t(), Node.t()}, term()) :: {t(), Node.t()}
  def insert_tail({%__MODULE__{} = dll, _node}, data), do: insert_tail(dll, data)

  @doc "Insert a node before the given node."
  @spec insert_before(t(), String.t(), term()) :: {t(), Node.t() | nil}
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

  @spec insert_before(t(), Node.t(), term()) :: {t(), Node.t() | nil}
  def insert_before(%__MODULE__{} = dll, %Node{} = before_node, data) do
    insert_before(dll, before_node.id, data)
  end

  @doc "Insert a node after the given node."
  @spec insert_after(t(), String.t(), term()) :: {t(), Node.t() | nil}
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

  @spec insert_after(t(), Node.t(), term()) :: {t(), Node.t() | nil}
  def insert_after(%__MODULE__{} = dll, %Node{} = after_node, data) do
    insert_after(dll, after_node.id, data)
  end

  @doc "Remove the node at the head of the list."
  @spec remove_head(t()) :: t()
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

  @doc "Remove the node at the tail of the list."
  @spec remove_tail(t()) :: t()
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

  @doc "Remove the node before the given node."
  @spec remove_before(t(), String.t()) :: t()
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
      nil -> dll
      %{id: id, prev: nil} when id == before_node_id -> dll
      %{prev: nil, next: next} when next == before_node_id -> remove_head(dll)
    end
  end

  @spec remove_before(t(), Node.t()) :: t()
  def remove_before(%__MODULE__{} = dll, %Node{} = before_node) do
    remove_before(dll, before_node.id)
  end

  @doc "Remove the node after the given node."
  @spec remove_after(t(), String.t()) :: t()
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
      nil -> dll
      %{id: id, next: nil} when id == after_node_id -> dll
      %{prev: prev, next: nil} when prev == after_node_id -> remove_tail(dll)
    end
  end

  @spec remove_after(t(), Node.t()) :: t()
  def remove_after(%__MODULE__{} = dll, %Node{} = after_node) do
    remove_after(dll, after_node.id)
  end

  @doc "Remove the node."
  @spec remove(t(), String.t()) :: t()
  def remove(%__MODULE__{} = dll, node_id) when is_binary(node_id) do
    with %{prev: prev, next: next} = node when prev != nil and next != nil <-
           get_node(dll.nodes, node_id),
         prev_node <- get_prev_node(dll.nodes, node),
         next_node <- get_next_node(dll.nodes, node) do
      nodes =
        dll.nodes
        |> delete_node(node)
        |> upsert_node(%{prev_node | next: next_node.id})
        |> upsert_node(%{next_node | prev: prev_node.id})

      %{dll | nodes: nodes}
    else
      nil -> dll
      %{prev: nil} -> remove_head(dll)
      %{next: nil} -> remove_tail(dll)
    end
  end

  @spec remove(t(), Node.t()) :: t()
  def remove(%__MODULE__{} = dll, %Node{id: id}), do: remove(dll, id)

  @doc "Get the node."
  @spec get(t(), String.t()) :: Node.t() | nil
  def get(%__MODULE__{} = dll, node_id) when is_binary(node_id), do: get_node(dll.nodes, node_id)

  @spec get(t(), Node.t()) :: Node.t() | nil
  def get(%__MODULE__{} = dll, %Node{} = node), do: get_node(dll.nodes, node)

  @doc "Get the node at the head of the list."
  @spec get_head(t()) :: nil
  def get_head(%__MODULE__{head: nil}), do: nil

  @spec get_head(t()) :: Node.t()
  def get_head(%__MODULE__{} = dll), do: get_node(dll.nodes, dll.head)

  @doc "Get the node at the tail of the list."
  @spec get_tail(t()) :: nil
  def get_tail(%__MODULE__{tail: nil}), do: nil

  @spec get_tail(t()) :: Node.t()
  def get_tail(%__MODULE__{} = dll), do: get_node(dll.nodes, dll.tail)

  @doc "Get the node after the given node."
  @spec get_next(t(), String.t()) :: Node.t() | nil
  def get_next(%__MODULE__{} = dll, node_id) when is_binary(node_id),
    do: get_next_node(dll.nodes, node_id)

  @spec get_next(t(), Node.t()) :: Node.t() | nil
  def get_next(%__MODULE__{} = dll, %Node{id: id}), do: get_next_node(dll.nodes, id)

  @doc "Get the node before the given node."
  @spec get_prev(t(), String.t()) :: Node.t() | nil
  def get_prev(%__MODULE__{} = dll, node_id) when is_binary(node_id),
    do: get_prev_node(dll.nodes, node_id)

  @spec get_prev(t(), Node.t()) :: Node.t() | nil
  def get_prev(%__MODULE__{} = dll, %Node{id: id}), do: get_prev_node(dll.nodes, id)

  @doc """
  Find the first node whose data matches the given value (starting from the head
  of the list).
  """
  @spec find_from_head(t(), term()) :: Node.t() | nil
  def find_from_head(%__MODULE__{head: nil}, _data), do: nil

  def find_from_head(%__MODULE__{} = dll, data) do
    case get_node(dll.nodes, dll.head) do
      nil -> nil
      head -> return_node_or_step_forwards(dll, head, data)
    end
  end

  @doc """
  Find the first node whose data matches the given value (starting from the tail
  of the list).
  """
  @spec find_from_tail(t(), term()) :: Node.t() | nil
  def find_from_tail(%__MODULE__{tail: nil}, _data), do: nil

  def find_from_tail(%__MODULE__{} = dll, data) do
    case get_node(dll.nodes, dll.tail) do
      nil -> nil
      tail -> return_node_or_step_backwards(dll, tail, data)
    end
  end

  @doc "Update the node with the given value."
  @spec update(t(), String.t(), term()) :: t() | nil
  def update(%__MODULE__{} = dll, node_id, data) when is_binary(node_id) do
    case get_node(dll.nodes, node_id) do
      nil ->
        nil

      node ->
        nodes = dll.nodes |> upsert_node(%{node | data: data})
        %{dll | nodes: nodes}
    end
  end

  @spec update(t(), Node.t(), term()) :: t() | nil
  def update(%__MODULE__{} = dll, %Node{} = node, data) do
    update(dll, node.id, data)
  end

  defimpl Enumerable, for: __MODULE__ do
    def count(%DoublyLinkedList{nodes: nodes}), do: {:ok, Enum.count(nodes)}

    def member?(%DoublyLinkedList{} = dll, data) do
      case DoublyLinkedList.find_from_head(dll, data) do
        nil -> {:ok, false}
        _ -> {:ok, true}
      end
    end

    def reduce(_dll, {:halt, acc}, _fun), do: {:halted, acc}

    def reduce(%DoublyLinkedList{} = dll, {:suspend, acc}, fun),
      do: {:suspended, acc, &reduce(dll, &1, fun)}

    def reduce(%DoublyLinkedList{head: nil}, {:cont, acc}, _fun), do: {:done, acc}

    def reduce(%DoublyLinkedList{head: head} = dll, {:cont, acc}, fun) do
      head = DoublyLinkedList.get(dll, head)
      dll = DoublyLinkedList.remove_head(dll)
      reduce(dll, fun.(head.data, acc), fun)
    end

    # Defaults to the linear-time algorithm
    def slice(_dll), do: {:error, __MODULE__}
  end

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(%DoublyLinkedList{} = dll, opts) do
      opts = %Inspect.Opts{opts | charlists: :as_lists}
      concat(["#DoublyLinkedList<", Inspect.List.inspect(Enum.to_list(dll), opts), ">"])
    end
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

  defp return_node_or_step_forwards(%__MODULE__{} = dll, %Node{} = node, data) do
    cond do
      node.data == data ->
        node

      node.next == nil ->
        nil

      true ->
        next_node = get_next_node(dll.nodes, node)
        return_node_or_step_forwards(dll, next_node, data)
    end
  end

  defp return_node_or_step_backwards(%__MODULE__{} = dll, %Node{} = node, data) do
    cond do
      node.data == data ->
        node

      node.prev == nil ->
        nil

      true ->
        prev_node = get_prev_node(dll.nodes, node)
        return_node_or_step_backwards(dll, prev_node, data)
    end
  end
end
