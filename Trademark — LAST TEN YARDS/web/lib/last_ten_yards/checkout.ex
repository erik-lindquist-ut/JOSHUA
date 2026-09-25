defmodule LastTenYards.Checkout do
  @moduledoc """
  Stripe Checkout, the smallest correct way: our server asks Stripe for a hosted
  checkout page for one product and sends the buyer there. Card numbers never touch
  this app. The secret key comes only from the STRIPE_SECRET_KEY environment variable.
  """
  alias LastTenYards.JSON

  @stripe "https://api.stripe.com/v1/checkout/sessions"

  @doc "Products from priv/products.json text. Empty or blank → empty store."
  def catalog(text) do
    case JSON.decode(String.trim(text || "")) do
      {:ok, list} when is_list(list) -> list
      _ -> []
    end
  end

  def find(list, id), do: Enum.find(list, &(&1["id"] == id))

  @doc "Form fields for one Checkout Session: one item, one-time payment."
  def params(product, base_url) do
    %{
      "mode" => "payment",
      "line_items[0][price]" => product["stripe_price"],
      "line_items[0][quantity]" => "1",
      "metadata[product_id]" => product["id"],
      "success_url" => base_url <> "/store/thanks?session_id={CHECKOUT_SESSION_ID}",
      "cancel_url" => base_url <> "/store"
    }
  end

  def encode(form), do: URI.encode_query(form)

  @doc """
  Create the session. `post` is the HTTP call (injected so specs never hit Stripe):
  `post.(%{url:, headers:, body:})` → `{:ok, status, body}`.
  """
  def create(_product, _base, nil, _post), do: {:error, :not_configured}
  def create(%{"stripe_price" => p} = product, base, key, post) when is_binary(p) do
    req = %{
      url: @stripe,
      headers: [{"authorization", "Bearer " <> key}, {"content-type", "application/x-www-form-urlencoded"}],
      body: encode(params(product, base))
    }

    case post.(req) do
      {:ok, 200, body} -> with {:ok, %{"url" => url}} <- JSON.decode(body), do: {:ok, url}
      {:ok, _, body} ->
        case JSON.decode(body) do
          {:ok, %{"error" => %{"message" => m}}} -> {:error, m}
          _ -> {:error, :stripe_failed}
        end
      other -> other
    end
  end
  def create(_product, _base, _key, _post), do: {:error, :no_price}
end
