defmodule LastTenYards.LinesTest do
  use ExUnit.Case, async: true
  alias LastTenYards.{Checkout, Store.Rules}

  @lines Path.expand("../../priv/lines.json", __DIR__) |> File.read!() |> Checkout.catalog()

  test "the lines file is valid: every line passes, no slug twice" do
    assert Rules.lines_file_errors(@lines) == []
  end

  test "every line the vault names is in the file — the 13 roots and the marks" do
    slugs = Enum.map(@lines, & &1["slug"])
    for s <- ~w(resume-writing curriculum-design tesla-rideshare tesla-semi pharmacology nursing landlord medical-detox
               robotics-elderly-care armored-training last-ten-yards breadcrumb-trail ribbon
               ride-at-closing pharmadash robolife kingfisher joshua-says), do: assert(s in slugs, s)
  end

  test "every line says where the record names it" do
    for l <- @lines, do: assert(l["source"] =~ ~r/^(50_Ribbon\/|30_Copyright\/|00_MIND\/(plans|next_steps)\/)/, l["slug"])
  end

  test "positions are 0..n-1, so the directory order is fixed" do
    assert Enum.map(@lines, & &1["position"]) == Enum.to_list(0..(length(@lines) - 1))
  end

  test "never-file names (someone else's brand) are not lines" do
    names = Enum.map_join(@lines, " ", &String.downcase(&1["name"]))
    for bad <- ["cybervan", "tesla hog", "tesla tile", "tesla osprey", "uber arbitrage", "golden goose"], do: refute(names =~ bad, bad)
  end

  for {l, why} <- [{%{"slug" => "Bad", "name" => "X"}, "slug"}, {%{"slug" => "ok", "name" => ""}, "name"},
                   {%{"slug" => "ok", "name" => "X", "tagline" => String.duplicate("a", 161)}, "tagline"}] do
    test "a line with a bad #{why} is refused" do
      assert [{unquote(why), _}] = Rules.line_errors(unquote(Macro.escape(l)))
    end
  end

  test "a duplicate slug in the file is caught" do
    assert {:duplicate, "a"} in Rules.lines_file_errors([%{"slug" => "a", "name" => "A"}, %{"slug" => "a", "name" => "B"}])
  end

  test "adding line 25 is one row, no code" do
    more = @lines ++ [%{"slug" => "new-line", "name" => "New Line", "tagline" => "one row", "position" => length(@lines)}]
    assert Rules.lines_file_errors(more) == []
  end
end
