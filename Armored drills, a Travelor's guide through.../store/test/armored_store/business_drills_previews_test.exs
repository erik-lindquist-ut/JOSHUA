defmodule ArmoredStore.BusinessDrillsPreviewsTest do
  @moduledoc """
  The six Armored business drills have no foreword, so each previews its opening section, "How to run it", copied
  exactly from the book's own PDF by tools/extract_previews.py.
  """
  use ExUnit.Case, async: true
  alias ArmoredStore.{PdfText, Previews}

  @books ".."
  @slugs ~w(armored-managing-organizations-and-leading-people armored-business-acumen armored-managing-human-capital
            armored-becoming-an-effective-leader armored-management-communication armored-leading-teams)

  test "each business drill previews its opening section, How to run it: a lead line, eight numbered steps, the strip" do
    for slug <- @slugs do
      p = Previews.get(slug)
      assert p, slug
      assert p.section == "How to run it", slug
      assert p.kind == "opening section", slug
      assert Enum.map(p.paragraphs, & &1.kind) == ["p"] ++ List.duplicate("li", 8) ++ ["p", "p"], slug
      assert hd(p.paragraphs).text == "Paper first. Pencil. One pass, no notes, a timer if you want the pressure."
      assert Enum.at(p.paragraphs, 8).text =~ "The biggest tally is what you drill next."
      assert [{:para, _}, {:list, steps}, {:para, _}, {:para, _}] = Previews.blocks(p)
      assert length(steps) == 8
    end
  end

  test "each preview names its own PDF in its own (book, V1) folder" do
    for slug <- @slugs do
      p = Previews.get(slug)
      assert String.ends_with?(p.source, ".pdf"), slug
      assert p.source =~ ~r/^Armored [^\/]+ \(book, V1\)\/Armored_[A-Za-z_]+\.pdf$/, slug
      assert File.regular?(Path.join(@books, p.source)), p.source
    end
  end

  test "every paragraph of each preview is the exact text of the book's own PDF" do
    assert PdfText.available?()

    for slug <- @slugs do
      p = Previews.get(slug)
      text = PdfText.text(Path.join(@books, p.source))
      assert String.contains?(text, p.section), slug
      for para <- p.paragraphs, do: assert(String.contains?(text, para.text), "#{slug}: #{String.slice(para.text, 0, 60)}")
    end
  end

  test "no running footer, page number or course number in any business drill preview" do
    for slug <- @slugs, para <- Previews.get(slug).paragraphs do
      refute para.text =~ ~r/\bC\d{3}\b/, slug
      refute para.text =~ "Armored Drill", slug
      refute para.text =~ "·", slug
    end
  end
end
