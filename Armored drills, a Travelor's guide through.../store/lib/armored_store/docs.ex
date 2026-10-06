defmodule ArmoredStore.Docs do
  @moduledoc """
  WGU handoff docs copied into priv/docs/ (README.md, TECHNICAL.md).
  Rendered on `/` and at `/docs/readme` + `/docs/technical`.
  """

  @docs_dir "priv/docs"

  def readme, do: load("README.md")
  def technical, do: load("TECHNICAL.md")

  def load(name) when name in ~w(README.md TECHNICAL.md) do
    path = Path.join(@docs_dir, name)

    case File.read(path) do
      {:ok, body} -> %{name: name, path: path, body: body, html: ArmoredStore.Markdown.to_html(body)}
      {:error, _} -> %{name: name, path: path, body: "", html: "<p><em>Missing #{name}.</em></p>"}
    end
  end

  def load(_), do: nil
end
