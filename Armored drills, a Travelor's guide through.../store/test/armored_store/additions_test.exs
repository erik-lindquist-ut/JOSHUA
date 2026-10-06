defmodule ArmoredStore.AdditionsTest do
  @moduledoc """
  Product #7 comes from priv/STORE_ADDITIONS.json, a small store-side data file, so Erik's
  KDP_LISTINGS.json stays untouched. Prices still come only from KDP_LISTINGS.json:
  anything in the additions file is shown as "Price not set".
  """
  use ExUnit.Case, async: true
  alias ArmoredStore.Listings

  @additions "priv/STORE_ADDITIONS.json"
  @listings "priv/KDP_LISTINGS.json"
  @slug "armored-accounting-for-decision-making"

  defp kdp, do: @listings |> File.read!() |> Listings.products()
  defp adds, do: @additions |> File.read!() |> Listings.additions(length(kdp()))

  test "the additions file starts with the Fail Fast Compendium, placed after the six listings" do
    assert [p | _] = adds()
    assert length(adds()) == 863
    assert p["title"] == "Armored Accounting for Decision Making: The Fail Fast Compendium"
    assert p["slug"] == @slug
    assert p["position"] == 6
    assert p["author"] == "Joshua"
    assert p["series"] == nil
    assert p["edition"] == "V1"
    assert p["subtitle"] == "For people who already know the easy version."
    assert p["description"] =~ "81 armored items"
  end

  test "#7 has no price: Price not set" do
    [p | _] = adds()
    assert p["cents"] == nil
    assert p["price_source"] == nil
  end

  test "a price in the additions file is never used; prices come only from KDP_LISTINGS.json" do
    for v <- [0.99, 5, "2.99"] do
      entry = %{"title" => "T", "author" => "A", "manuscript" => "x/T.docx", "price_usd" => v}
      assert [%{"cents" => nil, "price_source" => nil, "position" => 6}] = Listings.additions(Jason.encode!([entry]), 6), inspect(v)
    end
  end

  test "the six listing products are unchanged and do not include #7" do
    assert length(kdp()) == 6
    refute Enum.any?(kdp(), &(&1["slug"] == @slug))
    assert Enum.all?(kdp(), &(&1["cents"] == 99))
  end

  test "#7's cover is in priv/static/images/covers" do
    [p | _] = adds()
    assert p["cover"] == "Armored_Accounting_for_Decision_Making_cover.jpg"
    assert File.regular?("priv/static/images/covers/" <> p["cover"])
  end

  test "no course number in #7's title or slug" do
    [p | _] = adds()
    refute p["title"] =~ ~r/\bC\d{3}\b/
    refute p["slug"] =~ ~r/(^|-)c\d{3}(-|$)/
  end

  test "an additions file that is not a list is refused" do
    assert_raise MatchError, fn -> Listings.additions("{}", 6) end
  end
end
