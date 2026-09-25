defmodule ArmoredStore.CheckoutTest do
  use ExUnit.Case, async: true
  alias ArmoredStore.Checkout

  @p %{slug: "armored-servicenow-itsm", title: "Armored ServiceNow: ITSM", cents: 99}

  test "params ask Stripe for a one-time payment of one item at the listing price" do
    f = Checkout.params(@p, "https://store.example")
    assert f["mode"] == "payment"
    assert f["line_items[0][quantity]"] == "1"
    assert f["line_items[0][price_data][currency]"] == "usd"
    assert f["line_items[0][price_data][unit_amount]"] == "99"
    assert f["line_items[0][price_data][product_data][name]"] == "Armored ServiceNow: ITSM"
  end

  test "params send the buyer back to our own thanks and product pages" do
    f = Checkout.params(@p, "https://store.example")
    assert f["success_url"] == "https://store.example/thanks?session_id={CHECKOUT_SESSION_ID}"
    assert f["cancel_url"] == "https://store.example/books/armored-servicenow-itsm"
  end

  test "params tag the checkout with the product slug, so the webhook can file the order" do
    assert Checkout.params(@p, "https://x")["metadata[product_id]"] == "armored-servicenow-itsm"
  end

  test "params never carry the secret key" do
    f = Checkout.params(@p, "https://x")
    refute Enum.any?(Map.values(f), &String.starts_with?(&1, "sk_"))
  end

  test "form encoding keeps Stripe's bracket keys" do
    body = Checkout.encode(%{"line_items[0][quantity]" => "1", "mode" => "payment"})
    assert body =~ "line_items%5B0%5D%5Bquantity%5D=1"
    assert body =~ "mode=payment"
  end

  test "no secret key (unset or blank) → :not_configured, no call made" do
    assert Checkout.create(@p, "https://x", nil, fn _ -> flunk("called") end) == {:error, :not_configured}
    assert Checkout.create(@p, "https://x", "", fn _ -> flunk("called") end) == {:error, :not_configured}
  end

  test "a product with no price cannot be sold, and Stripe is not called" do
    assert Checkout.create(%{@p | cents: nil}, "https://x", "sk_test_1", fn _ -> flunk("called") end) == {:error, :no_price}
  end

  test "Stripe's answer: the hosted checkout URL is returned" do
    post = fn req ->
      assert req.url == "https://api.stripe.com/v1/checkout/sessions"
      assert req.headers == [{"authorization", "Bearer sk_test_1"}, {"content-type", "application/x-www-form-urlencoded"}]
      assert req.body =~ "unit_amount%5D=99"
      {:ok, 200, ~s({"id":"cs_1","url":"https://checkout.stripe.com/c/pay/cs_1"})}
    end

    assert Checkout.create(@p, "https://x", "sk_test_1", post) == {:ok, "https://checkout.stripe.com/c/pay/cs_1"}
  end

  test "Stripe says no → the error comes back, nothing is charged" do
    post = fn _ -> {:ok, 400, ~s({"error":{"message":"Invalid API Key"}})} end
    assert Checkout.create(@p, "https://x", "sk_test_1", post) == {:error, "Invalid API Key"}
  end

  test "a network failure comes back as an error" do
    assert Checkout.create(@p, "https://x", "sk_test_1", fn _ -> {:error, :timeout} end) == {:error, :timeout}
  end

  test "in tests the configured HTTP call refuses to reach Stripe" do
    assert Application.get_env(:armored_store, :stripe_post) == {ArmoredStore.Checkout, :offline_post}
    assert Checkout.offline_post(%{url: "https://api.stripe.com"}) == {:error, :offline}
  end
end
