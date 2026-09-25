defmodule LastTenYards.StoreTest do
  use LastTenYards.DataCase, async: true
  alias LastTenYards.Store

  @p %{"slug" => "ride-at-closing", "name" => "Ride at Closing", "cents" => 2500, "stripe_price" => "price_1", "line" => "tesla-rideshare"}

  setup do
    {:ok, _} = Store.upsert_line(%{"slug" => "tesla-rideshare", "name" => "Tesla Rideshare"})
    {:ok, _} = Store.upsert_line(%{"slug" => "pharmadash", "name" => "Pharmadash"})
    :ok
  end
  @paid %{"stripe_session_id" => "cs_1", "payment_intent" => "pi_1", "amount_cents" => 2500, "currency" => "usd",
          "status" => "paid", "product_id" => "ride-at-closing"}

  test "empty database → empty store" do
    assert Store.list_products() == []
  end

  test "a product saves and lists in the shape the pages use" do
    {:ok, _} = Store.upsert_product(@p)
    assert [%{"id" => "ride-at-closing", "cents" => 2500, "stripe_price" => "price_1"}] = Store.list_products()
  end

  test "upsert by slug updates, never duplicates" do
    {:ok, _} = Store.upsert_product(@p)
    {:ok, _} = Store.upsert_product(%{@p | "cents" => 3000})
    assert [%{"cents" => 3000}] = Store.list_products()
  end

  test "bad products are refused by the same rules" do
    assert {:error, cs} = Store.upsert_product(%{@p | "stripe_price" => "sk_live_x"})
    assert cs.errors[:stripe_price]
  end

  test "inactive products are hidden" do
    {:ok, _} = Store.upsert_product(Map.put(@p, "active", false))
    assert Store.list_products() == []
  end

  test "a paid order links to its product; a resend makes no second order" do
    {:ok, _} = Store.upsert_product(@p)
    {:ok, o} = Store.record_paid(@paid)
    assert o.product_id
    {:ok, _} = Store.record_paid(@paid)
    assert Repo.aggregate(LastTenYards.Store.Order, :count) == 1
    assert Store.paid_total_cents() == 2500
  end

  test "a refund flips the order and drops it from the paid total" do
    {:ok, _} = Store.upsert_product(@p)
    {:ok, _} = Store.record_paid(@paid)
    {:ok, o} = Store.record_refund(%{"payment_intent" => "pi_1"})
    assert o.status == "refunded"
    assert Store.paid_total_cents() == 0
  end

  test "a refund for an unknown payment is not found" do
    assert Store.record_refund(%{"payment_intent" => "pi_nope"}) == {:error, :not_found}
  end

  test "each line is its own storefront on the same database" do
    {:ok, _} = Store.upsert_product(@p)
    {:ok, _} = Store.upsert_product(%{@p | "slug" => "first-refill", "line" => "pharmadash"})
    assert [%{"id" => "ride-at-closing"}] = Store.list_products("tesla-rideshare")
    assert [%{"id" => "first-refill"}] = Store.list_products("pharmadash")
    assert length(Store.list_products()) == 2
  end

  test "a product with no line is refused" do
    assert {:error, cs} = Store.upsert_product(Map.delete(@p, "line"))
    assert cs.errors[:business_line_id]
  end

  test "the lines file seeds every line" do
    lines = LastTenYards.Checkout.catalog(File.read!("priv/lines.json"))
    Enum.each(lines, &({:ok, _} = Store.upsert_line(&1)))
    assert length(Store.list_lines()) == length(lines)
  end
end
