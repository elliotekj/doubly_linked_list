defmodule DoublyLinkedList.Node do
  defstruct __id__: nil, prev: nil, next: nil, data: nil

  def new(data, opts) do
    prev = opts[:prev]
    next = opts[:next]

    %__MODULE__{__id__: UUID.uuid4(), prev: prev, next: next, data: data}
  end
end
