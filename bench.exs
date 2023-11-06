alias DoublyLinkedList, as: DLL

{one_dll, one_node} = DLL.insert_tail(%DLL{}, "one")
{onek_dll, _} = Enum.reduce(1..1_000, %DLL{}, &DLL.insert_tail(&2, &1))
{_, onek_random_node} = Enum.random(onek_dll.nodes)
{tenk_dll, _} = Enum.reduce(1..10_000, %DLL{}, &DLL.insert_tail(&2, &1))
{_, tenk_random_node} = Enum.random(tenk_dll.nodes)

Benchee.run(%{
  "insert_head/2 for empty list" => fn -> DLL.insert_head(%DLL{}, "string") end,
  "insert_head/2 for 1k item list" => fn -> DLL.insert_head(onek_dll, "string") end,
  "insert_head/2 for 10k item list" => fn -> DLL.insert_head(tenk_dll, "string") end,
  "insert_tail/2 for empty list" => fn -> DLL.insert_tail(%DLL{}, "string") end,
  "insert_tail/2 for 1k item list" => fn -> DLL.insert_tail(onek_dll, "string") end,
  "insert_tail/2 for 10k item list" => fn -> DLL.insert_tail(tenk_dll, "string") end,
  "remove_head/2 for 1 item list" => fn -> DLL.remove_head(one_dll) end,
  "remove_head/2 for 1k item list" => fn -> DLL.remove_head(onek_dll) end,
  "remove_head/2 for 10k item list" => fn -> DLL.remove_head(tenk_dll) end,
  "remove_tail/2 for 1 item list" => fn -> DLL.remove_tail(one_dll) end,
  "remove_tail/2 for 1k item list" => fn -> DLL.remove_tail(onek_dll) end,
  "remove_tail/2 for 10k item list" => fn -> DLL.remove_tail(tenk_dll) end,
  "get/2 for 1 item list" => fn -> DLL.get(one_dll, one_node) end,
  "get/2 for 1k item list" => fn -> DLL.get(onek_dll, onek_random_node) end,
  "get/2 for 10k item list" => fn -> DLL.get(tenk_dll, tenk_random_node) end,
  "update/2 for 1 item list" => fn -> DLL.update(one_dll, one_node, "update") end,
  "update/2 for 1k item list" => fn -> DLL.update(onek_dll, onek_random_node, "update") end,
  "update/2 for 10k item list" => fn -> DLL.update(tenk_dll, tenk_random_node, "update") end,
  "remove/2 for 1 item list" => fn -> DLL.remove(one_dll, one_node) end,
  "remove/2 for 1k item list" => fn -> DLL.remove(onek_dll, onek_random_node) end,
  "remove/2 for 10k item list" => fn -> DLL.remove(tenk_dll, tenk_random_node) end
})
