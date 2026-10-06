defmodule ArmoredStore.Examples do
  @moduledoc """
  Free worked examples that a book page links to. There is one: Book 2 of the Armored Fail Fast set links its invented
  vendor recommendation memo (a filled-in rubric self-audit). The file served is an exact copy of the one in that
  book's folder, kept in priv/examples/ (outside priv/static, so no static path reaches it); it is sent only through
  /books/<slug>/example for the book listed here. The book files themselves are never served.
  """

  @examples %{
    "armored-fail-fast-2-the-performance-assessment" => %{
      label: "Example: a vendor recommendation memo",
      file: "example_rubric_self_audit.pdf",
      filename: "vendor-recommendation-memo-example.pdf"
    }
  }

  def get(slug) when is_binary(slug), do: Map.get(@examples, slug)
  def get(_), do: nil

  def url(slug), do: "/books/#{slug}/example"

  def path(%{file: f}), do: Application.app_dir(:armored_store, Path.join("priv/examples", f))
end
