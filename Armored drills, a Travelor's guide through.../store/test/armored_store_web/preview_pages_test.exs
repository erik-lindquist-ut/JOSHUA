defmodule ArmoredStoreWeb.PreviewPagesTest do
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.{Catalog, Previews}

  @placeholder "armored-fail-fast-4-the-punch-list"

  setup do
    Catalog.seed_store("priv/KDP_LISTINGS.json", "priv/STORE_ADDITIONS.json")
    :ok
  end

  defp doc(conn, path), do: conn |> get(path) |> html_response(200) |> Floki.parse_document!()

  test "every card is one selectable link to its book's preview page", %{conn: conn} do
    d = doc(conn, "/books")
    ps = Catalog.list_products()
    assert length(ps) == 869

    for p <- ps do
      card = Floki.find(d, "#product-#{p.slug}")
      links = Floki.find(card, "a.card-link")
      assert length(links) == 1, p.slug
      assert Floki.attribute(links, "href") == ["/books/#{p.slug}"]
      # the whole card is inside the one link: cover, title, price and the preview cue
      # (the Book 4 placeholder, #868, has no cover and says "Coming soon" instead)
      assert Floki.text(links) =~ p.title
      assert Floki.text(links) =~ if(p.cents, do: "$0.99", else: "Price not set")

      if p.slug == @placeholder do
        assert Floki.find(links, "img") == [] and Floki.text(links) =~ "Coming soon"
        refute Floki.text(links) =~ "Read the preview"
      else
        assert Floki.find(links, "img") != [], p.slug
        assert Floki.text(links) =~ "Read the preview"
      end
    end
  end

  test "each preview page shows cover, title, price rule and the book's own preview text", %{conn: conn} do
    for p <- Catalog.list_products(), p.slug != @placeholder do
      d = doc(build_conn(), "/books/#{p.slug}")
      pv = Previews.get(p.slug)
      preview = Floki.find(d, "#preview")
      assert preview != [], p.slug
      text = Floki.text(preview)
      assert text =~ pv.section, p.slug
      # a table row (the Fail Fast book table) shows as its cells
      for para <- [hd(pv.paragraphs), List.last(pv.paragraphs)], t <- para.cells || [para.text], do: assert(text =~ t, p.slug)
      assert length(Floki.find(preview, "p, li, tr")) >= length(pv.paragraphs), p.slug
      assert Floki.attribute(d, "img.cover", "src") == ["/images/covers/" <> p.cover]
      assert Floki.text(d) =~ p.title

      if p.cents do
        assert Floki.find(d, "form button") |> Floki.text() =~ "Buy — $0.99"
      else
        assert Floki.text(d) =~ "Price not set"
        assert Floki.find(d, "form") == []
        assert Floki.find(d, "button") == []
      end
    end

    _ = conn
  end

  test "the Accounting for Decision Making preview is its Introduction, with Price not set and no buy button", %{conn: conn} do
    d = doc(conn, "/books/armored-accounting-for-decision-making")
    preview = d |> Floki.find("#preview") |> Floki.text()
    assert preview =~ "Introduction"
    assert preview =~ "This is a working book, built from one learner's real results in Accounting for Decision Making."
    assert preview =~ "That is why this book drills the disguise."
    assert Floki.text(d) =~ "Price not set"
    assert Floki.find(d, "button") == []
  end

  test "The Traveler's Guide preview is 'A word before you go'", %{conn: conn} do
    preview = conn |> doc("/books/the-traveler-s-guide-nursing-state-and-owner-s-county") |> Floki.find("#preview") |> Floki.text()
    assert preview =~ "A word before you go"
    assert preview =~ "Every guide begins with a confession from whoever wrote it"
  end

  test "an armored drill with no foreword previews its opening section, How to run it, as a numbered list", %{conn: conn} do
    d = doc(conn, "/books/armored-servicenow-itsm")
    preview = Floki.find(d, "#preview")
    assert Floki.text(preview) =~ "How to run it"
    assert length(Floki.find(preview, "ol li")) == 6
    assert Floki.text(preview) =~ "Read the target word first."
  end

  test "preview text is escaped, never raw HTML" do
    for {_slug, p} <- Previews.all(), para <- p.paragraphs, do: refute(para.text =~ "<script")
  end
end
