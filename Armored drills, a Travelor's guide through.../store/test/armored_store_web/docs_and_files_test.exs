defmodule ArmoredStoreWeb.DocsAndFilesTest do
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.Catalog

  @compendium "armored-accounting-for-decision-making"
  @itsm "armored-servicenow-itsm"

  setup do
    Catalog.seed_store("priv/KDP_LISTINGS.json", "priv/STORE_ADDITIONS.json")
    :ok
  end

  defp doc(conn, path), do: conn |> get(path) |> html_response(200) |> Floki.parse_document!()

  test "home leads with project tree and both handoff docs", %{conn: conn} do
    d = doc(conn, "/")
    assert Floki.find(d, "#project-tree") != []
    assert Floki.find(d, "#docs-readme") != []
    assert Floki.find(d, "#docs-technical") != []
    tree = Floki.text(Floki.find(d, "#project-tree"))
    assert tree =~ "docs/"
    assert tree =~ "handoff"
    assert tree =~ "TECHNICAL.md"
    assert Floki.text(Floki.find(d, "#readme-body")) =~ "Fail Fast Compendium"
    assert Floki.text(Floki.find(d, "#technical-body")) =~ "Phoenix"
  end

  test "/docs/readme and /docs/technical render the priv/docs copies", %{conn: conn} do
    r = doc(conn, "/docs/readme")
    assert Floki.text(Floki.find(r, "#doc-body")) =~ "Provost"
    assert Floki.text(Floki.find(r, "#doc-body")) =~ "Fail Fast"

    t = doc(build_conn(), "/docs/technical")
    assert Floki.text(Floki.find(t, "#doc-body")) =~ "Rails"
    assert Floki.text(Floki.find(t, "#doc-body")) =~ "armored_store"
  end

  test "each book has a files page listing inventory without serving paid bytes", %{conn: conn} do
    d = doc(conn, "/books/#{@itsm}/files")
    assert Floki.text(d) =~ "Files"
    assert Floki.find(d, "#files-table") != []
    html = conn |> get("/books/#{@itsm}/files") |> html_response(200)
    refute html =~ "%PDF"
    # no download link to the paid PDF filename as an href to a binary path
    hrefs = Floki.attribute(d, "a", "href")
    refute Enum.any?(hrefs, &String.ends_with?(&1, ".pdf"))
  end

  test "Fail Fast Compendium files page lists the viewable handoff PDF", %{conn: conn} do
    d = doc(conn, "/books/#{@compendium}/files")
    assert Floki.find(d, "#file-Armored-Accounting-for-Decision-Making-Fail-Fast-Compendium-pdf") != []
    hrefs = Floki.attribute(d, "a", "href")
    assert "/handoff/Armored_Accounting_for_Decision_Making_Fail_Fast_Compendium.pdf" in hrefs
  end

  test "book show page links to its files inventory", %{conn: conn} do
    d = doc(conn, "/books/#{@compendium}")
    assert Floki.attribute(d, "#files-link a", "href") == ["/books/#{@compendium}/files"]
  end
end
