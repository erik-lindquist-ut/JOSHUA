defmodule ArmoredStoreWeb.BusinessDrillsPagesTest do
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.{Catalog, Previews}

  @drills [
    {"armored-managing-organizations-and-leading-people", "Armored Managing Organizations and Leading People", "Armored_Managing_Organizations_and_Leading_People"},
    {"armored-business-acumen", "Armored Business Acumen", "Armored_Business_Acumen"},
    {"armored-managing-human-capital", "Armored Managing Human Capital", "Armored_Managing_Human_Capital"},
    {"armored-becoming-an-effective-leader", "Armored Becoming an Effective Leader", "Armored_Becoming_an_Effective_Leader"},
    {"armored-management-communication", "Armored Management Communication", "Armored_Management_Communication"},
    {"armored-leading-teams", "Armored Leading Teams", "Armored_Leading_Teams"}
  ]

  defmodule NoStripe do
    def post(req) do
      send(:business_drills_pages_test, {:stripe_called, req})
      {:ok, 200, ~s({"id":"cs_test_8","url":"https://checkout.stripe.com/c/pay/cs_test_8"})}
    end
  end

  setup do
    Catalog.seed_store("priv/KDP_LISTINGS.json", "priv/STORE_ADDITIONS.json")
    :ok
  end

  defp doc(conn, path), do: conn |> get(path) |> html_response(200) |> Floki.parse_document!()

  test "the catalog lists the six listings, #7, then the six business drills in order", %{conn: conn} do
    ids = conn |> doc("/books") |> Floki.find("li.card") |> Enum.flat_map(&Floki.attribute(&1, "id"))
    assert length(ids) == 869
    assert Enum.at(ids, 6) == "product-armored-accounting-for-decision-making"
    assert Enum.slice(ids, 7, 6) == Enum.map(@drills, fn {slug, _, _} -> "product-" <> slug end)
  end

  test "each new card links to its preview page and shows its cover, title, by-line and 'Price not set'", %{conn: conn} do
    d = doc(conn, "/books")

    for {slug, title, stem} <- @drills do
      card = Floki.find(d, "#product-" <> slug)
      links = Floki.find(card, "a.card-link")
      assert Floki.attribute(links, "href") == ["/books/" <> slug]
      text = Floki.text(card)
      assert text =~ title
      assert text =~ "by Joshua"
      assert text =~ "Price not set"
      assert text =~ "Read the preview"
      refute text =~ "$"
      assert Floki.attribute(card, "img", "src") == ["/images/covers/#{stem}_cover.jpg"]
    end
  end

  test "each new page shows its title, 'Price not set' with no buy button, and How to run it as eight numbered steps", %{conn: conn} do
    for {slug, title, stem} <- @drills do
      d = doc(build_conn(), "/books/" <> slug)
      text = Floki.text(d)
      assert text =~ title
      assert text =~ "Price not set"
      assert text =~ "Not available to buy yet."
      assert Floki.find(d, "form") == []
      assert Floki.find(d, "button") == []
      assert Floki.attribute(d, "img.cover", "src") == ["/images/covers/#{stem}_cover.jpg"]

      preview = Floki.find(d, "#preview")
      ptext = Floki.text(preview)
      assert ptext =~ "How to run it"
      assert ptext =~ "Paper first. Pencil. One pass, no notes, a timer if you want the pressure."
      assert ptext =~ "Stop at the STOP page."
      assert ptext =~ "The strip, filled in, looks like this:"
      assert length(Floki.find(preview, "ol li")) == 8

      for para <- Previews.get(slug).paragraphs, do: assert(ptext =~ para.text, slug)
    end

    _ = conn
  end

  test "no course number anywhere on the catalog or the new pages", %{conn: conn} do
    html = conn |> get("/") |> html_response(200)
    refute html =~ ~r/\bC20[0-5]\b/

    for {slug, _, _} <- @drills do
      refute build_conn() |> get("/books/" <> slug) |> html_response(200) =~ ~r/\bC\d{3}\b/, slug
    end
  end

  test "the new drills cannot be bought even with checkout configured, and Stripe is not called", %{conn: conn} do
    Process.register(self(), :business_drills_pages_test)
    old_key = System.get_env("STRIPE_SECRET_KEY")
    old_post = Application.get_env(:armored_store, :stripe_post)

    on_exit(fn ->
      if old_key, do: System.put_env("STRIPE_SECRET_KEY", old_key), else: System.delete_env("STRIPE_SECRET_KEY")
      Application.put_env(:armored_store, :stripe_post, old_post)
    end)

    System.put_env("STRIPE_SECRET_KEY", "sk_test_fake_for_tests")
    Application.put_env(:armored_store, :stripe_post, {NoStripe, :post})

    for {slug, _, _} <- @drills do
      assert build_conn() |> post("/checkout/" <> slug) |> html_response(422) =~ "Price not set"
    end

    refute_received {:stripe_called, _}
    _ = conn
  end

  test "the new covers are served; the book files are not", %{conn: conn} do
    for {_, _, stem} <- @drills do
      c = get(build_conn(), "/images/covers/#{stem}_cover.jpg")
      assert c.status == 200
      assert c |> get_resp_header("content-type") |> hd() =~ "image/jpeg"

      for dir <- ["", "/images", "/images/covers", "/books", "/downloads", "/files", "/priv", "/static"] do
        assert build_conn() |> get("#{dir}/#{stem}.pdf") |> Map.get(:status) == 404, "#{dir}/#{stem}.pdf"
      end
    end

    _ = conn
  end
end
