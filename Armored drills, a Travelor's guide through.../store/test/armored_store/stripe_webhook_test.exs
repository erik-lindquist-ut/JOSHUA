defmodule ArmoredStore.StripeWebhookTest do
  use ExUnit.Case, async: true
  alias ArmoredStore.StripeWebhook

  @body ~s({"type":"checkout.session.completed","data":{"object":{"id":"cs_1","payment_status":"paid"}}})
  @now 1_800_000_000

  defp header(body, secret, ts), do: "t=#{ts},v1=#{StripeWebhook.sign(body, secret, ts)}"

  test "a correctly signed, fresh event is accepted" do
    assert {:ok, %{"type" => "checkout.session.completed"}} = StripeWebhook.verify(@body, header(@body, "whsec_a", @now), "whsec_a", @now)
  end

  test "a wrong secret is refused" do
    assert StripeWebhook.verify(@body, header(@body, "whsec_other", @now), "whsec_a", @now) == {:error, :bad_signature}
  end

  test "a tampered body is refused" do
    assert StripeWebhook.verify(@body <> " ", header(@body, "whsec_a", @now), "whsec_a", @now) == {:error, :bad_signature}
  end

  test "an old timestamp is refused" do
    assert StripeWebhook.verify(@body, header(@body, "whsec_a", @now - 1000), "whsec_a", @now) == {:error, :too_old}
  end

  test "a missing or garbled header is refused" do
    assert StripeWebhook.verify(@body, nil, "whsec_a", @now) == {:error, :bad_header}
    assert StripeWebhook.verify(@body, "nonsense", "whsec_a", @now) == {:error, :bad_header}
  end

  test "no signing secret configured → :not_configured" do
    assert StripeWebhook.verify(@body, "t=1,v1=x", nil, @now) == {:error, :not_configured}
    assert StripeWebhook.verify(@body, "t=1,v1=x", "", @now) == {:error, :not_configured}
  end

  test "a paid completed checkout becomes an order" do
    ev = %{"type" => "checkout.session.completed", "data" => %{"object" => %{"id" => "cs_1", "payment_status" => "paid", "amount_total" => 99, "currency" => "usd", "payment_intent" => "pi_1", "metadata" => %{"product_id" => "armored-servicenow-itsm"}}}}

    assert StripeWebhook.action(ev) ==
             {:record_paid, %{"stripe_session_id" => "cs_1", "product_id" => "armored-servicenow-itsm", "amount_cents" => 99, "currency" => "usd", "payment_intent" => "pi_1", "status" => "paid"}}
  end

  test "an unpaid checkout, and unknown events, do nothing; a refund marks a refund" do
    assert StripeWebhook.action(%{"type" => "checkout.session.completed", "data" => %{"object" => %{"payment_status" => "unpaid"}}}) == :ignore
    assert StripeWebhook.action(%{"type" => "customer.created"}) == :ignore
    assert StripeWebhook.action(%{"type" => "charge.refunded", "data" => %{"object" => %{"payment_intent" => "pi_1"}}}) == {:record_refund, %{"payment_intent" => "pi_1"}}
  end
end
