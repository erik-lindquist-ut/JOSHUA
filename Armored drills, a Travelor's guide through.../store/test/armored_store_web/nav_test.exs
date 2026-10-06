defmodule ArmoredStoreWeb.NavTest do
  @moduledoc """
  School > Program > Course navigation (priv/PROGRAMS.json), the Armored Fail Fast set (#865-#869) as its own home
  section, the Originals, breadcrumbs on every book page, and no course number anywhere.
  """
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.{Catalog, Programs, Previews}

  @books ".."
  @code ~r/\b(?:[A-Z]\d{3}|[A-Z]{3}\d)\b/
  @fail_fast [
    {"armored-fail-fast-1-the-pre-assessment", "The Pre-Assessment", "Take it before you feel ready."},
    {"armored-fail-fast-2-the-performance-assessment", "The Performance Assessment", "The rubric is the answer key you're allowed to see."},
    {"armored-fail-fast-3-the-objective-assessment", "The Objective Assessment", "Take it and see what happens."},
    {"armored-fail-fast-4-the-punch-list", "The Punch List", "Check it off."},
    {"armored-fail-fast-5-the-adventure-guide", "The Adventure Guide", "The breadcrumb trail, and where it leads."}
  ]
  # Book 4 is a placeholder slot (Erik, 2026-09-29): same slug and place, title "Book 4: coming soon", no cover, no
  # preview, no book file; the set still counts five books. The other four books' own tables still list "The Punch List".
  @placeholder "armored-fail-fast-4-the-punch-list"
  @real_ff Enum.reject(@fail_fast, fn {s, _, _} -> s == @placeholder end)
  @seven "armored-accounting-for-decision-making"

  setup do
    Catalog.seed_store("priv/KDP_LISTINGS.json", "priv/STORE_ADDITIONS.json")
    :ok
  end

  defp doc(path), do: build_conn() |> get(path) |> html_response(200) |> Floki.parse_document!()
  defp ids(d, sel \\ "li.card"), do: d |> Floki.find(sel) |> Enum.flat_map(&Floki.attribute(&1, "id"))
  defp crumbs(d), do: d |> Floki.find(~s{nav.crumbs[aria-label="Breadcrumb"] > *:not(.sep)}) |> Enum.map(&Floki.text/1)
  defp crumb_links(d), do: Floki.attribute(d, ~s(nav.crumbs[aria-label="Breadcrumb"] a), "href")

  describe "program data" do
    test "115 programs in four schools, slugs unique, each program's books unique and all in the store" do
      assert Programs.schools() == ~w(Business Technology Health Education)
      counts = Programs.all() |> Enum.frequencies_by(& &1.school)
      assert counts == %{"Business" => 22, "Technology" => 25, "Health" => 22, "Education" => 46}
      slugs = Enum.map(Programs.all(), & &1.slug)
      assert length(slugs) == length(Enum.uniq(slugs))
      for s <- Programs.schools(), do: assert(Programs.in_school(s) |> Enum.map(& &1.name) |> then(&(&1 == Enum.uniq(&1))))

      live = MapSet.new(Catalog.list_products(), & &1.slug)

      for p <- Programs.all() do
        books = Enum.flat_map(p.courses, & &1.books)
        assert books == Enum.uniq(books), p.slug
        assert Enum.all?(books, &(&1 in live)), p.slug
        assert p.slug =~ ~r/\A[a-z0-9]+(-[a-z0-9]+)*\z/
      end
    end

    test "every library book sits in at least one program of its own school; no \"Other courses\" are needed" do
      for p <- Catalog.list_products(), [s] = p.collections || [], s in Programs.schools() do
        assert Enum.any?(Programs.for_book(p.slug), fn {prog, _} -> prog.school == s end), p.slug
      end

      assert Enum.filter(Programs.all(), & &1.other?) == []
    end

    test "PROGRAMS.json and its README carry no course number; the README names the public source and its date" do
      for f <- ~w(priv/PROGRAMS.json priv/PROGRAMS_README.md), do: refute(File.read!(f) =~ @code, f)
      readme = File.read!("priv/PROGRAMS_README.md")
      assert readme =~ "https://www.wgu.edu/content/dam/wgu-65-assets/western-governors/documents/institutional-catalog/2026/catalog-september-2026.pdf"
      assert readme =~ "2026-09-25"
    end
  end

  describe "home" do
    test "Fail Fast first, then the four schools with program and book counts, then the Originals; no collection row" do
      d = doc("/")
      assert Floki.attribute(d, "main section", "id") == ~w(fail-fast schools originals)
      assert ids(d, "#fail-fast li.card") == Enum.map(@fail_fast, fn {s, _, _} -> "product-" <> s end)

      schools = Floki.find(d, "#schools li.school")
      assert Enum.flat_map(schools, &Floki.attribute(&1, "id")) == ~w(school-business school-technology school-health school-education)
      assert Floki.attribute(schools, "a", "href") == ~w(/schools/business /schools/technology /schools/health /schools/education)
      texts = Enum.map(schools, &(Floki.text(Floki.find(&1, ".name")) <> " " <> Floki.text(Floki.find(&1, ".counts"))))
      assert texts == ["Business 22 programs · 195 books", "Technology 25 programs · 199 books", "Health 22 programs · 177 books", "Education 46 programs · 286 books"]

      originals = Enum.take(Catalog.list_products(), 7) |> Enum.map(&("product-" <> &1.slug))
      assert ids(d, "#originals li.card") == originals
      assert List.last(originals) == "product-" <> @seven

      assert Floki.find(d, "#collections") == [] and Floki.find(d, "nav.collections") == []
      refute Floki.raw_html(d) =~ "?collection="
      assert Floki.find(d, ".all-link a") |> Floki.text() =~ "All books"
      assert Floki.find(d, ".all-link .count") |> Floki.text() == "869"
      assert length(ids(d)) == 12
    end

    test "the old collection filter is gone: ?collection= changes nothing, and All books lists all 869" do
      assert ids(doc("/?collection=education")) == ids(doc("/"))
      assert length(ids(doc("/books"))) == 869
    end
  end

  describe "school and program pages" do
    test "a school page lists its programs in catalog order, each with its course count" do
      for s <- Programs.schools() do
        d = doc("/schools/" <> Programs.school_slug(s))
        assert crumbs(d) == ["Home", s]
        progs = Programs.in_school(s)
        assert Floki.attribute(d, "#programs li.program a", "href") == Enum.map(progs, &("/programs/" <> &1.slug))
        for p <- progs, do: assert(Floki.find(d, "#program-#{p.slug}") |> Floki.text() =~ "#{length(p.courses)} courses")
      end

      assert build_conn() |> get("/schools/nursing") |> html_response(404) =~ "Not found"
    end

    test "every program page shows its courses' books as cards in program-guide order, with lazy covers and 'Price not set'" do
      for p <- Programs.all() do
        d = doc("/programs/" <> p.slug)
        assert crumbs(d) == ["Home", p.school, p.name], p.slug
        assert ids(d) == Enum.map(Programs.books(p), &("product-" <> &1)), p.slug
        assert Floki.attribute(d, "li.card img", "loading") |> Enum.uniq() == ["lazy"]
        assert Floki.find(d, "li.card .price") |> Enum.map(&Floki.text/1) |> Enum.uniq() == ["Price not set"]
        assert Floki.attribute(d, "li.card a.card-link", "href") == Enum.map(Programs.books(p), &"/books/#{&1}?in=#{p.slug}")
      end

      assert build_conn() |> get("/programs/no-such-program") |> html_response(404) =~ "Not found"
    end

    test "B.S. Accounting starts with its first term's courses, in the guide's order" do
      d = doc("/programs/bs-accounting")
      titles = d |> Floki.find("li.card h2") |> Enum.take(4) |> Enum.map(&Floki.text/1)
      assert titles == ["Armored Organizational Behavior", "Armored Fundamentals for Success in Business",
                        "Armored Principles of Financial and Managerial Accounting", "Armored Composition: Successful Self-Expression"]
    end
  end

  describe "book pages" do
    test "every book page has breadcrumbs, and a book in several places lists them all as links" do
      for p <- Catalog.list_products() do
        d = doc("/books/" <> p.slug)
        c = crumbs(d)
        assert hd(c) == "Home", p.slug
        in_programs = Programs.for_book(p.slug)

        case in_programs do
          [] -> assert length(c) == 3, p.slug
          _ -> assert length(c) == 4, p.slug
        end

        places = length(in_programs) + Enum.count([Catalog.fail_fast(), Catalog.originals()], &(&1 in (p.collections || [])))
        listed = Floki.find(d, "#trails li")
        if places > 1, do: assert(length(listed) == places, p.slug), else: assert(listed == [], p.slug)

        for {prog, _} <- in_programs, places > 1 do
          assert Floki.attribute(d, ~s(#trails a[href="/programs/#{prog.slug}"]), "href") != [], "#{p.slug} #{prog.slug}"
        end
      end
    end

    test "a book's breadcrumb is School > Program > Course, its own school first, or the program it was reached from" do
      [{first, course} | _] = Programs.for_book("armored-organizational-behavior")
      d = doc("/books/armored-organizational-behavior")
      assert crumbs(d) == ["Home", first.school, first.name, course]
      assert crumb_links(d) == ["/", "/schools/" <> Programs.school_slug(first.school), "/programs/" <> first.slug]

      {other, _} = Programs.for_book("armored-organizational-behavior") |> List.last()
      d = doc("/books/armored-organizational-behavior?in=" <> other.slug)
      assert Enum.slice(crumbs(d), 1, 2) == [other.school, other.name]

      # an Education course reached from nowhere shows an Education program first, not a Business one
      {slug, _} = Enum.find(Enum.map(Catalog.list_products(), &{&1.slug, &1.collections}), fn {_, c} -> c == ["Education"] end)
      assert doc("/books/" <> slug) |> crumbs() |> Enum.at(1) == "Education"
    end

    test "a course in several programs (and schools) is a card on each of those program pages, and its page links them all" do
      {slug, progs} =
        Catalog.list_products()
        |> Enum.map(&{&1.slug, Enum.map(Programs.for_book(&1.slug), fn {p, _} -> p end)})
        |> Enum.max_by(fn {_, ps} -> length(ps) end)

      assert length(progs) > 20
      assert progs |> Enum.map(& &1.school) |> Enum.uniq() |> length() == 4

      for p <- progs, do: assert(ids(doc("/programs/" <> p.slug)) |> Enum.member?("product-" <> slug), p.slug)

      d = doc("/books/" <> slug)
      hrefs = Floki.attribute(d, "#trails a", "href")
      for p <- progs, do: assert("/programs/" <> p.slug in hrefs)
      assert Floki.find(d, ".trails-label") |> Floki.text() =~ "Listed in #{length(progs)} places"
    end

    test "#7 sits with Accounting for Decision Makers in the three MBA programs, after that course's drill, and in Originals" do
      progs = Programs.for_book(@seven) |> Enum.map(fn {p, c} -> {p.name, c} end)
      assert progs == [{"Master of Business Administration", "Accounting for Decision Makers"},
                       {"MBA Information Technology Management", "Accounting for Decision Makers"},
                       {"MBA Healthcare Administration", "Accounting for Decision Makers"}]

      for {name, _} <- progs do
        p = Enum.find(Programs.all(), &(&1.name == name))
        i = ids(doc("/programs/" <> p.slug))
        assert Enum.find_index(i, &(&1 == "product-" <> @seven)) == Enum.find_index(i, &(&1 == "product-armored-accounting-for-decision-makers")) + 1
      end

      d = doc("/books/" <> @seven)
      assert Floki.attribute(d, "#trails a", "href") |> Enum.member?("/#originals")
      assert length(Floki.find(d, "#trails li")) == 4
    end
  end

  describe "Armored Fail Fast" do
    test "five products, #865-#869 in book order, at 'Price not set', in the Armored Fail Fast collection" do
      ps = Catalog.list_products()
      assert length(ps) == 869
      ff = Enum.slice(ps, 864, 5)
      assert Enum.map(ff, & &1.slug) == Enum.map(@fail_fast, &elem(&1, 0))

      for {p, {slug, title, tagline}} <- Enum.zip(ff, @fail_fast) do
        if slug == @placeholder do
          assert p.title == "Book 4: coming soon"
          assert p.subtitle == nil and p.cover == nil
        else
          assert p.title == "Armored Fail Fast: " <> title
          assert p.subtitle == tagline
        end

        assert p.cents == nil
        assert p.collections == ["Armored Fail Fast"]
        refute Programs.placed?(p.slug)
      end
    end

    test "Book 4 is a placeholder: no book file, no cover, no preview, no example, no buy button; still in the set of five" do
      e = "priv/STORE_ADDITIONS.json" |> File.read!() |> Jason.decode!() |> Enum.find(&(ArmoredStore.Listings.slug(&1) == @placeholder))
      assert e["title"] == "Book 4: coming soon"
      refute Map.has_key?(e, "manuscript") or Map.has_key?(e, "cover")
      refute File.exists?(Path.join(@books, "Armored Fail Fast - The Punch List (book, V1)"))
      refute File.exists?(Path.join(@books, "Cover — Fail Fast - The Punch List"))
      refute File.exists?("priv/static/images/covers/Armored_Fail_Fast_4_The_Punch_List_cover.jpg")
      assert Previews.get(@placeholder) == nil

      d = doc("/books/" <> @placeholder)
      assert crumbs(d) == ["Home", "Armored Fail Fast", "Book 4: coming soon"]
      assert Floki.find(d, "#preview") == [] and Floki.find(d, "img.cover") == [] and Floki.find(d, "#example") == []
      assert Floki.find(d, "form") == [] and Floki.find(d, "button") == []
      refute Floki.text(d) =~ "Punch List"
      assert build_conn() |> get("/books/#{@placeholder}/example") |> response(404)
      assert build_conn() |> get("/images/covers/Armored_Fail_Fast_4_The_Punch_List_cover.jpg") |> response(404)
      assert length(Catalog.in_collection(Catalog.list_products(), Catalog.fail_fast())) == 5
    end

    test "each has its folder with the PDF and a README, a cover folder, a served cover, and no buy button" do
      for {slug, title, _} <- @real_ff do
        e = "priv/STORE_ADDITIONS.json" |> File.read!() |> Jason.decode!() |> Enum.find(&(ArmoredStore.Listings.slug(&1) == slug))
        [dir, file] = String.split(e["manuscript"], "/")
        assert dir == "Armored Fail Fast - #{title} (book, V1)"
        assert File.regular?(Path.join([@books, dir, file])) and String.ends_with?(file, ".pdf")
        assert File.read!(Path.join([@books, dir, "README.md"])) =~ "# " <> dir
        [cdir, cfile] = String.split(e["cover"], "/")
        assert cdir == "Cover — Fail Fast - #{title}"
        assert File.regular?(Path.join([@books, cdir, cfile])) and File.regular?(Path.join([@books, cdir, "README.md"]))
        assert build_conn() |> get("/images/covers/" <> cfile) |> response(200)

        d = doc("/books/" <> slug)
        assert crumbs(d) == ["Home", "Armored Fail Fast", "Armored Fail Fast: " <> title]
        assert crumb_links(d) == ["/", "/#fail-fast"]
        assert Floki.text(d) =~ "Price not set"
        assert Floki.find(d, "form") == [] and Floki.find(d, "button") == []
      end
    end

    test "each preview is the book's 'What this is' paragraph and its five-book table, word for word" do
      for {slug, title, _} <- @real_ff do
        pv = Previews.get(slug)
        assert pv.section == "What this is"
        assert [%{kind: "p"} | rows] = pv.paragraphs
        assert length(rows) == 6 and Enum.all?(rows, &(&1.kind == "row"))
        assert hd(rows).cells == ["Book", "Title", "What it does"]
        assert Enum.map(tl(rows), &Enum.at(&1.cells, 1)) == Enum.map(@fail_fast, &elem(&1, 1))
        assert pv.source =~ "Armored Fail Fast - #{title} (book, V1)/"

        d = doc("/books/" <> slug)
        assert Floki.find(d, "#preview h2") |> Floki.text() == "What this is"
        assert Floki.find(d, "#preview table.book-table tbody tr") |> length() == 5
        assert Floki.find(d, "#preview table.book-table tbody tr:first-child td") |> Enum.map(&Floki.text/1) == ["1", "The Pre-Assessment", "Fail fast on the practice exam."]
      end

      assert hd(Previews.get("armored-fail-fast-1-the-pre-assessment").paragraphs).text ==
               "How to use a practice exam as a diagnosis instead of a score: take it early, think aloud, sort every item by confidence, name the trap, fix the principle, armor it, re-measure."
    end

    test "Book 2 links its example, the invented vendor recommendation memo, which is served as a PDF; nothing else is" do
      slug = "armored-fail-fast-2-the-performance-assessment"
      d = doc("/books/" <> slug)
      assert Floki.find(d, "#example a") |> Floki.text() == "Example: a vendor recommendation memo"
      assert Floki.attribute(d, "#example a", "href") == ["/books/#{slug}/example"]

      c = build_conn() |> get("/books/#{slug}/example")
      assert c.status == 200
      assert c |> get_resp_header("content-type") |> hd() =~ "application/pdf"
      assert String.starts_with?(c.resp_body, "%PDF")
      memo = Path.join([@books, "Armored Fail Fast - The Performance Assessment (book, V1)", "example_rubric_self_audit.pdf"])
      assert c.resp_body == File.read!(memo)
      assert File.read!("priv/examples/example_rubric_self_audit.pdf") == File.read!(memo)

      for {other, _, _} <- @fail_fast, other != slug do
        assert Floki.find(doc("/books/" <> other), "#example") == []
        assert build_conn() |> get("/books/#{other}/example") |> response(404)
      end

      for p <- ["/books/armored-servicenow-itsm/example", "/books/no-such-book/example", "/examples/example_rubric_self_audit.pdf",
                "/example_rubric_self_audit.pdf", "/priv/examples/example_rubric_self_audit.pdf"] do
        assert build_conn() |> get(p) |> response(404), p
      end
    end
  end

  test "no course number on the home page, All books, any school or program page, or any book page" do
    pages =
      ["/", "/books"] ++
        Enum.map(Programs.schools(), &("/schools/" <> Programs.school_slug(&1))) ++
        Enum.map(Programs.all(), &("/programs/" <> &1.slug)) ++ Enum.map(Catalog.list_products(), &("/books/" <> &1.slug))

    for path <- pages do
      html = build_conn() |> get(path) |> html_response(200)
      refute html =~ @code, "#{path}: #{inspect(Regex.run(@code, html))}"
    end
  end

  test "slugs are unique across products and programs, and product positions are unique" do
    ps = Catalog.list_products()
    assert length(Enum.uniq_by(ps, & &1.slug)) == length(ps)
    assert length(Enum.uniq_by(ps, & &1.position)) == length(ps)
    assert length(Enum.uniq_by(ps, & &1.title)) == length(ps)
    assert MapSet.disjoint?(MapSet.new(ps, & &1.slug), MapSet.new(Programs.all(), & &1.slug))
  end
end
