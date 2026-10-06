defmodule ArmoredStoreWeb.NoSeriesTest do
  @moduledoc """
  No series label anywhere in the store (Erik's request, 2026-09-25): no page -- home, all books, the four schools,
  every program, every book page with its preview, the not-found pages -- says "Joshua Says" in any case, no product
  carries a series, and the author "Joshua" still shows on every book page.
  """
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.{Catalog, Programs, Previews}

  @series ~r/joshua\s+says/i

  setup do
    Catalog.seed_store("priv/KDP_LISTINGS.json", "priv/STORE_ADDITIONS.json")
    :ok
  end

  defp page(path), do: build_conn() |> get(path) |> html_response(200)

  test "home, all books, the four schools and every program page carry no series label" do
    paths =
      ["/", "/books"] ++
        Enum.map(Programs.schools(), &"/schools/#{Programs.school_slug(&1)}") ++
        Enum.map(Programs.all(), &"/programs/#{&1.slug}")

    assert length(paths) == 2 + 4 + 115

    for path <- paths do
      html = page(path)
      refute html =~ @series, path
    end

    assert page("/") =~ "by Joshua"
  end

  test "every book page (with its preview) has no series label and still shows the author, Joshua" do
    products = Catalog.list_products()
    assert length(products) == 869

    for p <- products do
      html = page("/books/#{p.slug}")
      refute html =~ @series, p.slug
      by = html |> Floki.parse_document!() |> Floki.find("p.by") |> Floki.text() |> String.trim()
      assert by =~ ~r/\Aby Joshua\b/, p.slug
      refute by =~ @series, p.slug
    end
  end

  test "the not-found pages carry no series label" do
    refute build_conn() |> get("/no-such-page") |> response(404) =~ @series
    refute build_conn() |> get("/programs/no-such-program") |> response(404) =~ @series
  end

  test "no product has a series; the additions file has no series key; the previews never say it" do
    assert Enum.all?(Catalog.list_products(), &is_nil(&1.series))
    assert Enum.all?(Catalog.list_products(), &(&1.author == "Joshua"))

    additions = "priv/STORE_ADDITIONS.json" |> File.read!() |> Jason.decode!()
    assert length(additions) == 863
    refute Enum.any?(additions, &Map.has_key?(&1, "series"))
    refute File.read!("priv/STORE_ADDITIONS.json") =~ @series
    refute File.read!("priv/PREVIEWS.json") =~ @series

    for {slug, prev} <- Previews.all() do
      refute inspect(prev) =~ @series, slug
    end
  end

  test "no cover folder's README names the series" do
    readmes = Path.wildcard("../Cover — */README.md")
    assert length(readmes) >= 863

    for f <- readmes, do: refute(File.read!(f) =~ @series, f)
  end
end
