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
      node = Map.get(dll.nodes, node.__id__)
      tail_node = Map.get(dll.nodes, dll.tail)

      assert head_node == node
      assert node.next == tail_node.__id__
      assert map_size(dll.nodes) == 2
    end

    test "inserts before the node" do
      {dll, tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test2")
      {dll, node} = DLL.insert_before(dll, tail_node, "test3")

      head_node = Map.get(dll.nodes, dll.head)
      node = Map.get(dll.nodes, node.__id__)
      tail_node = Map.get(dll.nodes, dll.tail)

      assert node.prev == head_node.__id__
      assert node.next == tail_node.__id__
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
      node = Map.get(dll.nodes, node.__id__)
      tail_node = Map.get(dll.nodes, dll.tail)

      assert tail_node == node
      assert node.prev == head_node.__id__
      assert map_size(dll.nodes) == 2
    end

    test "inserts after the node" do
      {dll, tail_node} = %DLL{} |> DLL.insert_head("test") |> DLL.insert_head("test2")
      {dll, node} = DLL.insert_after(dll, tail_node, "test3")

      head_node = Map.get(dll.nodes, dll.head)
      node = Map.get(dll.nodes, node.__id__)
      tail_node = Map.get(dll.nodes, dll.tail)

      assert node.prev == head_node.__id__
      assert node.next == tail_node.__id__
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

      assert new_dll.head == tail_node.__id__
      assert new_dll.tail == tail_node.__id__
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

      assert new_dll.head == head_node.__id__
      assert new_dll.tail == head_node.__id__
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

      assert new_dll.head == head_node.__id__
      assert new_dll.tail == tail_node.__id__
      assert Map.get(new_dll.nodes, tail_node.__id__) |> Map.get(:prev) == head_node.__id__
      assert map_size(new_dll.nodes) == 2
    end

    test "removes the node and becomes head" do
      {dll, _head_node} = %DLL{} |> DLL.insert_tail("test")
      {dll, tail_node} = DLL.insert_tail(dll, "test2")
      new_dll = DLL.remove_before(dll, tail_node)

      assert new_dll.head == tail_node.__id__
      assert new_dll.tail == tail_node.__id__
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

      assert new_dll.head == head_node.__id__
      assert new_dll.tail == tail_node.__id__
      assert Map.get(new_dll.nodes, head_node.__id__) |> Map.get(:next) == tail_node.__id__
      assert map_size(new_dll.nodes) == 2
    end

    test "removes the node and becomes tail" do
      {dll, head_node} = %DLL{} |> DLL.insert_tail("test")
      {dll, _tail_node} = DLL.insert_tail(dll, "test2")
      new_dll = DLL.remove_after(dll, head_node)

      assert new_dll.head == head_node.__id__
      assert new_dll.tail == head_node.__id__
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

  describe "update/3" do
    test "updated the data" do
      {dll, tail_node} = %DLL{} |> DLL.insert_tail("test") |> DLL.insert_tail("test3")
      dll = DLL.update(dll, tail_node, "test2")

      assert DLL.get(dll, tail_node) |> Map.get(:data) == "test2"
    end
  end
end
