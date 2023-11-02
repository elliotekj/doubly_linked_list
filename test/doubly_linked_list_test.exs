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
end
