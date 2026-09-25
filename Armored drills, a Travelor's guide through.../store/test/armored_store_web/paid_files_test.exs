defmodule ArmoredStoreWeb.PaidFilesTest do
  @moduledoc "The PDFs and DOCX files are paid goods: there must be no free route to them."
  use ArmoredStoreWeb.ConnCase, async: false

  @books ~w(Armored_ServiceNow_ITSM Armored_ServiceNow_Customer_Service_Management Armored_ServiceNow_Now_Assist_Skill_Kit
            Armored_Genesys_Cloud_CX Armored_Integration_Whisper_Warm_Hot The_Traveler_s_Guide_Nursing_State_and_Owner_s_County
            C213_Armored_Drill)

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

  test "no PDF, DOCX or other book file sits under priv/static" do
    files = Path.wildcard("priv/static/**/*", match_dot: true) |> Enum.filter(&File.regular?/1)
    assert files != []
    bad = Enum.filter(files, &(String.downcase(Path.extname(&1)) in ~w(.pdf .docx .doc .epub .mobi .azw3 .zip)))
    assert bad == []
  end

  test "only images, styles, favicon and robots.txt are served as static files" do
    assert Enum.sort(ArmoredStoreWeb.static_paths()) == Enum.sort(~w(assets images favicon.ico robots.txt))
  end
end
