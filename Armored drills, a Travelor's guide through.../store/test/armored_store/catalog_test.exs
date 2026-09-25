defmodule ArmoredStore.CatalogTest do
  use ArmoredStore.DataCase, async: true
  alias ArmoredStore.Catalog

  @listings "priv/KDP_LISTINGS.json"

  test "seeding from the listing data stores six products in listing order, and is safe to repeat" do
    Catalog.seed_from_listings(@listings)
    Catalog.seed_from_listings(@listings)
    products = Catalog.list_products()
    assert length(products) == 6
    assert hd(products).slug == "armored-servicenow-itsm"
    assert List.last(products).slug == "the-traveler-s-guide-nursing-state-and-owner-s-county"
    assert Enum.all?(products, &(&1.cents == 99))
  end

  test "a product with no price can be stored, with no price" do
    assert {:ok, p} = Catalog.upsert_product(%{"slug" => "no-price", "title" => "No Price", "author" => "Joshua", "cents" => nil})
    assert p.cents == nil
  end

  test "a price, when present, must be positive" do
    assert {:error, cs} = Catalog.upsert_product(%{"slug" => "zero", "title" => "Zero", "author" => "Joshua", "cents" => 0})
    assert cs.errors[:cents]
  end

  test "get_product finds active products by slug only" do
    Catalog.seed_from_listings(@listings)
    assert Catalog.get_product("armored-genesys-cloud-cx").title == "Armored Genesys Cloud CX"
    assert Catalog.get_product("nope") == nil
    assert Catalog.get_product(nil) == nil
    {:ok, _} = Catalog.upsert_product(%{"slug" => "armored-genesys-cloud-cx", "title" => "Armored Genesys Cloud CX", "author" => "Joshua", "active" => false})
    assert Catalog.get_product("armored-genesys-cloud-cx") == nil
    assert length(Catalog.list_products()) == 5
  end

  test "a paid order is recorded once even if Stripe repeats the event; a refund marks it" do
    Catalog.seed_from_listings(@listings)
    attrs = %{"stripe_session_id" => "cs_x", "product_id" => "armored-servicenow-itsm", "amount_cents" => 99, "currency" => "usd", "payment_intent" => "pi_x", "status" => "paid"}
    {:ok, _} = Catalog.record_paid(attrs)
    {:ok, _} = Catalog.record_paid(attrs)
    assert Catalog.paid_total_cents() == 99
    assert {:ok, o} = Catalog.record_refund(%{"payment_intent" => "pi_x"})
    assert o.status == "refunded"
    assert Catalog.paid_total_cents() == 0
    assert Catalog.record_refund(%{"payment_intent" => "pi_none"}) == {:error, :not_found}
  end
end
