defmodule LastTenYards.CheckoutTest do
  use ExUnit.Case, async: true
  alias LastTenYards.Checkout

  @p %{"id" => "ride-at-closing", "name" => "Ride at Closing", "stripe_price" => "price_123", "cents" => 2500}

  test "params ask Stripe for a one-time payment of exactly one item" do
    f = Checkout.params(@p, "https://lty.example")
    assert f["mode"] == "payment"
    assert f["line_items[0][price]"] == "price_123"
    assert f["line_items[0][quantity]"] == "1"
  end

  test "params send the buyer back to our own success and cancel pages" do
    f = Checkout.params(@p, "https://lty.example")
    assert f["success_url"] == "https://lty.example/store/thanks?session={CHECKOUT_SESSION_ID}"
    assert f["cancel_url"] == "https://lty.example/store"
  end

  test "params never carry the secret key" do
    f = Checkout.params(@p, "https://lty.example")
    refute Enum.any?(Map.values(f), &String.starts_with?(&1, "sk_"))
  end

  test "form encoding keeps Stripe's bracket keys" do
    body = Checkout.encode(%{"line_items[0][price]" => "price_1", "mode" => "payment"})
    assert body =~ "line_items%5B0%5D%5Bprice%5D=price_1"
    assert body =~ "mode=payment"
  end

  test "no secret key configured → :not_configured, no call made" do
    assert Checkout.create(@p, "https://x", nil, fn _ -> flunk("called") end) == {:error, :not_configured}
  end

  test "a product with no Stripe price cannot be sold" do
    assert Checkout.create(Map.delete(@p, "stripe_price"), "https://x", "sk_test_1", fn _ -> flunk("called") end) ==
             {:error, :no_price}
  end

  test "Stripe's answer: the checkout URL is returned" do
    post = fn req ->
      assert req.url == "https://api.stripe.com/v1/checkout/sessions"
      assert req.headers == [{"authorization", "Bearer sk_test_1"}, {"content-type", "application/x-www-form-urlencoded"}]
      {:ok, 200, ~s({"id":"cs_1","url":"https://checkout.stripe.com/c/pay/cs_1"})}
    end

    assert Checkout.create(@p, "https://x", "sk_test_1", post) == {:ok, "https://checkout.stripe.com/c/pay/cs_1"}
  end

  test "Stripe says no → the error comes back, nothing is charged" do
    post = fn _ -> {:ok, 400, ~s({"error":{"message":"No such price"}})} end
    assert Checkout.create(@p, "https://x", "sk_test_1", post) == {:error, "No such price"}
  end

  test "catalog: an empty product file is an empty store, not a crash" do
    assert Checkout.catalog("[]") == []
    assert Checkout.catalog("") == []
  end

  test "catalog: products are read in order, and find/2 finds by id" do
    list = Checkout.catalog(~s([{"id":"a","name":"A"},{"id":"b","name":"B"}]))
    assert Enum.map(list, & &1["id"]) == ["a", "b"]
    assert Checkout.find(list, "b")["name"] == "B"
    assert Checkout.find(list, "zzz") == nil
  end

  test "params tag the checkout with the product id, so the webhook can file the order" do
    assert Checkout.params(@p, "https://x")["metadata[product_id]"] == "ride-at-closing"
  end
end
