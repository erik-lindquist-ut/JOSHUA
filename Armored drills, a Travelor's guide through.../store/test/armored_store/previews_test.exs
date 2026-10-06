defmodule ArmoredStore.PreviewsTest do
  @moduledoc """
  priv/PREVIEWS.json carries each book's preview section (its foreword, or its opening section when it has none),
  extracted by tools/extract_previews.py from the book's own .docx. The text must be the book's exact text.
  """
  use ExUnit.Case, async: true
  alias ArmoredStore.{Listings, Previews}

  @books ".."
  @placeholder "armored-fail-fast-4-the-punch-list"

  defp slugs do
    kdp = "priv/KDP_LISTINGS.json" |> File.read!() |> Listings.products()
    adds = "priv/STORE_ADDITIONS.json" |> File.read!() |> Listings.additions(length(kdp))
    Enum.map(kdp ++ adds, & &1["slug"])
  end

  defp docx_text(path) do
    {:ok, files} = :zip.unzip(String.to_charlist(path), [:memory])
    {_, xml} = Enum.find(files, fn {name, _} -> name == ~c"word/document.xml" end)

    Regex.scan(~r/<w:t(?: [^>]*)?>([^<]*)<\/w:t>/, xml, capture: :all_but_first)
    |> Enum.map_join(&hd/1)
    |> String.replace(["&amp;", "&lt;", "&gt;", "&quot;", "&apos;"], fn
      "&amp;" -> "&"
      "&lt;" -> "<"
      "&gt;" -> ">"
      "&quot;" -> "\""
      "&apos;" -> "'"
    end)
  end

  test "every product in the store has a preview, except the Book 4 placeholder (#868), which has none" do
    all = Previews.all()
    for s <- slugs(), s != @placeholder, do: assert(Map.has_key?(all, s), s)
    refute Map.has_key?(all, @placeholder)
    assert length(slugs()) == 869
  end

  test "each preview uses the book's foreword, or its opening section when it has none" do
    expected = %{
      "armored-servicenow-itsm" => {"How to run it", "opening section"},
      "armored-servicenow-customer-service-management" => {"How to run it", "opening section"},
      "armored-servicenow-now-assist-skill-kit" => {"How to run it", "opening section"},
      "armored-genesys-cloud-cx" => {"How to run it", "opening section"},
      "armored-integration-whisper-warm-hot" => {"How to run it", "opening section"},
      "the-traveler-s-guide-nursing-state-and-owner-s-county" => {"A word before you go", "foreword"},
      "armored-accounting-for-decision-making" => {"Introduction", "foreword"}
    }

    for {slug, {section, kind}} <- expected do
      p = Previews.get(slug)
      assert p.section == section, slug
      assert p.kind == kind, slug
      assert p.paragraphs != [], slug
    end
  end

  # reads every book file (869 of them, most PDFs through PDFKit), so it needs more than the default minute
  @tag timeout: 600_000
  test "every preview paragraph is the exact text of the book's own file" do
    for {slug, p} <- Previews.all() do
      path = Path.join(@books, p.source)

      if File.exists?(path) do
        text = if String.ends_with?(path, ".pdf"), do: ArmoredStore.PdfText.text(path), else: docx_text(path)
        assert String.contains?(text, p.section), slug
        for para <- p.paragraphs, do: assert(String.contains?(text, para.text), "#{slug}: #{String.slice(para.text, 0, 60)}")
      end
    end
  end

  test "the preview names its source book file, which is not served" do
    for {_slug, p} <- Previews.all() do
      assert String.ends_with?(p.source, ".docx") or String.ends_with?(p.source, ".pdf")
      refute String.starts_with?(p.source, "priv/static")
    end
  end

  test "an unknown slug has no preview" do
    assert Previews.get("no-such-book") == nil
    assert Previews.get(nil) == nil
  end

  test "no email address in the previews" do
    refute Regex.match?(~r/[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}/, File.read!("priv/PREVIEWS.json"))
  end
end
