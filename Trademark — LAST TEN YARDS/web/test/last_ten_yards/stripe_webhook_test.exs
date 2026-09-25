defmodule LastTenYards.StripeWebhookTest do
  use ExUnit.Case, async: true
  alias LastTenYards.StripeWebhook, as: W

  @secret "whsec_test"
  @now 1_790_000_000
  @paid ~s({"type":"checkout.session.completed","data":{"object":{"id":"cs_test_9","payment_status":"paid","amount_total":2500,"currency":"usd","payment_intent":"pi_9","metadata":{"product_id":"ride-at-closing"}}}})

  defp header(body, ts \\ @now, secret \\ @secret), do: "t=#{ts},v1=#{W.sign(body, secret, ts)}"

  test "a correctly signed event is accepted" do
    assert {:ok, %{"type" => "checkout.session.completed"}} = W.verify(@paid, header(@paid), @secret, @now)
  end

  test "any change to the body breaks the signature" do
    assert W.verify(String.replace(@paid, "2500", "1"), header(@paid), @secret, @now) == {:error, :bad_signature}
  end

  test "a signature made with another secret is refused" do
    assert W.verify(@paid, header(@paid, @now, "whsec_other"), @secret, @now) == {:error, :bad_signature}
  end

  test "an old event (replay) is refused" do
    assert W.verify(@paid, header(@paid, @now - 301), @secret, @now) == {:error, :too_old}
    assert {:ok, _} = W.verify(@paid, header(@paid, @now - 300), @secret, @now)
  end

  test "no secret set → not switched on" do
    assert W.verify(@paid, header(@paid), nil, @now) == {:error, :not_configured}
    assert W.verify(@paid, header(@paid), "", @now) == {:error, :not_configured}
  end

  test "garbage headers are refused" do
    for h <- [nil, "", "v1=abc", "t=abc,v1=x", "t=#{@now}"] do
      assert {:error, _} = W.verify(@paid, h, @secret, @now)
    end
  end

  test "one good signature among several is enough (secret rotation)" do
    assert {:ok, _} = W.verify(@paid, "t=#{@now},v1=deadbeef,v1=#{W.sign(@paid, @secret, @now)}", @secret, @now)
  end

  test "a paid checkout becomes an order to record" do
    {:ok, ev} = W.verify(@paid, header(@paid), @secret, @now)
    assert {:record_paid, o} = W.action(ev)
    assert o == %{"stripe_session_id" => "cs_test_9", "product_id" => "ride-at-closing", "amount_cents" => 2500,
                  "currency" => "usd", "payment_intent" => "pi_9", "status" => "paid"}
    assert LastTenYards.Store.Rules.order_errors(o) == []
  end

  test "an unpaid checkout records nothing" do
    ev = %{"type" => "checkout.session.completed", "data" => %{"object" => %{"payment_status" => "unpaid"}}}
    assert W.action(ev) == :ignore
  end

  test "a refund points at its payment" do
    ev = %{"type" => "charge.refunded", "data" => %{"object" => %{"payment_intent" => "pi_9"}}}
    assert W.action(ev) == {:record_refund, %{"payment_intent" => "pi_9"}}
  end

  test "other events are ignored" do
    assert W.action(%{"type" => "customer.created"}) == :ignore
  end
end
