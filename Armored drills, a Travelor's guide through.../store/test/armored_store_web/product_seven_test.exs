defmodule ArmoredStoreWeb.ProductSevenTest do
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.Catalog

  @slug "armored-accounting-for-decision-making"
  @title "Armored Accounting for Decision Making: The Fail Fast Compendium"
  @cover "Armored_Accounting_for_Decision_Making_cover.jpg"

  defmodule NoStripe do
    def post(req) do
      send(:product_seven_test, {:stripe_called, req})
      {:ok, 200, ~s({"id":"cs_test_7","url":"https://checkout.stripe.com/c/pay/cs_test_7"})}
    end
  end

  setup do
    Catalog.seed_store("priv/KDP_LISTINGS.json", "priv/STORE_ADDITIONS.json")
    :ok
  end

  defp doc(conn, path), do: conn |> get(path) |> html_response(200) |> Floki.parse_document!()

  test "the catalog lists #7 after the six listings, with its cover and 'Price not set'", %{conn: conn} do
    d = doc(conn, "/books")
    ids = d |> Floki.find("li.card") |> Enum.flat_map(&Floki.attribute(&1, "id"))
    assert length(ids) == 869
    assert Enum.at(ids, 6) == "product-" <> @slug

    card = Floki.find(d, "#product-" <> @slug)
    text = Floki.text(card)
    assert text =~ @title
    assert text =~ "by Joshua"
    assert text =~ "Price not set"
    refute text =~ "$"
    assert Floki.attribute(card, "img", "src") == ["/images/covers/" <> @cover]
  end

  test "the other six are unchanged: same order, $0.99 each", %{conn: conn} do
    d = doc(conn, "/books")
    six = Enum.take(Catalog.list_products(), 6)
    assert Enum.map(six, & &1.slug) == ~w(armored-servicenow-itsm armored-servicenow-customer-service-management
             armored-servicenow-now-assist-skill-kit armored-genesys-cloud-cx armored-integration-whisper-warm-hot
             the-traveler-s-guide-nursing-state-and-owner-s-county)

    for p <- six, do: assert(d |> Floki.find("#product-#{p.slug}") |> Floki.text() =~ "$0.99", p.slug)
  end

  test "#7's page shows the title and 'Price not set', with no buy button", %{conn: conn} do
    d = doc(conn, "/books/" <> @slug)
    text = Floki.text(d)
    assert text =~ @title
    assert text =~ "Price not set"
    assert text =~ "Not available to buy yet."
    assert Floki.find(d, "form") == []
    assert Floki.find(d, "button") == []
    assert Floki.attribute(d, "img.cover", "src") == ["/images/covers/" <> @cover]
  end

  test "#7 cannot be bought even with checkout configured, and Stripe is not called", %{conn: conn} do
    Process.register(self(), :product_seven_test)
    old_key = System.get_env("STRIPE_SECRET_KEY")
    old_post = Application.get_env(:armored_store, :stripe_post)

    on_exit(fn ->
      if old_key, do: System.put_env("STRIPE_SECRET_KEY", old_key), else: System.delete_env("STRIPE_SECRET_KEY")
      Application.put_env(:armored_store, :stripe_post, old_post)
    end)

    System.put_env("STRIPE_SECRET_KEY", "sk_test_fake_for_tests")
    Application.put_env(:armored_store, :stripe_post, {NoStripe, :post})
    assert conn |> post("/checkout/" <> @slug) |> html_response(422) =~ "Price not set"
    refute_received {:stripe_called, _}
  end

  test "#7's cover is served; its book files are not", %{conn: conn} do
    c = get(conn, "/images/covers/" <> @cover)
    assert c.status == 200
    assert c |> get_resp_header("content-type") |> hd() =~ "image/jpeg"

    for ext <- ~w(pdf docx), dir <- ["", "/images", "/images/covers", "/assets", "/books", "/downloads", "/files", "/priv", "/static"] do
      path = "#{dir}/Armored_Accounting_for_Decision_Making.#{ext}"
      assert build_conn() |> get(path) |> Map.get(:status) == 404, path
    end
  end

  test "#7's page carries no email address", %{conn: conn} do
    html = conn |> get("/books/" <> @slug) |> response(200)
    refute Regex.match?(~r/[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}/, html)
  end
end
