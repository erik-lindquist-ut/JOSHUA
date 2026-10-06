defmodule ArmoredStore.CatalogAdditionsTest do
  use ArmoredStore.DataCase, async: true
  alias ArmoredStore.{Catalog, Listings}

  @listings "priv/KDP_LISTINGS.json"
  @additions "priv/STORE_ADDITIONS.json"
  @slug "armored-accounting-for-decision-making"

  test "seeding the store loads the six listings, then #7; safe to repeat" do
    Catalog.seed_store(@listings, @additions)
    Catalog.seed_store(@listings, @additions)
    ps = Catalog.list_products()
    assert length(ps) == 869

    six = Enum.take(ps, 6)
    assert Enum.map(six, & &1.slug) == @listings |> File.read!() |> Listings.products() |> Enum.map(& &1["slug"])
    assert Enum.all?(six, &(&1.cents == 99))

    seven = Enum.at(ps, 6)
    assert seven.slug == @slug
    assert seven.position == 6
    assert seven.cents == nil
    assert seven.price_source == nil
  end

  test "seed_store returns every product it loaded" do
    assert @listings |> Catalog.seed_store(@additions) |> Enum.map(& &1.slug) |> Enum.at(6) == @slug
  end
end
