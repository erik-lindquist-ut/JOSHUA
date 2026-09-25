defmodule LastTenYardsWeb.WebhookTest do
  use LastTenYardsWeb.ConnCase, async: false
  alias LastTenYards.{Store, StripeWebhook}

  @body ~s({"type":"checkout.session.completed","data":{"object":{"id":"cs_w1","payment_status":"paid","amount_total":2500,"currency":"usd","payment_intent":"pi_w1","metadata":{"product_id":"ride-at-closing"}}}})

  setup do
    System.put_env("STRIPE_WEBHOOK_SECRET", "whsec_t")
    on_exit(fn -> System.delete_env("STRIPE_WEBHOOK_SECRET") end)
    {:ok, _} = Store.upsert_line(%{"slug" => "tesla-rideshare", "name" => "Tesla Rideshare"})
    {:ok, _} = Store.upsert_product(%{"slug" => "ride-at-closing", "name" => "Ride", "cents" => 2500, "stripe_price" => "price_1", "line" => "tesla-rideshare"})
    :ok
  end

  defp signed(conn, body) do
    ts = System.system_time(:second)
    conn |> put_req_header("content-type", "application/json") |> put_req_header("stripe-signature", "t=#{ts},v1=#{StripeWebhook.sign(body, "whsec_t", ts)}")
  end

  test "a signed paid event records one order", %{conn: conn} do
    assert conn |> signed(@body) |> post("/stripe/webhook", @body) |> response(200)
    assert Store.paid_total_cents() == 2500
  end

  test "an unsigned event is refused and records nothing", %{conn: conn} do
    assert conn |> put_req_header("content-type", "application/json") |> post("/stripe/webhook", @body) |> response(400)
    assert Store.paid_total_cents() == 0
  end

  test "store page lists products from the database", %{conn: conn} do
    assert conn |> get("/store") |> html_response(200) =~ "Ride"
  end

  test "the lines directory and one line's storefront", %{conn: conn} do
    assert conn |> get("/lines") |> html_response(200) =~ "Tesla Rideshare"
    assert conn |> get("/l/tesla-rideshare") |> html_response(200) =~ "Ride"
    assert conn |> get("/l/no-such-line") |> response(404)
  end
end
