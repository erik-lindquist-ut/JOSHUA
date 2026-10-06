defmodule ArmoredStoreWeb.PaidFilesTest do
  @moduledoc """
  The PDFs and DOCX files are paid goods: there must be no free route to them,
  except the labeled WGU Fail Fast Compendium under priv/static/handoff/.
  """
  use ArmoredStoreWeb.ConnCase, async: false

  @books ~w(Armored_ServiceNow_ITSM Armored_ServiceNow_Customer_Service_Management Armored_ServiceNow_Now_Assist_Skill_Kit
            Armored_Genesys_Cloud_CX Armored_Integration_Whisper_Warm_Hot The_Traveler_s_Guide_Nursing_State_and_Owner_s_County
            C213_Armored_Drill)

  @handoff "Armored_Accounting_for_Decision_Making_Fail_Fast_Compendium.pdf"

  setup do
    ArmoredStore.Catalog.seed_from_listings("priv/KDP_LISTINGS.json")
    :ok
  end

  test "every book file path returns 404", %{conn: conn} do
    for b <- @books, ext <- ~w(pdf docx), dir <- ["", "/images", "/images/covers", "/assets", "/books", "/downloads", "/files", "/priv", "/static"] do
      path = "#{dir}/#{b}.#{ext}"
      c = build_conn() |> get(path)
      assert c.status == 404, path
      refute String.starts_with?(c.resp_body, "%PDF"), path
      refute String.starts_with?(c.resp_body, "PK"), path
    end

    _ = conn
  end

  test "the book folders themselves are not reachable", %{conn: conn} do
    for path <- ["/Armored%20ServiceNow%20-%20ITSM%20(book,%20V1)/Armored_ServiceNow_ITSM.pdf", "/KDP_LISTINGS.json", "/C213%20Armored%20Drill/C213_Armored_Drill.pdf"] do
      assert build_conn() |> get(path) |> response(404), path
    end

    _ = conn
  end

  test "only the labeled handoff PDF may sit under priv/static (plus images/styles/favicon/robots)" do
    files = Path.wildcard("priv/static/**/*", match_dot: true) |> Enum.filter(&File.regular?/1)
    assert files != []
    bad =
      Enum.filter(files, fn f ->
        ext = String.downcase(Path.extname(f))
        ext in ~w(.pdf .docx .doc .epub .mobi .azw3 .zip) and not String.starts_with?(f, "priv/static/handoff/")
      end)

    assert bad == []
    assert File.regular?("priv/static/handoff/" <> @handoff)
  end

  test "only images, styles, favicon, robots.txt and handoff are served as static files" do
    assert Enum.sort(ArmoredStoreWeb.static_paths()) == Enum.sort(~w(assets images favicon.ico robots.txt handoff))
  end

  test "the WGU handoff PDF is served from /handoff/", %{conn: conn} do
    c = conn |> get("/handoff/" <> @handoff)
    assert c.status == 200
    assert String.starts_with?(c.resp_body, "%PDF")
  end

  test "paid book stems are still 404 even under /handoff/", %{conn: conn} do
    for b <- @books do
      path = "/handoff/#{b}.pdf"
      c = build_conn() |> get(path)
      assert c.status == 404, path
      refute String.starts_with?(c.resp_body || "", "%PDF"), path
    end

    _ = conn
  end
end
