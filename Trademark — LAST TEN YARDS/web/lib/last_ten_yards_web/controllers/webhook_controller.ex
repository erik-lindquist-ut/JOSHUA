defmodule LastTenYardsWeb.WebhookController do
  use LastTenYardsWeb, :controller
  alias LastTenYards.{Store, StripeWebhook}

  def stripe(conn, _params) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, length: 1_000_000)
    sig = conn |> get_req_header("stripe-signature") |> List.first()

    case StripeWebhook.verify(body, sig, System.get_env("STRIPE_WEBHOOK_SECRET"), System.system_time(:second)) do
      {:ok, event} ->
        case StripeWebhook.action(event) do
          {:record_paid, attrs} -> Store.record_paid(attrs)
          {:record_refund, attrs} -> Store.record_refund(attrs)
          :ignore -> :ok
        end

        send_resp(conn, 200, "ok")

      {:error, :not_configured} ->
        send_resp(conn, 503, "webhook not switched on")

      {:error, _} ->
        send_resp(conn, 400, "bad signature")
    end
  end
end
