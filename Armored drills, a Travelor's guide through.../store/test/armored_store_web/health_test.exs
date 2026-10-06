defmodule ArmoredStoreWeb.HealthTest do
  @moduledoc """
  Products #402 on: the Health shelf of the Armored drills, added through priv/STORE_ADDITIONS.json after the
  Technology drills, the same way. Data-driven over every Health addition. None is priced; each previews its
  opening section, "How to run it", from its own PDF. Titles that repeat (inside Health, or a Business title) carry
  a short subtitle from the book's own text; no course number appears in any name, slug, listing or preview; every
  slug and folder name is unique across the whole store.
  """
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.{Catalog, Listings, Previews}

  @books ".."
  @total 869
  # a course number (C200, D072, AFT2 style); CYP450, the enzyme family named in two books' concept lists, is not one
  @course ~r/(^|[^A-Za-z0-9])(?!CYP450(?![A-Za-z0-9]))([A-Za-z]{1,3}\d{3}|[A-Za-z]{3}\d)([^A-Za-z0-9]|$)/
  @subtitled %{
    "Consumer Behavior" => ["Cognitive Dissonance"],
    "Emerging Professional Practice" => ["Advance Directives", "Forensic Nursing"],
    "Environmental Health" => ["Drinking Water Treatment", "Risk Assessment"],
    "Global Health" => ["Demographic Transition", "International Health Regulations"],
    "Global and Population Health" => ["Levels of Prevention", "Value-Based Care"],
    "Pathophysiology" => ["Cellular Adaptation", "For Nursing Students"],
    "Public Health Leadership and Administration" => ["Leading Change", "Negotiation"]
  }

  defp kdp, do: "priv/KDP_LISTINGS.json" |> File.read!() |> Listings.products()
  defp adds, do: "priv/STORE_ADDITIONS.json" |> File.read!() |> Listings.additions(length(kdp()))
  defp raw_adds, do: "priv/STORE_ADDITIONS.json" |> File.read!() |> Jason.decode!()
  defp health, do: adds() |> Enum.drop(395) |> Enum.take(177)
  defp raw_health, do: raw_adds() |> Enum.drop(395) |> Enum.take(177)
  defp doc(conn, path), do: conn |> get(path) |> html_response(200) |> Floki.parse_document!()
  defp visible(d), do: Enum.join([Floki.text(d, sep: " ") | Floki.attribute(d, "href") ++ Floki.attribute(d, "src") ++ Floki.attribute(d, "alt")], "\n")

  setup do
    Catalog.seed_store("priv/KDP_LISTINGS.json", "priv/STORE_ADDITIONS.json")
    :ok
  end

  test "177 Health titles follow the Technology drills, at positions 401 to 577, in the series shape, with no price" do
    assert length(health()) == 177
    assert length(kdp()) + length(adds()) == @total

    for {p, i} <- Enum.with_index(health(), 401) do
      assert p["position"] == i, p["slug"]
      assert String.starts_with?(p["title"], "Armored "), p["title"]
      assert p["subtitle"] == "For people who already know the easy version."
      assert {p["author"], p["series"], p["edition"]} == {"Joshua", nil, "V1"}
      assert p["description"] =~ ~r/^\d+ disguised items, \d+ of them transfer items, across \w+ concepts: /, p["slug"]
      assert p["cents"] == nil and p["price_source"] == nil, p["slug"]
    end

    refute Enum.any?(raw_health(), &Map.has_key?(&1, "price_usd"))
  end

  test "every slug, title, book folder and cover folder is unique across the whole store" do
    all = kdp() ++ adds()
    assert length(all) == @total
    assert all |> Enum.map(& &1["slug"]) |> Enum.uniq() |> length() == @total
    assert all |> Enum.map(&String.downcase(&1["title"])) |> Enum.uniq() |> length() == @total

    # every book addition (the Book 4 placeholder, #868, has no book or cover folder)
    books = Enum.filter(raw_adds(), &Map.has_key?(&1, "manuscript"))
    dirs = fn key -> books |> Enum.map(&(&1[key] |> String.split("/") |> hd() |> String.downcase())) end
    assert dirs.("manuscript") |> Enum.uniq() |> length() == length(books)
    assert dirs.("cover") |> Enum.uniq() |> length() == length(books)
  end

  test "repeated titles carry a short subtitle from the book's own text; the Business titles keep theirs" do
    for {base, subs} <- @subtitled do
      got = for p <- health(), String.starts_with?(p["title"], "Armored #{base} - "), do: String.replace_prefix(p["title"], "Armored #{base} - ", "")
      assert Enum.sort(got) == subs, base
      refute Enum.any?(health(), &(&1["title"] == "Armored #{base}")), base
      for s <- subs, do: refute(s =~ ~r/\bv(ersion)?\s*\d/i, s)
    end

    business = adds() |> Enum.take(196) |> Enum.map(& &1["title"])
    assert "Armored Consumer Behavior" in business
  end

  test "each book file is filed in its own (book, V1) folder, its cover in a Cover folder and in the store's covers" do
    for {e, p} <- Enum.zip(raw_health(), health()) do
      [dir, file] = String.split(e["manuscript"], "/")
      assert dir =~ ~r/^Armored .+ \(book, V1\)$/, dir
      assert file =~ ~r/^Armored_[A-Za-z0-9_]+\.pdf$/, file
      assert e["cover"] =~ ~r/^Cover — [^\/:]+\/Armored_[A-Za-z0-9_]+_cover\.jpg$/, e["cover"]
      refute dir =~ ":", dir
      assert File.read!(Path.join(@books, e["manuscript"])) |> binary_part(0, 5) == "%PDF-", e["manuscript"]
      store = "priv/static/images/covers/" <> p["cover"]
      assert File.read!(store) == File.read!(Path.join(@books, e["cover"])), store
      assert File.read!(Path.join(@books, dir <> "/README.md")) =~ "store product ##{p["position"] + 1}"
    end
  end

  test "titles with a colon or slash keep it in the store title and use a safe substitute in folder names" do
    unsafe = Enum.filter(raw_health(), &(&1["title"] =~ ~r/[:\/]/))
    assert Enum.map(unsafe, & &1["title"]) |> Enum.sort() ==
             ["Armored Microbiology with Lab: A Fundamental Approach", "Armored Professional Practice Experience II: Management"]

    for e <- unsafe do
      name = e["title"] |> String.replace_prefix("Armored ", "") |> String.replace(": ", " - ") |> String.replace("/", "-")
      assert String.starts_with?(e["manuscript"], "Armored #{name} (book, V1)/"), e["manuscript"]
      assert String.starts_with?(e["cover"], "Cover — #{name}/"), e["cover"]
    end
  end

  test "each previews its opening section, How to run it, from its own PDF" do
    for p <- health() do
      pv = Previews.get(p["slug"])
      assert pv, p["slug"]
      assert {pv.section, pv.kind} == {"How to run it", "opening section"}, p["slug"]
      assert Enum.map(pv.paragraphs, & &1.kind) == ["p"] ++ List.duplicate("li", 8) ++ ["p", "p"], p["slug"]
      assert String.ends_with?(pv.source, ".pdf") and File.regular?(Path.join(@books, pv.source)), pv.source
    end
  end

  test "no course number in any Health name, slug, file name, listing or preview" do
    for {e, p} <- Enum.zip(raw_health(), health()) do
      for v <- [p["title"], p["subtitle"], p["description"], p["slug"], p["cover"], e["manuscript"], e["cover"]],
          do: refute(v =~ @course, v)

      pv = Previews.get(p["slug"])
      for t <- [pv.section, pv.source | Enum.map(pv.paragraphs, & &1.text)], do: refute(t =~ @course, "#{p["slug"]}: #{t}")
    end
  end

  test "the catalog shows every title; each Health card links to its page with its cover and 'Price not set'", %{conn: conn} do
    d = doc(conn, "/books")
    assert length(Floki.find(d, "li.card")) == @total
    refute visible(d) =~ @course, inspect(Regex.run(@course, visible(d)))

    for p <- health() do
      card = Floki.find(d, "#product-" <> p["slug"])
      assert Floki.attribute(card, "a.card-link", "href") == ["/books/" <> p["slug"]]
      assert Floki.attribute(card, "img", "src") == ["/images/covers/" <> p["cover"]]
      assert Floki.text(card) =~ "Price not set"
      refute Floki.text(card) =~ "$"
    end
  end

  test "each Health page shows its title, no buy button, and How to run it as eight numbered steps" do
    for p <- health() do
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
