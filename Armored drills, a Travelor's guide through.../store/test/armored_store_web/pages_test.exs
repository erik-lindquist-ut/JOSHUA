defmodule ArmoredStoreWeb.PagesTest do
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.Catalog

  setup do
    Catalog.seed_from_listings("priv/KDP_LISTINGS.json")
    :ok
  end

  defp doc(conn, path), do: conn |> get(path) |> html_response(200) |> Floki.parse_document!()

  test "catalog shows every product with cover, title, author, short description and price", %{conn: conn} do
    d = doc(conn, "/")

    for p <- Catalog.list_products() do
      card = Floki.find(d, "#product-#{p.slug}")
      assert card != [], p.slug
      text = Floki.text(card)
      assert text =~ p.title
      assert text =~ "by Joshua"
      assert text =~ ArmoredStore.Listings.short(p.description)
      assert text =~ "$0.99"
      assert Floki.attribute(card, "img", "src") == ["/images/covers/" <> p.cover]
      assert Floki.attribute(card, "a", "href") |> Enum.uniq() == ["/books/" <> p.slug]
    end
  end

  test "catalog is a full HTML document with a favicon and a stylesheet", %{conn: conn} do
    html = conn |> get("/") |> html_response(200)
    assert html =~ "<!DOCTYPE html>"
    assert html =~ ~s(rel="icon" href="/favicon.ico")
    assert html =~ ~s(href="/assets/store.css")
  end

  test "an empty catalog says Coming soon", %{conn: conn} do
    ArmoredStore.Repo.delete_all(ArmoredStore.Catalog.Product)
    assert conn |> get("/") |> html_response(200) =~ "Coming soon."
  end

  test "each product has its own page with the full description and a buy button at its price", %{conn: conn} do
    for p <- Catalog.list_products() do
      d = doc(build_conn(), "/books/#{p.slug}")
      text = Floki.text(d)
      assert text =~ p.title
      assert text =~ p.subtitle
      assert text =~ p.description
      assert text =~ "by Joshua"
      assert Floki.attribute(d, "form", "action") == ["/checkout/#{p.slug}"]
      assert Floki.find(d, "form button") |> Floki.text() =~ "Buy — $0.99"
      assert Floki.attribute(d, "img.cover", "src") == ["/images/covers/" <> p.cover]
    end

    _ = conn
  end

  test "a product with no price shows 'Price not set' and no buy button", %{conn: conn} do
    {:ok, _} = Catalog.upsert_product(%{"slug" => "unpriced", "title" => "Unpriced Title", "author" => "Joshua", "description" => "No price yet.", "position" => 99})

    card = doc(conn, "/") |> Floki.find("#product-unpriced")
    assert Floki.text(card) =~ "Price not set"

    d = doc(build_conn(), "/books/unpriced")
    assert Floki.text(d) =~ "Price not set"
    assert Floki.find(d, "form") == []
    assert Floki.find(d, "button") == []
  end

  test "an unknown product is a 404", %{conn: conn} do
    assert conn |> get("/books/no-such-book") |> html_response(404) =~ "Not found"
  end

  test "thanks page with a Stripe checkout session id says the order is in", %{conn: conn} do
    html = conn |> get("/thanks?session_id=cs_test_a1B2c3") |> html_response(200)
    assert html =~ "Thank you."
    assert html =~ "Your order is in."
    refute html =~ "cs_test_a1B2c3"
    assert html =~ ~s(href="/")
  end

  test "thanks page without a Stripe checkout session id does not claim an order", %{conn: conn} do
    for q <- ["", "?session_id=", "?session_id=hello", "?session_id=pi_123", "?session=cs_test_a1B2c3", "?session_id=cs_<script>"] do
      html = build_conn() |> get("/thanks" <> q) |> html_response(200)
      refute html =~ "Your order is in.", q
      assert html =~ "No order found.", q
    end

    _ = conn
  end

  test "favicon and every cover image are served", %{conn: conn} do
    assert conn |> get("/favicon.ico") |> response(200) != ""

    for p <- Catalog.list_products() do
      c = build_conn() |> get("/images/covers/" <> p.cover)
      assert c.status == 200, p.cover
      assert c |> get_resp_header("content-type") |> hd() =~ "image/jpeg"
    end
  end

  test "no page carries an email address", %{conn: conn} do
    pages = ["/", "/thanks", "/thanks?session_id=cs_test_1"] ++ Enum.map(Catalog.list_products(), &"/books/#{&1.slug}")

    for path <- pages do
      html = build_conn() |> get(path) |> response(200)
      refute Regex.match?(~r/[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}/, html), path
      refute html =~ "mailto:", path
    end

    _ = conn
  end
end
