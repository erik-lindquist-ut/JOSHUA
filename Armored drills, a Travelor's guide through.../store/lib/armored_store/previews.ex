defmodule ArmoredStore.Previews do
  @moduledoc """
  Each book's preview, read from priv/PREVIEWS.json: the book's foreword (or, when it has none, its opening
  section), copied exactly from the book's own .docx (or, for the Armored business drills, its own .pdf) by
  tools/extract_previews.py. An Armored Fail Fast book previews its "What this is" paragraph and its book table
  (paragraphs of kind "row", the first row of a run being the table's header). The book files themselves are never
  served.
  """

  @doc "Every preview, keyed by product slug."
  def all do
    Application.app_dir(:armored_store, "priv/PREVIEWS.json")
    |> File.read!()
    |> Jason.decode!()
    |> Map.new(fn {slug, p} -> {slug, to_preview(p)} end)
  end

  def get(slug) when is_binary(slug), do: Map.get(all(), slug)
  def get(_), do: nil

  defp to_preview(p) do
    %{
      section: p["section"],
      kind: p["kind"],
      source: p["source"],
      paragraphs: Enum.map(p["paragraphs"] || [], &%{kind: &1["kind"], text: &1["text"], cells: &1["cells"]})
    }
  end

  @doc "Paragraphs grouped into blocks: runs of list items become one list, runs of table rows one table."
  def blocks(%{paragraphs: paras}) do
    paras
    |> Enum.chunk_by(& &1.kind)
    |> Enum.flat_map(fn
      [%{kind: "li"} | _] = items -> [{:list, Enum.map(items, & &1.text)}]
      [%{kind: "row"} | _] = rows -> [{:table, Enum.map(rows, & &1.cells)}]
      ps -> Enum.map(ps, &{:para, &1.text})
    end)
  end
end
