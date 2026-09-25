defmodule ArmoredStore.Checkout do
  @moduledoc """
  Stripe Checkout, the smallest correct way: the server asks Stripe for a hosted
  checkout page for one product at its listing price and sends the buyer there.
  Card numbers never touch this app. The secret key comes only from the
  STRIPE_SECRET_KEY environment variable; with none set, nothing is called.
  """

  @stripe "https://api.stripe.com/v1/checkout/sessions"

  @doc "Form fields for one Checkout Session: one item, one-time payment, price from the listing."
  def params(product, base_url) do
    %{
      "mode" => "payment",
      "line_items[0][quantity]" => "1",
      "line_items[0][price_data][currency]" => "usd",
      "line_items[0][price_data][unit_amount]" => Integer.to_string(product.cents),
      "line_items[0][price_data][product_data][name]" => product.title,
      "metadata[product_id]" => product.slug,
      "success_url" => base_url <> "/thanks?session_id={CHECKOUT_SESSION_ID}",
      "cancel_url" => base_url <> "/books/" <> product.slug
    }
  end

  def encode(form), do: URI.encode_query(form)

  @doc """
  Create the session. `post` is the HTTP call (injected so tests never hit Stripe):
  `post.(%{url:, headers:, body:})` → `{:ok, status, body}` or `{:error, reason}`.
  """
  def create(_product, _base, key, _post) when key in [nil, ""], do: {:error, :not_configured}

  def create(%{cents: cents} = product, base, key, post) when is_integer(cents) and cents > 0 do
    req = %{
      url: @stripe,
      headers: [{"authorization", "Bearer " <> key}, {"content-type", "application/x-www-form-urlencoded"}],
      body: encode(params(product, base))
    }

    case post.(req) do
      {:ok, 200, body} ->
        case Jason.decode(body) do
          {:ok, %{"url" => url}} when is_binary(url) -> {:ok, url}
          _ -> {:error, :stripe_failed}
        end

      {:ok, _status, body} ->
        case Jason.decode(body) do
          {:ok, %{"error" => %{"message" => m}}} -> {:error, m}
          _ -> {:error, :stripe_failed}
        end

      {:error, _} = e ->
        e
    end
  end

  def create(_product, _base, _key, _post), do: {:error, :no_price}

  @doc "The real HTTP call (used only outside tests, and only when a key is set)."
  def http_post(req) do
    case Req.post(req.url, headers: req.headers, body: req.body, decode_body: false, retry: false) do
      {:ok, %{status: s, body: b}} -> {:ok, s, b}
      {:error, e} -> {:error, Exception.message(e)}
    end
  end

  @doc "The HTTP call configured for tests: never leaves the machine."
  def offline_post(_req), do: {:error, :offline}
end
