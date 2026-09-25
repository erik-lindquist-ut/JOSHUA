defmodule LastTenYardsWeb.StoreController do
  use LastTenYardsWeb, :controller
  alias LastTenYards.Checkout

  # Products live in Postgres now (LastTenYards.Store). products.json only seeds it.
  defp products, do: LastTenYards.Store.list_products()

  defp base_url(conn), do: "#{conn.scheme}://#{conn.host}" <> if(conn.port in [80, 443], do: "", else: ":#{conn.port}")

  defp stripe_post(req) do
    case Req.post(req.url, headers: req.headers, body: req.body, decode_body: false) do
      {:ok, %{status: s, body: b}} -> {:ok, s, b}
      {:error, e} -> {:error, Exception.message(e)}
    end
  end

  def index(conn, _), do: conn |> put_root_layout(false) |> render(:index, products: products(), token: get_csrf_token())

  def checkout(conn, %{"id" => id}) do
    case Checkout.find(products(), id) do
      nil ->
        conn |> put_status(404) |> text("No such product.")

      p ->
        case Checkout.create(p, base_url(conn), System.get_env("STRIPE_SECRET_KEY"), &stripe_post/1) do
          {:ok, url} -> redirect(conn, external: url)
          {:error, :not_configured} -> conn |> put_status(503) |> text("Checkout is not switched on yet.")
          {:error, why} -> conn |> put_status(502) |> text("Checkout could not start: #{inspect(why)}")
        end
    end
  end

  @doc "Every business line, each with its own storefront."
  def lines(conn, _), do: conn |> put_root_layout(false) |> render(:lines, lines: LastTenYards.Store.list_lines())

  @doc "One line's storefront. Same checkout, same database."
  def line(conn, %{"line" => slug}) do
    case LastTenYards.Store.get_line(slug) do
      nil -> conn |> put_status(404) |> text("No such line.")
      l -> conn |> put_root_layout(false) |> render(:line, line: l, products: LastTenYards.Store.list_products(slug), token: get_csrf_token())
    end
  end

  def thanks(conn, _), do: conn |> put_root_layout(false) |> render(:thanks)
end
