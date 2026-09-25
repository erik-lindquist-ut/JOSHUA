defmodule LastTenYardsWeb.PageTest do
  use LastTenYardsWeb.ConnCase, async: true

  test "home is 200 and mobile-first", %{conn: conn} do
    html = conn |> get("/") |> html_response(200)
    assert html =~ ~s(name="viewport" content="width=device-width, initial-scale=1")
    assert html =~ "<title>Last Ten Yards</title>"
  end

  test "home loads the posts, the renderer and the theme", %{conn: conn} do
    html = conn |> get("/") |> html_response(200)
    for a <- ~w(/assets/posts.js /assets/render.js /assets/styles.css), do: assert(html =~ a)
  end

  for a <- ~w(posts.js render.js styles.css) do
    @a a
    test "asset #{a} is served", %{conn: conn} do
      assert conn |> get("/assets/" <> @a) |> response(200) =~ ~r/\S/
    end
  end

  test "the posts file carries #LastTenYards", %{conn: conn} do
    assert conn |> get("/assets/posts.js") |> response(200) =~ "#LastTenYards"
  end
end
