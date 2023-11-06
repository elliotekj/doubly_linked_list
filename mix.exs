defmodule DoublyLinkedList.MixProject do
  use Mix.Project

  @version "0.1.0"
  @repo_url "https://github.com/elliotekj/doubly_linked_list"

  def project do
    [
      app: :doubly_linked_list,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:elixir_uuid, "~> 1.2"},
      {:ex_doc, "~> 0.30.9"},
      {:benchee, "~> 1.0", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Elliot Jackson"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @repo_url}
    ]
  end

  defp description do
    """
    A fast, ammortised O(log n) doubly linked list implementation.
    """
  end

  defp docs do
    [
      name: "DoublyLinkedList",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/doubly_linked_list",
      source_url: @repo_url
    ]
  end
end
