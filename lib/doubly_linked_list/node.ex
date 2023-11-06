defmodule DoublyLinkedList.Node do
  defstruct id: nil, prev: nil, next: nil, data: nil

  def new(data, opts) do
    prev = opts[:prev]
    next = opts[:next]

    %__MODULE__{id: UUID.uuid4(), prev: prev, next: next, data: data}
  end

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(%DoublyLinkedList.Node{} = node, opts) do
      opts = %Inspect.Opts{opts | charlists: :as_lists}
      concat(["#DoublyLinkedNode<", Inspect.inspect(node.data, opts), ">"])
    end
  end
end
