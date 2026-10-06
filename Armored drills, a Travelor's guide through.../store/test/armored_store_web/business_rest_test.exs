defmodule ArmoredStoreWeb.BusinessRestTest do
  @moduledoc """
  Products #14 on: the rest of the Armored business drills, added through priv/STORE_ADDITIONS.json after #13 the
  same way as #8 to #13. Data-driven over every addition from #14. None is priced; each previews its opening section,
  "How to run it", from its own PDF; no course number appears in any name, slug, listing or preview.
  """
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.{Catalog, Listings, Previews}

  @books ".."
  @total 869
  # a course number: C200, D072, E054 or AFT2-style, alone or inside a slug or file name
  # CYP450, the enzyme family named in two Health books' concept lists, is not a course number
  @course ~r/(^|[^A-Za-z0-9])(?!CYP450(?![A-Za-z0-9]))([A-Za-z]{1,3}\d{3}|[A-Za-z]{3}\d)([^A-Za-z0-9]|$)/

  defp kdp, do: "priv/KDP_LISTINGS.json" |> File.read!() |> Listings.products()
  defp adds, do: "priv/STORE_ADDITIONS.json" |> File.read!() |> Listings.additions(length(kdp()))
  defp rest, do: adds() |> Enum.drop(7) |> Enum.take(189)
  defp raw_rest, do: "priv/STORE_ADDITIONS.json" |> File.read!() |> Jason.decode!() |> Enum.drop(7) |> Enum.take(189)
  defp doc(conn, path), do: conn |> get(path) |> html_response(200) |> Floki.parse_document!()
  # what a reader sees or follows: the page text (text nodes kept apart, so "V1" and "12 items" never run together),
  # link targets, image sources and alt text
  defp visible(d), do: Enum.join([Floki.text(d, sep: " ") | Floki.attribute(d, "href") ++ Floki.attribute(d, "src") ++ Floki.attribute(d, "alt")], "\n")

  setup do
    Catalog.seed_store("priv/KDP_LISTINGS.json", "priv/STORE_ADDITIONS.json")
    :ok
  end

  test "189 more titles follow #13, at positions 13 to 201, in the series shape, with no price" do
    assert length(rest()) == 189
    assert length(kdp()) + length(adds()) == @total

    for {p, i} <- Enum.with_index(rest(), 13) do
      assert p["position"] == i, p["slug"]
      assert String.starts_with?(p["title"], "Armored "), p["title"]
      assert p["subtitle"] == "For people who already know the easy version."
      assert {p["author"], p["series"], p["edition"]} == {"Joshua", nil, "V1"}
      assert p["description"] =~ ~r/^\d+ disguised items, \d+ of them transfer items, across \w+ concepts: /, p["slug"]
      assert p["cents"] == nil and p["price_source"] == nil, p["slug"]
    end

    refute Enum.any?(raw_rest(), &Map.has_key?(&1, "price_usd"))
  end

  test "Accounting for Decision Makers is its own product; #7, the compendium, is unchanged" do
    p = Enum.find(rest(), &(&1["slug"] == "armored-accounting-for-decision-makers"))
    assert p["title"] == "Armored Accounting for Decision Makers"
    assert Enum.at(adds(), 0)["slug"] == "armored-accounting-for-decision-making"
    assert Enum.at(adds(), 0)["title"] == "Armored Accounting for Decision Making: The Fail Fast Compendium"
  end

  test "every slug in the store is unique" do
    slugs = Enum.map(kdp() ++ adds(), & &1["slug"])
    assert length(Enum.uniq(slugs)) == @total
  end

  test "each book file is filed in its own (book, V1) folder, its cover in a Cover folder and in the store's covers" do
    for {e, p} <- Enum.zip(raw_rest(), rest()) do
      [dir, file] = String.split(e["manuscript"], "/")
      assert dir =~ ~r/^Armored .+ \(book, V1\)$/, dir
      assert file =~ ~r/^Armored_[A-Za-z0-9_]+\.pdf$/, file
      assert e["cover"] =~ ~r/^Cover — .+\/Armored_[A-Za-z0-9_]+_cover\.jpg$/, e["cover"]
      refute e["manuscript"] =~ ":", e["manuscript"]
      refute e["cover"] =~ ":", e["cover"]
      assert File.read!(Path.join(@books, e["manuscript"])) |> binary_part(0, 5) == "%PDF-", e["manuscript"]
      store = "priv/static/images/covers/" <> p["cover"]
      assert File.read!(store) == File.read!(Path.join(@books, e["cover"])), store
      assert File.read!(Path.join(@books, dir <> "/README.md")) =~ "store product #"
    end
  end

  test "titles with a colon keep it in the store title and use ' - ' in folder names" do
    colon = Enum.filter(raw_rest(), &(&1["title"] =~ ":"))
    assert length(colon) == 10

    for e <- colon do
      name = e["title"] |> String.replace_prefix("Armored ", "") |> String.replace(": ", " - ")
      assert e["manuscript"] |> String.starts_with?("Armored #{name} (book, V1)/"), e["manuscript"]
      assert e["cover"] |> String.starts_with?("Cover — #{name}/"), e["cover"]
    end
  end

  test "each previews its opening section, How to run it, from its own PDF" do
    for p <- rest() do
      pv = Previews.get(p["slug"])
      assert pv, p["slug"]
      assert {pv.section, pv.kind} == {"How to run it", "opening section"}, p["slug"]
      assert Enum.map(pv.paragraphs, & &1.kind) == ["p"] ++ List.duplicate("li", 8) ++ ["p", "p"], p["slug"]
      assert String.ends_with?(pv.source, ".pdf") and File.regular?(Path.join(@books, pv.source)), pv.source
    end
  end

  test "no course number in any new name, slug, file name, listing or preview" do
    for {e, p} <- Enum.zip(raw_rest(), rest()) do
      for v <- [p["title"], p["subtitle"], p["description"], p["slug"], p["cover"], e["manuscript"], e["cover"]],
          do: refute(v =~ @course, v)

      pv = Previews.get(p["slug"])
      for t <- [pv.section, pv.source | Enum.map(pv.paragraphs, & &1.text)], do: refute(t =~ @course, "#{p["slug"]}: #{t}")
    end
  end

  test "the catalog shows every title; each new card links to its page with its cover and 'Price not set'", %{conn: conn} do
    d = doc(conn, "/books")
    assert length(Floki.find(d, "li.card")) == @total
    refute visible(d) =~ @course, inspect(Regex.run(@course, visible(d)))

    for p <- rest() do
      card = Floki.find(d, "#product-" <> p["slug"])
      assert Floki.attribute(card, "a.card-link", "href") == ["/books/" <> p["slug"]]
      assert Floki.attribute(card, "img", "src") == ["/images/covers/" <> p["cover"]]
      assert Floki.text(card) =~ "Price not set"
      refute Floki.text(card) =~ "$"
    end
  end

  test "each new page shows its title, no buy button, and How to run it as eight numbered steps" do
    for p <- rest() do
      d = doc(build_conn(), "/books/" <> p["slug"])
      assert Floki.find(d, "h1") |> Floki.text() == p["title"]
      assert Floki.text(d) =~ "Price not set"
      assert Floki.find(d, "form") == [] and Floki.find(d, "button") == []
      preview = Floki.find(d, "#preview")
      assert Floki.text(preview) =~ "How to run it"
      assert length(Floki.find(preview, "ol li")) == 8, p["slug"]
      refute visible(d) =~ @course, "#{p["slug"]}: #{inspect(Regex.run(@course, visible(d)))}"
    end
  end
end
