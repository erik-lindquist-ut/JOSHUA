defmodule ArmoredStore.ListingsTest do
  use ExUnit.Case, async: true
  alias ArmoredStore.Listings

  # priv/KDP_LISTINGS.json is a verbatim copy of Erik's listing data, so the app can ship without the parent folder.
  @copy "priv/KDP_LISTINGS.json"
  @original "../KDP listing sheet + JSON/KDP_LISTINGS.json"

  defp real, do: @copy |> File.read!() |> Listings.products()

  test "the listing data yields the five Armored books and the Traveler's Guide, in listing order" do
    assert Enum.map(real(), & &1["title"]) == [
             "Armored ServiceNow: ITSM",
             "Armored ServiceNow: Customer Service Management",
             "Armored ServiceNow: Now Assist Skill Kit",
             "Armored Genesys Cloud CX",
             "Armored Integration: Whisper, Warm, Hot",
             "The Traveler's Guide: Nursing State and Owner's County"
           ]
  end

  test "every price is the record's own price_usd, in cents, and says where it came from" do
    for {p, i} <- Enum.with_index(real()) do
      assert p["cents"] == 99
      assert p["price_source"] == "KDP_LISTINGS.json [#{i}] price_usd"
    end
  end

  test "author, subtitle and description come straight from the listing" do
    [itsm | _] = real()
    assert Enum.all?(real(), &(&1["author"] == "Joshua"))
    assert itsm["subtitle"] == "For people who already know the easy version."
    assert itsm["description"] =~ "26 disguised items across incident"
    assert itsm["series"] == "Joshua Says"
  end

  test "C213 is not in the listing data, so it is not a product" do
    refute Enum.any?(real(), &(&1["title"] =~ "C213"))
    refute Enum.any?(real(), &(&1["slug"] =~ "c213"))
  end

  test "no usable price in the record means no price, never a made-up one" do
    base = %{"title" => "T", "author" => "A", "manuscript" => "editions/T.docx"}

    for v <- [:missing, nil, "", 0, -1, "free"] do
      entry = if v == :missing, do: base, else: Map.put(base, "price_usd", v)
      a = Listings.to_attrs(entry, 3)
      assert a["cents"] == nil, inspect(v)
      assert a["price_source"] == nil, inspect(v)
    end
  end

  test "dollar prices convert to exact cents" do
    assert Listings.cents(0.99) == 99
    assert Listings.cents(2.99) == 299
    assert Listings.cents(5) == 500
  end

  test "slug comes from the manuscript file name; cover is the cover's file name" do
    [itsm | _] = real()
    assert itsm["slug"] == "armored-servicenow-itsm"
    assert itsm["cover"] == "Armored_ServiceNow_ITSM_cover.jpg"
    assert Listings.slug(%{"title" => "Hello: World"}) == "hello-world"
  end

  test "short description is whole sentences, about a line long" do
    text = "A blueprint and 19 items. Real-time whisper coaching, warm transfer to coaches, hot transfer to leadership. More."
    assert Listings.short(text) == "A blueprint and 19 items. Real-time whisper coaching, warm transfer to coaches, hot transfer to leadership."
    long = String.duplicate("word ", 30) <> "end. Second sentence."
    assert Listings.short(long) == String.duplicate("word ", 30) <> "end."
    assert Listings.short(nil) == ""
  end

  test "a listing file that is not a list is refused" do
    assert Listings.decode("{}") == {:error, :not_a_list}
    assert {:error, _} = Listings.decode("not json")
  end

  test "the app's copy is byte-identical to Erik's listing file" do
    if File.exists?(@original), do: assert(File.read!(@copy) == File.read!(@original))
  end

  test "every product's cover is in priv/static/images/covers" do
    for p <- real(), do: assert(File.regular?("priv/static/images/covers/" <> p["cover"]), p["cover"])
  end
end
