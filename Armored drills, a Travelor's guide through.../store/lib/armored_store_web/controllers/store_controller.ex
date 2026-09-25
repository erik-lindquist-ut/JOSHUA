defmodule ArmoredStoreWeb.StoreController do
  use ArmoredStoreWeb, :controller
  alias ArmoredStore.{Catalog, Checkout}

  def index(conn, _params), do: page(conn, :index, products: Catalog.list_products())

  def show(conn, %{"slug" => slug}) do
    case Catalog.get_product(slug) do
      nil -> missing(conn)
      p -> page(conn, :show, product: p, token: get_csrf_token())
    end
  end

  def checkout(conn, %{"slug" => slug}) do
    case Catalog.get_product(slug) do
      nil ->
        missing(conn)

      p ->
        case Checkout.create(p, base_url(conn), System.get_env("STRIPE_SECRET_KEY"), &stripe_post/1) do
          {:ok, url} ->
            redirect(conn, external: url)

          {:error, :not_configured} ->
            notice(conn, 200, "Checkout not configured",
              "Online checkout is not configured on this store yet, so this title cannot be bought here right now. No payment was taken.", p)

          {:error, :no_price} ->
            notice(conn, 422, "Price not set", "This title has no price set yet, so it cannot be bought. No payment was taken.", p)

          {:error, _why} ->
            notice(conn, 502, "Checkout could not start", "Stripe did not open a checkout page. No payment was taken. Please try again later.", p)
        end
    end
  end

  @doc """
  Stripe sends the buyer here with ?session_id={CHECKOUT_SESSION_ID} (see Checkout.params/2).
  Only a Stripe checkout session id ("cs_...") says the order is in; the id is never shown.
  The order itself is recorded only by the signed webhook, not by this page.
  """
  def thanks(conn, params), do: page(conn, :thanks, order?: checkout_session?(params["session_id"]))

  def not_found(conn, _params), do: conn |> put_resp_content_type("text/plain") |> send_resp(404, "Not found.")

  defp checkout_session?(id) when is_binary(id), do: Regex.match?(~r/\Acs_[A-Za-z0-9_]{1,255}\z/, id)
  defp checkout_session?(_), do: false

  defp missing(conn), do: notice(conn, 404, "Not found", "There is no such title in this store.", nil)

  defp notice(conn, status, heading, message, product),
    do: conn |> put_status(status) |> page(:notice, heading: heading, message: message, product: product)

  defp page(conn, template, assigns), do: conn |> put_root_layout(false) |> render(template, assigns)

  defp base_url(conn), do: "#{conn.scheme}://#{conn.host}" <> if(conn.port in [80, 443], do: "", else: ":#{conn.port}")

  defp stripe_post(req) do
    {m, f} = Application.get_env(:armored_store, :stripe_post, {Checkout, :http_post})
    apply(m, f, [req])
  end
end
