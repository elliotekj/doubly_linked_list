defmodule DoublyLinkedList.Node do
  defstruct id: nil, prev: nil, next: nil, data: nil

  def new(data, opts) do
    prev = opts[:prev]
    next = opts[:next]

    %__MODULE__{id: UUID.uuid4(), prev: prev, next: next, data: data}
  end
end
