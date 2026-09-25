defmodule ArmoredStoreWeb.WebhookTest do
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.{Catalog, StripeWebhook}

  @body ~s({"type":"checkout.session.completed","data":{"object":{"id":"cs_w1","payment_status":"paid","amount_total":99,"currency":"usd","payment_intent":"pi_w1","metadata":{"product_id":"armored-servicenow-itsm"}}}})

  setup do
    old = System.get_env("STRIPE_WEBHOOK_SECRET")
    System.put_env("STRIPE_WEBHOOK_SECRET", "whsec_t")
    on_exit(fn -> if old, do: System.put_env("STRIPE_WEBHOOK_SECRET", old), else: System.delete_env("STRIPE_WEBHOOK_SECRET") end)
    Catalog.seed_from_listings("priv/KDP_LISTINGS.json")
    :ok
  end

  defp signed(conn, body) do
    ts = System.system_time(:second)
    conn |> put_req_header("content-type", "application/json") |> put_req_header("stripe-signature", "t=#{ts},v1=#{StripeWebhook.sign(body, "whsec_t", ts)}")
  end

  test "a signed paid event records one order, even if sent twice", %{conn: conn} do
    assert conn |> signed(@body) |> post("/stripe/webhook", @body) |> response(200)
    assert build_conn() |> signed(@body) |> post("/stripe/webhook", @body) |> response(200)
    assert Catalog.paid_total_cents() == 99
  end

  test "an unsigned or wrongly signed event is refused and records nothing", %{conn: conn} do
    assert conn |> put_req_header("content-type", "application/json") |> post("/stripe/webhook", @body) |> response(400)
    assert build_conn() |> put_req_header("content-type", "application/json") |> put_req_header("stripe-signature", "t=#{System.system_time(:second)},v1=deadbeef") |> post("/stripe/webhook", @body) |> response(400)
    assert Catalog.paid_total_cents() == 0
  end

  test "with no signing secret configured the webhook is off", %{conn: conn} do
    System.delete_env("STRIPE_WEBHOOK_SECRET")
    assert conn |> signed(@body) |> post("/stripe/webhook", @body) |> response(503)
    assert Catalog.paid_total_cents() == 0
  end
end
