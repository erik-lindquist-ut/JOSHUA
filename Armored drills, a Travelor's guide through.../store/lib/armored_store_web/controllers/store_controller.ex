defmodule ArmoredStoreWeb.StoreController do
  use ArmoredStoreWeb, :controller
  alias ArmoredStore.{BookFiles, Bundles, Catalog, Checkout, Docs, Examples, Programs, ProjectTree}

  @doc """
  Home: project tree + WGU handoff docs first, then the Armored Fail Fast set, the four schools,
  the Originals, and any book no program or section reaches. The full list is /books.
  """
  def index(conn, _params) do
    all = Catalog.list_products()
    sections = [Catalog.fail_fast(), Catalog.originals() | Programs.schools()]

    others = Enum.reject(all, fn p -> Programs.placed?(p.slug) or Enum.any?(sections, &(&1 in (p.collections || []))) end)

    schools =
      for s <- Programs.schools(),
          do: %{name: s, slug: Programs.school_slug(s), programs: Programs.program_count(s), books: length(Catalog.in_collection(all, s))}

    page(conn, :index,
      all: all,
      tree: ProjectTree.lines(),
      readme: Docs.readme(),
      technical: Docs.technical(),
      fail_fast: Catalog.in_collection(all, Catalog.fail_fast()),
      originals: Catalog.in_collection(all, Catalog.originals()),
      schools: schools,
      others: others
    )
  end

  @doc "Every book, in listing order."
  def books(conn, _params), do: page(conn, :books, products: Catalog.list_products())

  def docs_readme(conn, _params), do: page(conn, :docs, doc: Docs.readme(), kind: :readme)
  def docs_technical(conn, _params), do: page(conn, :docs, doc: Docs.technical(), kind: :technical)

  @doc "Per-drill file inventory (names/paths). Only the labeled handoff PDF is downloadable."
  def files(conn, %{"slug" => slug}) do
    case Catalog.get_product(slug) do
      nil ->
        missing(conn)

      product ->
        inv = BookFiles.for_slug(slug) || %{slug: slug, title: product.title, manuscript: nil, files: []}
        page(conn, :files, product: product, inventory: inv)
    end
  end

  @doc "A school: its programs, then its \"Other courses\" if it has any."
  def school(conn, %{"school" => slug}) do
    case Programs.school_by_slug(slug) do
      nil ->
        notice(conn, 404, "Not found", "There is no such school in this store.", nil)

      s ->
        all = Catalog.list_products()
        live = MapSet.new(all, & &1.slug)
        programs = for p <- Programs.in_school(s), do: Map.put(p, :book_count, p |> Programs.books() |> Enum.count(&(&1 in live)))
        page(conn, :school, school: s, programs: programs, program_count: Programs.program_count(s), book_count: length(Catalog.in_collection(all, s)))
    end
  end

  @doc "A program: its courses' books in program-guide order."
  def program(conn, %{"slug" => slug}) do
    case Programs.get(slug) do
      nil -> notice(conn, 404, "Not found", "There is no such program in this store.", nil)
      p -> page(conn, :program, program: p, products: Catalog.list_by_slugs(Programs.books(p)))
    end
  end

  def show(conn, %{"slug" => slug} = params) do
    case Catalog.get_product(slug) do
      nil ->
        missing(conn)

      p ->
        trails = trails(p, params["in"])
        bundle = if Bundles.bundle?(p), do: Bundles.shared_books(), else: []
        page(conn, :show, product: p, trails: trails, bundle: bundle, example: Examples.get(p.slug), preview: ArmoredStore.Previews.get(p.slug), token: get_csrf_token())
    end
  end

  @doc "The one free example a book page may link to (Book 2 of the Fail Fast set). Everything else is a 404."
  def example(conn, %{"slug" => slug}) do
    with %{} = ex <- Examples.get(slug), %{} <- Catalog.get_product(slug), true <- File.regular?(Examples.path(ex)) do
      conn
      |> put_resp_content_type("application/pdf")
      |> put_resp_header("content-disposition", ~s(inline; filename="#{ex.filename}"))
      |> send_file(200, Examples.path(ex))
    else
      _ -> not_found(conn, %{})
    end
  end

  # Every path to a book: School > Program > Course for each program it is in, then its home-page section (Armored
  # Fail Fast, Originals). First comes the program named by ?in= (the program page the reader came from), then the
  # programs of the book's own school (the library catalog's school), then the rest, each group in catalog order.
  # Each trail is a list of {label, href}; the last is the course (or, for a section, the book).
  defp trails(p, from) do
    programs =
      for {prog, course} <- Programs.for_book(p.slug),
          do: {prog.slug, [{"Home", "/"}, {prog.school, "/schools/" <> Programs.school_slug(prog.school)}, {prog.name, "/programs/" <> prog.slug}, {course, nil}]}

    own = p.collections || []
    programs = Enum.sort_by(programs, fn {ps, [_, {school, _} | _]} -> {ps != from, school not in own} end)

    sections =
      for {c, anchor} <- [{Catalog.fail_fast(), "fail-fast"}, {Catalog.originals(), "originals"}], c in (p.collections || []),
          do: [{"Home", "/"}, {c, "/#" <> anchor}, {p.title, nil}]

    Enum.map(programs, &elem(&1, 1)) ++ sections
  end

  def checkout(conn, %{"slug" => slug}) do
    case Catalog.get_product(slug) do
      nil ->
        missing(conn)

      p ->
        case Checkout.create(p, base_url(conn), System.get_env("STRIPE_SECRET_KEY"), &stripe_post/1) do
          {:ok, url} ->
            redirect(conn, external: url)

          {:error, :not_configured} ->
            notice(conn, 200, "Checkout not configured",
              "Online checkout is not configured on this store yet, so this title cannot be bought here right now. No payment was taken.", p)

          {:error, :no_price} ->
            notice(conn, 422, "Price not set", "This title has no price set yet, so it cannot be bought. No payment was taken.", p)

          {:error, _why} ->
            notice(conn, 502, "Checkout could not start", "Stripe did not open a checkout page. No payment was taken. Please try again later.", p)
        end
    end
  end

  @doc """
  Stripe sends the buyer here with ?session_id={CHECKOUT_SESSION_ID} (see Checkout.params/2).
  Only a Stripe checkout session id ("cs_...") says the order is in; the id is never shown.
  The order itself is recorded only by the signed webhook, not by this page.
  """
  def thanks(conn, params), do: page(conn, :thanks, order?: checkout_session?(params["session_id"]))

  def not_found(conn, _params), do: conn |> put_resp_content_type("text/plain") |> send_resp(404, "Not found.")

  defp checkout_session?(id) when is_binary(id), do: Regex.match?(~r/\Acs_[A-Za-z0-9_]{1,255}\z/, id)
  defp checkout_session?(_), do: false

  defp missing(conn), do: notice(conn, 404, "Not found", "There is no such title in this store.", nil)

  defp notice(conn, status, heading, message, product),
    do: conn |> put_status(status) |> page(:notice, heading: heading, message: message, product: product)

  defp page(conn, template, assigns), do: conn |> put_root_layout(false) |> render(template, assigns)

  defp base_url(conn), do: "#{conn.scheme}://#{conn.host}" <> if(conn.port in [80, 443], do: "", else: ":#{conn.port}")

  defp stripe_post(req) do
    {m, f} = Application.get_env(:armored_store, :stripe_post, {Checkout, :http_post})
    apply(m, f, [req])
  end
end
