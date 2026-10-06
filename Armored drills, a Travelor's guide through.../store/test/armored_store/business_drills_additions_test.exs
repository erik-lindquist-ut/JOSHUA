defmodule ArmoredStore.BusinessDrillsAdditionsTest do
  @moduledoc """
  Products #8 to #13, the six Armored business drills, come from priv/STORE_ADDITIONS.json after #7, the same way
  #7 was added, so KDP_LISTINGS.json stays untouched. None is priced: each shows "Price not set". No course number
  appears in any title, slug, file name or listing text.
  """
  use ExUnit.Case, async: true
  alias ArmoredStore.Listings

  @books ".."
  @drills [
    {"armored-managing-organizations-and-leading-people", "Armored Managing Organizations and Leading People", "Managing Organizations and Leading People"},
    {"armored-business-acumen", "Armored Business Acumen", "Business Acumen"},
    {"armored-managing-human-capital", "Armored Managing Human Capital", "Managing Human Capital"},
    {"armored-becoming-an-effective-leader", "Armored Becoming an Effective Leader", "Becoming an Effective Leader"},
    {"armored-management-communication", "Armored Management Communication", "Management Communication"},
    {"armored-leading-teams", "Armored Leading Teams", "Leading Teams"}
  ]
  @course ~r/\b[Cc]\d{3}\b/

  defp kdp, do: "priv/KDP_LISTINGS.json" |> File.read!() |> Listings.products()
  defp adds, do: "priv/STORE_ADDITIONS.json" |> File.read!() |> Listings.additions(length(kdp()))
  defp raw_adds, do: "priv/STORE_ADDITIONS.json" |> File.read!() |> Jason.decode!()

  test "the additions file holds #7, then the six business drills, in order, at positions 7 to 12" do
    [seven | rest] = adds()
    six = Enum.take(rest, 6)
    assert seven["slug"] == "armored-accounting-for-decision-making"
    assert seven["position"] == 6
    assert length(six) == 6

    for {{slug, title, _}, {p, i}} <- Enum.zip(@drills, Enum.with_index(six, 7)) do
      assert p["slug"] == slug
      assert p["title"] == title
      assert p["position"] == i, slug
      assert p["author"] == "Joshua"
      assert p["series"] == nil
      assert p["edition"] == "V1"
      assert p["subtitle"] == "For people who already know the easy version."
      assert p["description"] =~ "12 disguised items, 4 of them transfer items, across eight concepts"
    end
  end

  test "#8 to #13 have no price: Price not set" do
    for p <- Enum.drop(adds(), 1) do
      assert p["cents"] == nil, p["slug"]
      assert p["price_source"] == nil, p["slug"]
    end

    refute Enum.any?(raw_adds(), &Map.has_key?(&1, "price_usd"))
  end

  test "the six listing products are unchanged: six titles at $0.99, none of the new drills among them" do
    assert length(kdp()) == 6
    assert Enum.all?(kdp(), &(&1["cents"] == 99))
    slugs = Enum.map(kdp(), & &1["slug"])
    for {slug, _, _} <- @drills, do: refute(slug in slugs)
  end

  test "each drill's book file is filed in its own (book, V1) folder in the drills folder, and its cover in a Cover folder" do
    entries = Enum.drop(raw_adds(), 1)

    for {{_, _, name}, e} <- Enum.zip(@drills, entries) do
      stem = "Armored_" <> String.replace(name, " ", "_")
      assert e["manuscript"] == "Armored #{name} (book, V1)/#{stem}.pdf"
      assert e["cover"] == "Cover — #{name}/#{stem}_cover.jpg"
      assert File.regular?(Path.join(@books, e["manuscript"])), e["manuscript"]
      assert File.regular?(Path.join(@books, e["cover"])), e["cover"]
      assert File.read!(Path.join(@books, e["manuscript"])) |> binary_part(0, 5) == "%PDF-"
    end
  end

  test "each drill's store cover is in priv/static/images/covers and is the same file as the one in its Cover folder" do
    # every book addition (the Book 4 placeholder, #868, has no book file or cover)
    for {e, p} <- Enum.zip(Enum.drop(raw_adds(), 1), Enum.drop(adds(), 1)), Map.has_key?(e, "manuscript") do
      store = "priv/static/images/covers/" <> p["cover"]
      assert File.regular?(store), store
      assert File.read!(store) == File.read!(Path.join(@books, e["cover"])), store
      assert File.read!(store) |> binary_part(0, 3) == <<0xFF, 0xD8, 0xFF>>
    end
  end

  test "no course number in any new title, slug, file name, folder name or listing text" do
    # every book addition (the Book 4 placeholder, #868, has no book file or cover)
    for {e, p} <- Enum.zip(Enum.drop(raw_adds(), 1), Enum.drop(adds(), 1)), Map.has_key?(e, "manuscript") do
      for v <- [p["title"], p["subtitle"], p["description"], p["cover"], e["manuscript"], e["cover"]],
          do: refute(v =~ @course, v)

      refute p["slug"] =~ ~r/(^|-)c\d{3}(-|$)/
    end
  end
end
