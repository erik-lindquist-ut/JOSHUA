defmodule ArmoredStoreWeb.BundleTest do
  @moduledoc """
  Every course product (#7 and the library drills #8-#864) is shown as one bundle: its drill plus the five shared
  Armored Fail Fast books. The Originals #1-#6 and the Fail Fast books themselves are not bundles. Nothing is priced.
  """
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.{Bundles, Catalog, Programs}

  @line "Bundle: this drill + the Armored Fail Fast set (5 books)"
  @fail_fast ~w(armored-fail-fast-1-the-pre-assessment armored-fail-fast-2-the-performance-assessment
                armored-fail-fast-3-the-objective-assessment armored-fail-fast-4-the-punch-list armored-fail-fast-5-the-adventure-guide)
  @ff_titles ["The Pre-Assessment", "The Performance Assessment", "The Objective Assessment", "Book 4: coming soon", "The Adventure Guide"]

  setup do
    Catalog.seed_store("priv/KDP_LISTINGS.json", "priv/STORE_ADDITIONS.json")
    :ok
  end

  defp doc(path), do: build_conn() |> get(path) |> html_response(200) |> Floki.parse_document!()
  defp split do
    ps = Catalog.list_products()
    {Enum.take(ps, 6), Enum.slice(ps, 6, 858), Enum.slice(ps, 864, 5)}
  end

  test "858 course bundles: #7 and #8-#864; not #1-#6 and not the five Fail Fast books" do
    {originals, courses, ff} = split()
    assert length(courses) == 858 and hd(courses).slug == "armored-accounting-for-decision-making"
    assert Enum.all?(courses, &Bundles.bundle?/1)
    refute Enum.any?(originals ++ ff, &Bundles.bundle?/1)
    assert Enum.map(ff, & &1.slug) == @fail_fast
    assert Enum.map(Bundles.shared_books(), & &1.slug) == @fail_fast
    assert Bundles.line() == @line
  end

  test "every card on All books shows the bundle line for a course, and not for #1-#6 or the Fail Fast books" do
    {originals, courses, ff} = split()
    d = doc("/books")

    for p <- courses do
      card = Floki.find(d, "#product-" <> p.slug)
      assert Floki.find(card, ".bundle-line") |> Floki.text() == @line, p.slug
      assert Floki.text(card) =~ "Price not set"
      assert length(Floki.find(card, "a")) == 1
    end

    for p <- originals ++ ff, do: assert(Floki.find(d, "#product-#{p.slug} .bundle-line") == [], p.slug)
  end

  test "program-page and home cards carry the same rule" do
    p = Programs.get("bs-accounting")
    d = doc("/programs/bs-accounting")
    lines = Floki.find(d, "li.card .bundle-line")
    assert length(lines) == length(Programs.books(p))

    home = doc("/")
    assert Floki.find(home, "#fail-fast .bundle-line") == []
    # of the Originals on the home page, only #7 (a course) is a bundle
    assert Floki.find(home, "#originals li.card") |> Enum.filter(&(Floki.find(&1, ".bundle-line") != [])) |> Enum.flat_map(&Floki.attribute(&1, "id")) ==
             ["product-armored-accounting-for-decision-making"]
  end

  test "every course page shows the bundle with the five Fail Fast titles linked to their pages, 'Price not set', no buy button" do
    {_, courses, _} = split()

    for p <- courses do
      d = doc("/books/" <> p.slug)
      b = Floki.find(d, "#bundle")
      assert Floki.find(b, ".bundle-line") |> Floki.text() == @line, p.slug
      assert Floki.attribute(b, "a", "href") == Enum.map(@fail_fast, &("/books/" <> &1)), p.slug
      assert Floki.find(b, "a") |> Enum.map(&Floki.text/1) == @ff_titles
      assert Floki.text(d) =~ "Price not set"
      assert Floki.find(d, "form") == [] and Floki.find(d, "button") == []
    end
  end

  test "no bundle on #1-#6 or on the Fail Fast books' own pages" do
    {originals, _, ff} = split()
    for p <- originals ++ ff, do: assert(Floki.find(doc("/books/" <> p.slug), "#bundle, .bundle-line") == [], p.slug)
  end

  test "the Fail Fast PDFs are not copied into any course folder" do
    ff_files = ~w(Armored_Fail_Fast_1_The_Pre-Assessment.pdf Armored_Fail_Fast_2_The_Performance_Assessment.pdf Armored_Fail_Fast_3_The_Objective_Assessment.pdf
                  Armored_Fail_Fast_5_The_Adventure_Guide.pdf)
    # Book 4 is a placeholder (#868) with no book file; its old PDF is in ../_removed_2026-09-29_punch_list/
    hits = for f <- ff_files, path <- Path.wildcard("../*/" <> f), do: path
    assert length(hits) == 4
    assert Path.wildcard("../*/Armored_Fail_Fast_4_*.pdf") == []
    assert Enum.all?(hits, &String.starts_with?(&1, "../Armored Fail Fast - "))
    refute Enum.any?(Path.wildcard("../*/*Fail Fast [1-5]*.pdf"))
  end
end
