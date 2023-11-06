defmodule DoublyLinkedListTest do
  use ExUnit.Case
  alias DoublyLinkedList, as: DLL
  doctest DoublyLinkedList

  describe "new/0" do
    test "returns a new DLL" do
      assert DLL.new() == %DLL{}
    end
  end

  describe "insert_head/2" do
    test "inserts into an empty list" do
      {dll, _} = %DLL{} |> DLL.insert_head("test")

      assert dll.head == dll.tail
      assert map_size(dll.nodes) == 1
    end

    test "updates a singularly populated list" do
      {dll, _} = %DLL{} |> DLL.insert_head("test")
      old_head = dll.head
      {dll, _} = DLL.insert_head(dll, "test2")

      refute dll.head == old_head
      assert dll.tail == old_head
      assert map_size(dll.nodes) == 2
    end

    test "updates a populated list" do
      {dll, _} = %DLL{} |> DLL.insert_head("test") |> DLL.insert_head("test2")
      old_head = dll.head
      {dll, _} = DLL.insert_head(dll, "test3")

      refute dll.head == old_head
      refute dll.tail == old_head
      assert map_size(dll.nodes) == 3
    end
  end

  describe "insert_tail/2" do
    test "inserts into an empty list" do
      {dll, _} = %DLL{} |> DLL.insert_tail("test")

      assert dll.head == dll.tail
      assert map_size(dll.nodes) == 1
    end

    test "updates a singularly populated list" do
      {dll, _} = %DLL{} |> DLL.insert_tail("test")
      old_tail = dll.tail
      {dll, _} = DLL.insert_tail(dll, "test2")

      refute dll.tail == old_tail
      assert dll.head == old_tail
      assert map_size(dll.nodes) == 2
    end

    test "updates a populated list" do
      {dll, _} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test2")
      old_tail = dll.tail
      {dll, _} = DLL.insert_tail(dll, "test3")

      refute dll.tail == old_tail
      refute dll.head == old_tail
      assert map_size(dll.nodes) == 3
    end
  end

  describe "insert_before/2" do
    test "inserts before the node and becomes head" do
      {dll, tail_node} = %DLL{} |> DLL.insert_tail("test")
      {dll, node} = DLL.insert_before(dll, tail_node, "test2")

      head_node = Map.get(dll.nodes, dll.head)
      node = Map.get(dll.nodes, node.id)
      tail_node = Map.get(dll.nodes, dll.tail)

      assert head_node == node
      assert node.next == tail_node.id
      assert map_size(dll.nodes) == 2
    end

    test "inserts before the node" do
      {dll, tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test2")
      {dll, node} = DLL.insert_before(dll, tail_node, "test3")

      head_node = Map.get(dll.nodes, dll.head)
      node = Map.get(dll.nodes, node.id)
      tail_node = Map.get(dll.nodes, dll.tail)

      assert node.prev == head_node.id
      assert node.next == tail_node.id
      assert map_size(dll.nodes) == 3
    end

    test "returns nil if the insertion failed" do
      {dll, _tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test2")
      {dll, node} = DLL.insert_before(dll, "unknown_id", "test3")

      assert node |> is_nil()
      assert map_size(dll.nodes) == 2
    end
  end

  describe "insert_after/2" do
    test "inserts after the node and becomes tail" do
      {dll, tail_node} = %DLL{} |> DLL.insert_tail("test")
      {dll, node} = DLL.insert_after(dll, tail_node, "test2")

      head_node = Map.get(dll.nodes, dll.head)
      node = Map.get(dll.nodes, node.id)
      tail_node = Map.get(dll.nodes, dll.tail)

      assert tail_node == node
      assert node.prev == head_node.id
      assert map_size(dll.nodes) == 2
    end

    test "inserts after the node" do
      {dll, tail_node} = %DLL{} |> DLL.insert_head("test") |> DLL.insert_head("test2")
      {dll, node} = DLL.insert_after(dll, tail_node, "test3")

      head_node = Map.get(dll.nodes, dll.head)
      node = Map.get(dll.nodes, node.id)
      tail_node = Map.get(dll.nodes, dll.tail)

      assert node.prev == head_node.id
      assert node.next == tail_node.id
      assert map_size(dll.nodes) == 3
    end

    test "returns nil if the insertion failed" do
      {dll, _tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test2")
      {dll, node} = DLL.insert_after(dll, "unknown_id", "test3")

      assert node |> is_nil()
      assert map_size(dll.nodes) == 2
    end
  end

  describe "remove_head/1" do
    test "removes the node at the head of the list" do
      {dll, tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test2")
      new_dll = DLL.remove_head(dll)

      assert new_dll.head == tail_node.id
      assert new_dll.tail == tail_node.id
      assert map_size(new_dll.nodes) == 1
    end

    test "removes the node when scaling to 0" do
      {dll, _tail_node} = %DLL{} |> DLL.insert_tail("test")
      new_dll = DLL.remove_head(dll)

      assert new_dll.head |> is_nil()
      assert new_dll.tail |> is_nil()
      assert map_size(new_dll.nodes) == 0
    end
  end

  describe "remove_tail/1" do
    test "removes the node at the tail of the list" do
      {dll, head_node} = %DLL{} |> DLL.insert_head("test") |> DLL.insert_head("test2")
      new_dll = DLL.remove_tail(dll)

      assert new_dll.head == head_node.id
      assert new_dll.tail == head_node.id
      assert map_size(new_dll.nodes) == 1
    end

    test "removes the node when scaling to 0" do
      {dll, _tail_node} = %DLL{} |> DLL.insert_tail("test")
      new_dll = DLL.remove_tail(dll)

      assert new_dll.head |> is_nil()
      assert new_dll.tail |> is_nil()
      assert map_size(new_dll.nodes) == 0
    end
  end

  describe "remove_before/2" do
    test "does nothing if the node is head" do
      {dll, head_node} = %DLL{} |> DLL.insert_tail("test")
      new_dll = DLL.remove_before(dll, head_node)

      assert dll == new_dll
    end

    test "removes the node before" do
      {dll, head_node} = %DLL{} |> DLL.insert_tail("test")
      {dll, _middle_node} = DLL.insert_tail(dll, "test2")
      {dll, tail_node} = DLL.insert_tail(dll, "test3")

      new_dll = DLL.remove_before(dll, tail_node)

      assert new_dll.head == head_node.id
      assert new_dll.tail == tail_node.id
      assert Map.get(new_dll.nodes, tail_node.id) |> Map.get(:prev) == head_node.id
      assert map_size(new_dll.nodes) == 2
    end

    test "removes the node and becomes head" do
      {dll, _head_node} = %DLL{} |> DLL.insert_tail("test")
      {dll, tail_node} = DLL.insert_tail(dll, "test2")
      new_dll = DLL.remove_before(dll, tail_node)

      assert new_dll.head == tail_node.id
      assert new_dll.tail == tail_node.id
      assert map_size(new_dll.nodes) == 1
    end
  end

  describe "remove_after/2" do
    test "does nothing if the node is tail" do
      {dll, tail_node} = %DLL{} |> DLL.insert_tail("test")
      new_dll = DLL.remove_after(dll, tail_node)

      assert dll == new_dll
    end

    test "removes the node after" do
      {dll, head_node} = %DLL{} |> DLL.insert_tail("test")
      {dll, _middle_node} = DLL.insert_tail(dll, "test2")
      {dll, tail_node} = DLL.insert_tail(dll, "test3")

      new_dll = DLL.remove_after(dll, head_node)

      assert new_dll.head == head_node.id
      assert new_dll.tail == tail_node.id
      assert Map.get(new_dll.nodes, head_node.id) |> Map.get(:next) == tail_node.id
      assert map_size(new_dll.nodes) == 2
    end

    test "removes the node and becomes tail" do
      {dll, head_node} = %DLL{} |> DLL.insert_tail("test")
      {dll, _tail_node} = DLL.insert_tail(dll, "test2")
      new_dll = DLL.remove_after(dll, head_node)

      assert new_dll.head == head_node.id
      assert new_dll.tail == head_node.id
      assert map_size(new_dll.nodes) == 1
    end
  end

  describe "get/2" do
    test "returns the node" do
      {dll, tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test2")
      node = DLL.get(dll, tail_node)

      assert tail_node == node
    end

    test "returns nil if the node doesn't exist" do
      {dll, _tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test2")
      assert nil == DLL.get(dll, "unknown_id")
    end
  end

  describe "get_head/1" do
    test "returns the head node" do
      {dll, head_node} = %DLL{} |> DLL.insert_head("test") |> DLL.insert_head("test2")
      node = DLL.get_head(dll)

      assert head_node == node
    end

    test "returns nil if the list is empty" do
      assert nil == DLL.get_head(DLL.new())
    end
  end

  describe "get_tail/1" do
    test "returns the tail node" do
      {dll, tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test2")
      node = DLL.get_tail(dll)

      assert tail_node == node
    end

    test "returns nil if the list is empty" do
      assert nil == DLL.get_tail(DLL.new())
    end
  end

  describe "get_next/2" do
    test "returns the next node" do
      {dll, tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test2")
      node = DLL.get_next(dll, dll.head)

      assert tail_node == node
    end

    test "returns nil if the node doesn't exist" do
      {dll, tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test2")
      assert nil == DLL.get_next(dll, tail_node)
    end
  end

  describe "get_prev/2" do
    test "returns the previous node" do
      {dll, head_node} = %DLL{} |> DLL.insert_head("test") |> DLL.insert_head("test2")
      node = DLL.get_prev(dll, dll.tail)

      assert head_node == node
    end

    test "returns nil if the node doesn't exist" do
      {dll, head_node} = %DLL{} |> DLL.insert_head("test") |> DLL.insert_head("test2")
      assert nil == DLL.get_prev(dll, head_node)
    end
  end

  describe "update/3" do
    test "updated the data" do
      {dll, tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test3")
      dll = DLL.update(dll, tail_node, "test2")

      assert DLL.get(dll, tail_node) |> Map.get(:data) == "test2"
    end

    test "returns nil if the node doesn't exist" do
      {dll, _tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test2")
      assert nil == DLL.update(dll, "unknown_id", "test3")
    end
  end

  describe "find_from_head/2" do
    test "returns the node or nil" do
      {dll, _tail_node} =
        Enum.reduce(1..100, %DLL{}, fn i, acc -> DLL.insert_tail(acc, "test#{i}") end)

      refute is_nil(DLL.find_from_head(dll, "test86"))
      assert is_nil(DLL.find_from_head(dll, "test101"))
    end

    test "returns nil if the dll is empty" do
      dll = DLL.new()
      assert is_nil(DLL.find_from_head(dll, "test"))
    end
  end

  describe "find_from_tail/2" do
    test "returns the node or nil" do
      {dll, _tail_node} =
        Enum.reduce(1..100, %DLL{}, fn i, acc -> DLL.insert_tail(acc, "test#{i}") end)

      refute is_nil(DLL.find_from_tail(dll, "test86"))
      assert is_nil(DLL.find_from_tail(dll, "test101"))
    end

    test "returns nil if the dll is empty" do
      dll = DLL.new()
      assert is_nil(DLL.find_from_tail(dll, "test"))
    end
  end

  describe "Enumerable" do
    test "count/1" do
      {dll, _tail_node} =
        Enum.reduce(1..100, %DLL{}, fn i, acc -> DLL.insert_tail(acc, "test#{i}") end)

      assert Enum.count(dll) == 100
    end

    test "member?/2" do
      {dll, _tail_node} =
        Enum.reduce(1..100, %DLL{}, fn i, acc -> DLL.insert_tail(acc, "test#{i}") end)

      assert true == Enum.member?(dll, "test86")
      assert false == Enum.member?(dll, "test101")
    end

    test "reduce/3" do
      {dll, _tail_node} =
        Enum.reduce(1..100, %DLL{}, fn i, acc -> DLL.insert_tail(acc, i) end)

      list = Enum.reduce(dll, [], fn i, acc -> [i | acc] end)
      assert Enum.to_list(100..1) == list

      half_list =
        Enum.reduce_while(dll, [], fn
          51, acc -> {:halt, acc}
          i, acc -> {:cont, [i | acc]}
        end)

      assert Enum.to_list(50..1) == half_list
    end

    test "slice/3" do
      {dll, _tail_node} =
        Enum.reduce(1..100, %DLL{}, fn i, acc -> DLL.insert_tail(acc, i) end)

      subset = Enum.slice(dll, 0, 10)
      assert Enum.to_list(1..10) == subset
    end
  end
end
