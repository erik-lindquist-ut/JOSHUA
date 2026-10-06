defmodule ArmoredStore.BookFiles do
  @moduledoc """
  Per-drill file inventory for `/books/:slug/files`.

  Lists PDF/DOCX metadata (names + local relative paths) from KDP_LISTINGS /
  STORE_ADDITIONS manuscripts. Does **not** serve paid binary bytes over HTTP.

  Exception: the WGU Fail Fast Compendium handoff PDF in `priv/static/handoff/`
  is viewable at `/handoff/...` for institutional review.
  """

  @listings "priv/KDP_LISTINGS.json"
  @additions "priv/STORE_ADDITIONS.json"
  @handoff_slug "armored-accounting-for-decision-making"
  @handoff_name "Armored_Accounting_for_Decision_Making_Fail_Fast_Compendium.pdf"
  @handoff_url "/handoff/Armored_Accounting_for_Decision_Making_Fail_Fast_Compendium.pdf"

  def handoff_slug, do: @handoff_slug
  def handoff_url, do: @handoff_url
  def handoff_name, do: @handoff_name

  def books_root, do: Path.expand("..", File.cwd!())

  @doc "File inventory for a product slug, or nil if the product is unknown."
  def for_slug(slug) when is_binary(slug) do
    case entry(slug) do
      nil ->
        nil

      entry ->
        files = inventory(entry, slug)
        %{slug: slug, title: entry["title"], manuscript: entry["manuscript"], files: files}
    end
  end

  def for_slug(_), do: nil

  defp entry(slug) do
    (@listings |> read_list()) ++ (@additions |> read_list())
    |> Enum.find(&(ArmoredStore.Listings.slug(&1) == slug))
  end

  defp read_list(path) do
    case File.read(path) do
      {:ok, body} ->
        case Jason.decode(body) do
          {:ok, list} when is_list(list) -> list
          _ -> []
        end

      _ ->
        []
    end
  end

  defp inventory(entry, slug) do
    listed =
      case entry["manuscript"] do
        m when is_binary(m) and m != "" ->
          dir = Path.dirname(m)
          abs_dir = Path.join(books_root(), dir)

          names =
            if File.dir?(abs_dir) do
              abs_dir
              |> File.ls!()
              |> Enum.filter(&(String.downcase(Path.extname(&1)) in ~w(.pdf .docx .doc)))
              |> Enum.sort()
            else
              [Path.basename(m)]
            end

          for name <- names do
            rel = Path.join(dir, name)
            %{
              name: name,
              path: rel,
              kind: kind(name),
              present?: File.regular?(Path.join(books_root(), rel)),
              downloadable?: false,
              href: nil,
              note: "Local / institutional handoff only — not served over HTTP until priced delivery exists."
            }
          end

        _ ->
          []
      end

    listed
    |> maybe_add_handoff(slug)
    |> Enum.uniq_by(& &1.name)
  end

  defp maybe_add_handoff(files, @handoff_slug) do
    handoff = %{
      name: @handoff_name,
      path: "priv/static/handoff/#{@handoff_name}",
      kind: "pdf",
      present?: File.regular?("priv/static/handoff/#{@handoff_name}"),
      downloadable?: true,
      href: @handoff_url,
      note: "WGU handoff artifact — viewable from priv/static/handoff/."
    }

    [handoff | files]
  end

  defp maybe_add_handoff(files, _), do: files

  defp kind(name) do
    case String.downcase(Path.extname(name)) do
      ".pdf" -> "pdf"
      ".docx" -> "docx"
      ".doc" -> "doc"
      _ -> "file"
    end
  end
end
