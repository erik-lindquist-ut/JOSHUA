defmodule ArmoredStoreWeb.CheckoutFlowTest do
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.Catalog

  defmodule FakeStripe do
    def ok(req) do
      send(:checkout_flow_test, {:stripe_called, req})
      {:ok, 200, ~s({"id":"cs_test_9","url":"https://checkout.stripe.com/c/pay/cs_test_9"})}
    end

    def refuse(req) do
      send(:checkout_flow_test, {:stripe_called, req})
      {:ok, 401, ~s({"error":{"message":"Invalid API Key provided"}})}
    end
  end

  setup do
    Process.register(self(), :checkout_flow_test)
    old_key = System.get_env("STRIPE_SECRET_KEY")
    old_post = Application.get_env(:armored_store, :stripe_post)
    System.delete_env("STRIPE_SECRET_KEY")

    on_exit(fn ->
      if old_key, do: System.put_env("STRIPE_SECRET_KEY", old_key), else: System.delete_env("STRIPE_SECRET_KEY")
      Application.put_env(:armored_store, :stripe_post, old_post)
    end)

    Catalog.seed_from_listings("priv/KDP_LISTINGS.json")
    :ok
  end

  test "with no Stripe key, Buy shows a clear 'checkout not configured' message, not an error", %{conn: conn} do
    Application.put_env(:armored_store, :stripe_post, {FakeStripe, :ok})
    html = conn |> post("/checkout/armored-servicenow-itsm") |> html_response(200)
    assert html =~ "Checkout not configured"
    assert html =~ "No payment was taken."
    refute_received {:stripe_called, _}
  end

  test "with a key, Buy sends the buyer to Stripe's hosted checkout at the listing price", %{conn: conn} do
    System.put_env("STRIPE_SECRET_KEY", "sk_test_fake_for_tests")
    Application.put_env(:armored_store, :stripe_post, {FakeStripe, :ok})
    c = post(conn, "/checkout/armored-genesys-cloud-cx")
    assert redirected_to(c, 302) == "https://checkout.stripe.com/c/pay/cs_test_9"
    assert_received {:stripe_called, req}
    assert req.body =~ "unit_amount%5D=99"
    assert req.body =~ "armored-genesys-cloud-cx"
  end

  test "if Stripe refuses, the buyer sees that checkout could not start and nothing was charged", %{conn: conn} do
    System.put_env("STRIPE_SECRET_KEY", "sk_test_fake_for_tests")
    Application.put_env(:armored_store, :stripe_post, {FakeStripe, :refuse})
    html = conn |> post("/checkout/armored-genesys-cloud-cx") |> html_response(502)
    assert html =~ "Checkout could not start"
    assert html =~ "No payment was taken."
  end

  test "the default HTTP call in tests never reaches Stripe", %{conn: conn} do
    System.put_env("STRIPE_SECRET_KEY", "sk_test_fake_for_tests")
    assert conn |> post("/checkout/armored-genesys-cloud-cx") |> html_response(502) =~ "Checkout could not start"
  end

  test "a product with no price cannot be bought, and Stripe is not called", %{conn: conn} do
    System.put_env("STRIPE_SECRET_KEY", "sk_test_fake_for_tests")
    Application.put_env(:armored_store, :stripe_post, {FakeStripe, :ok})
    {:ok, _} = Catalog.upsert_product(%{"slug" => "unpriced", "title" => "Unpriced", "author" => "Joshua"})
    assert conn |> post("/checkout/unpriced") |> html_response(422) =~ "Price not set"
    refute_received {:stripe_called, _}
  end

  test "an unknown product is a 404", %{conn: conn} do
    assert conn |> post("/checkout/no-such-book") |> html_response(404) =~ "Not found"
  end
end
