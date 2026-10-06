defmodule ArmoredStoreWeb.EducationTest do
  @moduledoc """
  Products #579 on: the Education shelf of the Armored drills, added through priv/STORE_ADDITIONS.json after the
  Health drills, the same way, in the Education collection. Data-driven over every Education addition. None is priced;
  each previews its opening section, "How to run it", from its own PDF. Titles that repeat (inside Education, or a title
  already in the store from another shelf) carry a short subtitle: one of the book's own concepts. No Education book is
  the same book as one already in the store (no identical PDF, no identical concept list), so none was folded into an
  existing product. No course number appears in any name, slug, listing or preview; every slug and folder is unique.
  """
  use ArmoredStoreWeb.ConnCase, async: false
  alias ArmoredStore.{Catalog, Listings, Previews}

  @books ".."
  @total 869
  @first 578
  @count 286
  # a course number (C200, D072, AFT2 style); CYP450, the enzyme family named in two Health books' concept lists, is not one
  @course ~r/(^|[^A-Za-z0-9])(?!CYP450(?![A-Za-z0-9]))([A-Za-z]{1,3}\d{3}|[A-Za-z]{3}\d)([^A-Za-z0-9]|$)/
  @subtitled %{
    "Advanced Calculus" => ["Heine-Borel Compactness", "Riemann Integrability"],
    "Advanced Clinical in Elementary Education" => ["Academic Language Demands", "Backward Design"],
    "Advanced Clinical in Secondary Education" => ["Restorative Conversations", "Scaffolding and Fading"],
    "Advanced Clinical in Special Education" => ["PBIS Tiers", "Task Analysis"],
    "Algebra for Secondary Mathematics Teaching" => ["Equivalent Expressions", "Historical Stages of Algebra", "Logarithms Undo Exponentials"],
    "Assessment for Special Education" => ["Curriculum-Based Measurement", "Identifying Specific Learning Disabilities"],
    "Astronomy" => ["Light-Years and Lookback Time", "Parallax Distance"],
    "Behavioral Intervention Strategies and Applied Behavior Analysis" => ["Functions of Behavior", "The Premack Principle"],
    "Calculus I" => ["Continuity at a Point", "Equation of the Tangent Line", "Implicit Differentiation"],
    "Calculus II" => ["Integration by Parts", "Separable Differential Equations"],
    "College Algebra" => ["Quadratic Vertex", "Remainder Theorem"],
    "Considerations for Instructional Planning for Learners" => ["Instructional Hierarchy", "Programming for Generalization"],
    "Early Clinical in Elementary Education" => ["Behavior-Specific Praise", "Withitness and Overlapping"],
    "Early Clinical in Secondary Education" => ["Bell-to-Bell Routines", "The Warm Demander Stance"],
    "Early Clinical in Special Education" => ["Least Restrictive Environment", "Objective Observation Notes"],
    "Early Literacy Methods" => ["Decodable Texts", "The Phonological Awareness Continuum"],
    "Early Mathematics Methods and Interventions" => ["Conservation of Number", "Make-Ten Strategy"],
    "Elementary Disciplinary Literacy" => ["Reading Data Displays", "Reading Like a Historian"],
    "Elementary Fine Arts Methods" => ["Color Relationships", "The Four Artistic Processes"],
    "Elementary Health and Physical Education Methods" => ["Fundamental Movement Categories", "Physical Activity Guidelines for Children"],
    "Elementary Literacy Curriculum" => ["Purposeful Writing Process", "Syllable Types"],
    "Elementary Literacy Methods" => ["Morphology for Multisyllabic Words", "Types of Context Clues"],
    "Elementary Literacy and Mathematics Strategies and Assistive Technologies" => ["Repeated Reading for Fluency", "Schema-Based Word-Problem Instruction"],
    "Elementary Mathematics Curriculum" => ["Classifying Shapes by Hierarchy", "Converting Measurement Units"],
    "Elementary Mathematics Methods and Interventions" => ["Area Model and Partial Products", "Productive Talk Moves"],
    "Elementary Science Curriculum" => ["Day and Night", "Moon Phases"],
    "Elementary Science and Engineering Methods" => ["Iterative Design", "The 5E Sequence"],
    "Elementary Social Studies Curriculum" => ["Sourcing and Corroboration", "The NCSS Thematic Strands"],
    "Elementary Social Studies Methods" => ["Beyond Heroes and Holidays", "Multiple Causation"],
    "Foundations of Literacy Through Literature" => ["Prompting for Word Reading", "Traditional Literature Subgenres"],
    "General Chemistry II with Lab" => ["Limiting Reactant", "Rate Laws and Reaction Order"],
    "General Secondary Methods" => ["Identity Formation", "Self-Efficacy"],
    "Geometry for Secondary Mathematics Teaching" => ["Counterexamples and Proof", "Inscribed Angle Theorem", "Triangle Congruence Criteria"],
    "Individualized Education Plan (IEP) Collaboration and Communication with Parents and School Staff" => ["Procedural Safeguards Notice", "Two-Way Family Partnership"],
    "Integrated Physical Sciences" => ["Conservation of Momentum"],
    "Introduction to Biology" => ["X-Linked Inheritance"],
    "Laboratory Safety" => ["Chemical Waste Disposal", "Hierarchy of Controls"],
    "Linear Algebra" => ["Rank-Nullity Theorem", "Subspace Test"],
    "Literacy Assessment and Interventions" => ["Aim-Line Decision Rules", "Dyslexia and Structured Literacy"],
    "Methods of Teaching Secondary Mathematics" => ["Cognitive Demand of Tasks", "Humanizing Mathematics"],
    "Organic Chemistry" => ["Esterification", "Markovnikov Addition"],
    "Practicum in Educational Leadership" => ["Master Schedule Priorities", "Reflective Practice"],
    "Secondary Biology Curriculum" => ["Monohybrid Crosses", "Reproductive Isolation"],
    "Secondary Chemistry Curriculum" => ["Particle Diagrams as Assessment", "Weighted Average Atomic Mass"],
    "Secondary Disciplinary Literacy" => ["Contextualization in History", "Sourcing in History"],
    "Secondary Earth Science Curriculum" => ["Evidence for the Big Bang", "Sequencing by Prerequisites"],
    "Secondary Literacy Methods and Interventions" => ["Multisyllabic Word Reading", "Summarizing with GIST"],
    "Secondary Literacy and Mathematics Strategies and Assistive Technologies" => ["Four Accommodation Categories", "Reciprocal Teaching"],
    "Secondary Mathematics Curriculum" => ["Independent Events Multiply", "The Integral as Accumulation"],
    "Secondary Physics Curriculum" => ["Electromagnets", "Research Misconduct"],
    "Secondary Science Teaching Methods" => ["Hands-On Needs Minds-On", "Levels of Inquiry"],
    "Special Education Curriculum" => ["Executive Function Supports", "IDEA Disability Categories"],
    "Special Education Law, Policies and Procedures" => ["Key IDEA Timelines", "Stay-Put"],
    "Statistics for Secondary Mathematics Teaching" => ["Law of Large Numbers", "The Equiprobability Misconception"],
    "Student Teaching I in Elementary Education" => ["Developmentally Appropriate Instruction", "Flexible Grouping"],
    "Student Teaching I in Secondary Education" => ["Digital Equity", "Process Praise"],
    "Student Teaching I in Special Education" => ["Age-Respectful Materials", "Constant Time Delay"],
    "Student Teaching II in Elementary Education" => ["Student-Led Conferences", "Sustainable Self-Care"],
    "Student Teaching II in Secondary Education" => ["Curriculum Compacting", "Item Analysis"],
    "Student Teaching II in Special Education" => ["Burnout Warning Signs", "Manifestation Determination"],
    "Three Dimensional Science and Engineering" => ["Naming the Three Dimensions", "Testable Questions"]
  }

  defp kdp, do: "priv/KDP_LISTINGS.json" |> File.read!() |> Listings.products()
  defp adds, do: "priv/STORE_ADDITIONS.json" |> File.read!() |> Listings.additions(length(kdp()))
  defp raw_adds, do: "priv/STORE_ADDITIONS.json" |> File.read!() |> Jason.decode!()
  defp edu, do: adds() |> Enum.drop(@first - length(kdp())) |> Enum.take(@count)
  defp raw_edu, do: raw_adds() |> Enum.drop(@first - length(kdp())) |> Enum.take(@count)
  defp doc(conn, path), do: conn |> get(path) |> html_response(200) |> Floki.parse_document!()
  defp visible(d), do: Enum.join([Floki.text(d, sep: " ") | Floki.attribute(d, "href") ++ Floki.attribute(d, "src") ++ Floki.attribute(d, "alt")], "\n")
  defp norm(s), do: s |> String.downcase() |> String.replace(["’", "–", "—"], fn "’" -> "'"; _ -> "-" end)

  setup do
    Catalog.seed_store("priv/KDP_LISTINGS.json", "priv/STORE_ADDITIONS.json")
    :ok
  end

  test "286 Education titles follow the Health drills, at positions 578 to 863, in the series shape, with no price" do
    assert length(edu()) == @count
    assert length(kdp()) + length(adds()) == @total
    # Education is the last library shelf; only the five Armored Fail Fast books (#865-#869) come after it
    assert adds() |> Enum.drop(-5) |> List.last() == List.last(edu())
    assert adds() |> Enum.take(-5) |> Enum.map(& &1["collections"]) |> Enum.uniq() == [["Armored Fail Fast"]]

    for {p, i} <- Enum.with_index(edu(), @first) do
      assert p["position"] == i, p["slug"]
      assert p["collections"] == ["Education"], p["slug"]
      assert String.starts_with?(p["title"], "Armored "), p["title"]
      assert p["subtitle"] == "For people who already know the easy version."
      assert {p["author"], p["series"], p["edition"]} == {"Joshua", nil, "V1"}
      assert p["description"] =~ ~r/^\d+ disguised items, \d+ of them transfer items, across \w+ concepts: /, p["slug"]
      assert p["cents"] == nil and p["price_source"] == nil, p["slug"]
    end

    refute Enum.any?(raw_edu(), &Map.has_key?(&1, "price_usd"))
  end

  test "no Education book is already in the store: no two book files are identical and no two concept lists match" do
    # every addition but #7 (a .docx) and the Book 4 placeholder (#868, no book file) is a PDF
    pdfs = for e <- raw_adds(), String.ends_with?(e["manuscript"] || "", ".pdf"), do: e["manuscript"]
    assert length(pdfs) == length(raw_adds()) - 2
    hashes = Enum.map(pdfs, &:crypto.hash(:sha256, File.read!(Path.join(@books, &1))))
    assert hashes |> Enum.uniq() |> length() == length(pdfs)

    concepts = fn p -> p["description"] |> String.split(" concepts: ", parts: 2) |> List.last() |> String.split(". Every wrong answer") |> hd() |> norm() end
    lists = for p <- adds(), p["description"] =~ " concepts: ", do: concepts.(p)
    assert lists |> Enum.uniq() |> length() == length(lists)
  end

  test "every slug, title, book folder and cover folder is unique across the whole store" do
    all = kdp() ++ adds()
    assert length(all) == @total
    assert all |> Enum.map(& &1["slug"]) |> Enum.uniq() |> length() == @total
    assert all |> Enum.map(&String.downcase(&1["title"])) |> Enum.uniq() |> length() == @total
    assert all |> Enum.map(& &1["cover"]) |> Enum.uniq() |> length() == @total

    # every book addition (the Book 4 placeholder, #868, has no book or cover folder)
    books = Enum.filter(raw_adds(), &Map.has_key?(&1, "manuscript"))
    dirs = fn key -> books |> Enum.map(&(&1[key] |> String.split("/") |> hd() |> String.downcase())) end
    assert dirs.("manuscript") |> Enum.uniq() |> length() == length(books)
    assert dirs.("cover") |> Enum.uniq() |> length() == length(books)
  end

  test "repeated titles carry a short subtitle, one of the book's own concepts; titles from other shelves keep theirs" do
    for {base, subs} <- @subtitled do
      got = for p <- edu(), String.starts_with?(p["title"], "Armored #{base} - "), do: String.replace_prefix(p["title"], "Armored #{base} - ", "")
      assert Enum.sort(got) == subs, base
      refute Enum.any?(edu(), &(&1["title"] == "Armored #{base}")), base

      for s <- subs do
        refute s =~ ~r/\bv(ersion)?\s*\d/i, s
        p = Enum.find(edu(), &(&1["title"] == "Armored #{base} - #{s}"))
        assert norm(p["description"]) =~ norm(s), "#{s} is one of its own concepts"
        for o <- edu() -- [p], String.starts_with?(o["title"], "Armored #{base} - "), do: refute(norm(o["description"]) =~ ", " <> norm(s) <> ",")
      end
    end

    assert map_size(@subtitled) == 61
    assert @subtitled |> Map.values() |> List.flatten() |> length() == 123
    earlier = adds() |> Enum.take(@first - length(kdp())) |> Enum.map(& &1["title"])
    for t <- ["Armored Integrated Physical Sciences", "Armored Introduction to Biology", "Armored Calculus I - Definite Integrals", "Armored Calculus I - Linear Approximation"],
        do: assert(t in earlier, t)

    titles = Enum.map(edu(), & &1["title"])
    assert length(Enum.uniq(titles)) == @count
    earlier_down = Enum.map(earlier ++ Enum.map(kdp(), & &1["title"]), &String.downcase/1)
    for t <- titles, do: refute(String.downcase(t) in earlier_down, t)
  end

  test "each book file is filed in its own (book, V1) folder, its cover in a Cover folder and in the store's covers" do
    for {e, p} <- Enum.zip(raw_edu(), edu()) do
      [dir, file] = String.split(e["manuscript"], "/")
      assert dir =~ ~r/^Armored .+ \(book, V1\)$/, dir
      assert file =~ ~r/^Armored_[A-Za-z0-9_]+\.pdf$/, file
      assert e["cover"] =~ ~r/^Cover — [^\/:]+\/Armored_[A-Za-z0-9_]+_cover\.jpg$/, e["cover"]
      refute dir =~ ":", dir
      assert File.read!(Path.join(@books, e["manuscript"])) |> binary_part(0, 5) == "%PDF-", e["manuscript"]
      store = "priv/static/images/covers/" <> p["cover"]
      assert File.read!(store) == File.read!(Path.join(@books, e["cover"])), store
      readme = File.read!(Path.join(@books, dir <> "/README.md"))
      assert readme =~ "store product ##{p["position"] + 1}"
      assert readme =~ "Education shelf"
    end
  end

  test "titles with a colon or slash keep it in the store title and use a safe substitute in folder names" do
    unsafe = Enum.filter(raw_edu(), &(&1["title"] =~ ~r/[:\/]/))

    assert Enum.map(unsafe, & &1["title"]) |> Enum.sort() == [
      "Armored Biology: Content Knowledge",
      "Armored Chemistry: Content Knowledge",
      "Armored Earth Science: Content Knowledge",
      "Armored Earth: Inside and Out",
      "Armored Geology I: Physical",
      "Armored Geology II: Earth Systems",
      "Armored Graphing, Proportional Reasoning and Equations/Inequalities",
      "Armored Mathematics: Content Knowledge",
      "Armored Middle School Mathematics: Content Knowledge",
      "Armored Middle School Science: Content Knowledge",
      "Armored Physics: Content Knowledge",
      "Armored Physics: Electricity and Magnetism",
      "Armored Physics: Mechanics",
      "Armored Physics: Waves and Optics",
      "Armored Subject Specific Pedagogy: ELL",
      "Armored Technology and Ethics: A Look at Emerging Trends and Society"
           ]

    for e <- unsafe do
      name = e["title"] |> String.replace_prefix("Armored ", "") |> String.replace(": ", " - ") |> String.replace("/", "-")
      assert String.starts_with?(e["manuscript"], "Armored #{name} (book, V1)/"), e["manuscript"]
      assert String.starts_with?(e["cover"], "Cover — #{name}/"), e["cover"]
    end
  end

  test "each previews its opening section, How to run it, from its own PDF" do
    for p <- edu() do
      pv = Previews.get(p["slug"])
      assert pv, p["slug"]
      assert {pv.section, pv.kind} == {"How to run it", "opening section"}, p["slug"]
      assert Enum.map(pv.paragraphs, & &1.kind) == ["p"] ++ List.duplicate("li", 8) ++ ["p", "p"], p["slug"]
      assert String.ends_with?(pv.source, ".pdf") and File.regular?(Path.join(@books, pv.source)), pv.source
    end
  end

  test "no course number in any Education name, slug, file name, listing or preview" do
    for {e, p} <- Enum.zip(raw_edu(), edu()) do
      for v <- [p["title"], p["subtitle"], p["description"], p["slug"], p["cover"], e["manuscript"], e["cover"]],
          do: refute(v =~ @course, v)

      pv = Previews.get(p["slug"])
      for t <- [pv.section, pv.source | Enum.map(pv.paragraphs, & &1.text)], do: refute(t =~ @course, "#{p["slug"]}: #{t}")
    end
  end

  test "the Education school's programs show every Education card, linking to its page with its cover and 'Price not set'", %{conn: conn} do
    progs = ArmoredStore.Programs.in_school("Education")
    pages = Map.new(progs, &{&1.slug, doc(build_conn(), "/programs/" <> &1.slug)})
    for {_, d} <- pages, do: refute(visible(d) =~ @course, inspect(Regex.run(@course, visible(d))))

    for p <- edu() do
      {ps, d} = Enum.find(pages, fn {_, d} -> Floki.find(d, "#product-" <> p["slug"]) != [] end) || flunk("#{p["slug"]} is in no Education program")
      card = Floki.find(d, "#product-" <> p["slug"])
      assert Floki.attribute(card, "a.card-link", "href") == ["/books/#{p["slug"]}?in=#{ps}"]
      assert Floki.attribute(card, "img", "src") == ["/images/covers/" <> p["cover"]]
      assert Floki.attribute(card, "img", "loading") == ["lazy"]
      assert Floki.text(card) =~ "Price not set"
      refute Floki.text(card) =~ "$"
    end

    assert length(Floki.find(doc(conn, "/books"), "li.card")) == @total
  end

  test "each Education page shows its title, its school first in the breadcrumbs, no buy button, and How to run it as eight numbered steps" do
    for p <- edu() do
      d = doc(build_conn(), "/books/" <> p["slug"])
      assert Floki.find(d, "h1") |> Floki.text() == p["title"]
      assert Floki.find(d, ~s(nav.crumbs[aria-label="Breadcrumb"] a)) |> Enum.map(&Floki.text/1) |> Enum.take(2) == ["Home", "Education"]
      assert Floki.text(d) =~ "Price not set"
      assert Floki.find(d, "form") == [] and Floki.find(d, "button") == []
      preview = Floki.find(d, "#preview")
      assert Floki.text(preview) =~ "How to run it"
      assert length(Floki.find(preview, "ol li")) == 8, p["slug"]
      refute visible(d) =~ @course, "#{p["slug"]}: #{inspect(Regex.run(@course, visible(d)))}"
    end
  end
end
