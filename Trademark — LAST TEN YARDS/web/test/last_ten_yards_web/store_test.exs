defmodule LastTenYardsWeb.StoreTest do
  use LastTenYardsWeb.ConnCase, async: false

  test "empty catalog shows Coming soon", %{conn: conn} do
    html = conn |> get("/store") |> html_response(200)
    assert html =~ "Coming soon."
    assert html =~ "Card numbers never touch this site."
  end

  test "thanks page with a Stripe checkout session id says the order is in", %{conn: conn} do
    html = conn |> get("/store/thanks?session_id=cs_test_a1B2c3") |> html_response(200)
    assert html =~ "Thank you."
    assert html =~ "Your order is in."
    assert html =~ ~s(href="/")
  end

  test "thanks page without a session id does not claim an order", %{conn: conn} do
    html = conn |> get("/store/thanks") |> html_response(200)
    refute html =~ "Your order is in."
    assert html =~ "No order found."
    assert html =~ ~s(href="/")
  end

  test "thanks page with an empty or non-Stripe session id does not claim an order", %{conn: conn} do
    for q <- ["session_id=", "session_id=hello", "session=cs_test_a1B2c3"] do
      html = build_conn() |> get("/store/thanks?" <> q) |> html_response(200)
      refute html =~ "Your order is in.", q
      assert html =~ "No order found.", q
    end
    _ = conn
  end

  test "README line counts match priv/lines.json" do
    n = "priv/lines.json" |> File.read!() |> Jason.decode!() |> length()
    counts = Regex.scan(~r/(\d+)\*{0,2} lines\b/, File.read!("README.md"), capture: :all_but_first) |> List.flatten()
    assert counts != []
    assert Enum.all?(counts, &(&1 == Integer.to_string(n))), "README counts #{inspect(counts)} vs #{n} lines in priv/lines.json"
  end

  test "Heroku files are present" do
    assert File.read!("Procfile") =~ "web: mix phx.server"
    assert File.read!("elixir_buildpack.config") =~ "elixir_version"
  end
end
