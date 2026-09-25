defmodule ArmoredStore.StripeWebhook do
  @moduledoc """
  Stripe tells us a payment went through by calling /stripe/webhook.
  We only trust it if the Stripe-Signature header matches an HMAC-SHA256 of the raw body
  made with our signing secret (STRIPE_WEBHOOK_SECRET), and the timestamp is fresh.
  """

  @tolerance 300

  @doc "Header looks like: t=1700000000,v1=abc...,v1=def..."
  def parse_header(header) when is_binary(header) do
    parts =
      header
      |> String.split(",", trim: true)
      |> Enum.map(&String.split(String.trim(&1), "=", parts: 2))
      |> Enum.filter(&match?([_, _], &1))

    with [_, t] <- Enum.find(parts, &match?(["t", _], &1)),
         {ts, ""} <- Integer.parse(t) do
      {:ok, ts, for(["v1", sig] <- parts, do: sig)}
    else
      _ -> {:error, :bad_header}
    end
  end

  def parse_header(_), do: {:error, :bad_header}

  def sign(payload, secret, ts),
    do: :crypto.mac(:hmac, :sha256, secret, "#{ts}.#{payload}") |> Base.encode16(case: :lower)

  @doc "Check the signature, then return the decoded event."
  def verify(_payload, _header, secret, _now) when secret in [nil, ""], do: {:error, :not_configured}

  def verify(payload, header, secret, now) do
    with {:ok, ts, sigs} <- parse_header(header),
         :ok <- fresh(ts, now),
         :ok <- match(sign(payload, secret, ts), sigs),
         {:ok, event} <- Jason.decode(payload) do
      {:ok, event}
    else
      {:error, reason} when is_atom(reason) -> {:error, reason}
      _ -> {:error, :bad_payload}
    end
  end

  defp fresh(ts, now) when abs(now - ts) <= @tolerance, do: :ok
  defp fresh(_, _), do: {:error, :too_old}

  defp match(_, []), do: {:error, :no_signature}
  defp match(expected, sigs), do: if(Enum.any?(sigs, &Plug.Crypto.secure_compare(&1, expected)), do: :ok, else: {:error, :bad_signature})

  @doc "Only a completed, paid checkout makes an order. Refunds mark it refunded."
  def action(%{"type" => "checkout.session.completed", "data" => %{"object" => s}}) do
    if s["payment_status"] == "paid" do
      {:record_paid,
       %{
         "stripe_session_id" => s["id"],
         "product_id" => get_in(s, ["metadata", "product_id"]),
         "amount_cents" => s["amount_total"],
         "currency" => s["currency"],
         "payment_intent" => s["payment_intent"],
         "status" => "paid"
       }}
    else
      :ignore
    end
  end

  def action(%{"type" => "charge.refunded", "data" => %{"object" => c}}),
    do: {:record_refund, %{"payment_intent" => c["payment_intent"]}}

  def action(_), do: :ignore
end
