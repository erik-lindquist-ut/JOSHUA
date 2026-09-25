defmodule LastTenYardsWeb.StoreTest do
  use LastTenYardsWeb.ConnCase, async: false

  test "empty catalog shows Coming soon", %{conn: conn} do
    html = conn |> get("/store") |> html_response(200)
    assert html =~ "Coming soon."
    assert html =~ "Card numbers never touch this site."
  end

  test "thanks page", %{conn: conn} do
    assert conn |> get("/store/thanks") |> html_response(200) =~ "Thank you."
  end

  test "Heroku files are present" do
    assert File.read!("Procfile") =~ "web: mix phx.server"
    assert File.read!("elixir_buildpack.config") =~ "elixir_version"
  end
end
