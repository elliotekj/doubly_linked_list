# Doubly Linked List

**A fast, ammortised O(log n) doubly linked list implementation.**

A doubly linked list is a type of linked list in which each node contains three
elements: a data value, a pointer to the next node in the list, and a pointer to
the previous node. This two-way linkage allows traversal of the list in both
directions, forward and backward, which is a significant advantage over a singly
linked list that can only be traversed in one direction.

## Installation

The package can be installed by adding `doubly_linked_list` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:doubly_linked_list, "~> 0.1.0"}
  ]
end
```

## Usage ([full documentation](https://hexdocs.pm/doubly_linked_list))

A new doubly linked list can be constructed using `new/0`:

```
iex> dll = DoublyLinkedList.new()
#DoublyLinkedList<[]>
```

Many types of insertion and deletion are supported, the most basic being
`insert_head/2`, `insert_tail/2`, `remove_head/1` and `remove_tail/2` which will
insert and remove at the head and tail of the doubly linked list respectively:

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

## License

`DoublyLinkedList` is released under the [`Apache License
2.0`](https://github.com/elliotekj/doubly_linked_list/blob/main/LICENSE).

## About

This package was written by [Elliot Jackson](https://elliotekj.com).

- Blog: [https://elliotekj.com](https://elliotekj.com)
- Email: elliot@elliotekj.com
