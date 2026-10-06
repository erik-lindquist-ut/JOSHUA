defmodule ArmoredStoreWeb.StoreHTML do
  use ArmoredStoreWeb, :html
  embed_templates "store_html/*"

  def price(%{cents: c}) when is_integer(c) and c > 0 do
    dollars = div(c, 100)
    cents = rem(c, 100) |> Integer.to_string() |> String.pad_leading(2, "0")
    "$" <> thousands(dollars) <> "." <> cents
  end

  def price(_), do: "Price not set"

  defp thousands(n) when n < 1000, do: Integer.to_string(n)
  defp thousands(n) do
    {rest, last} = {div(n, 1000), rem(n, 1000)}
    thousands(rest) <> "," <> (last |> Integer.to_string() |> String.pad_leading(3, "0"))
  end

  def buyable?(%{cents: c}), do: is_integer(c) and c > 0
  def buyable?(_), do: false

  def cover_url(%{cover: c}) when is_binary(c) and c != "", do: "/images/covers/" <> c
  def cover_url(_), do: nil

  def short(p), do: ArmoredStore.Listings.short(p.description)

  def plural(1, one, _many), do: "1 #{one}"
  def plural(n, _one, many), do: "#{n} #{many}"

  @doc "A book as a card: cover (lazy), title, by-line, short description, price. `from` is the program it is listed in."
  attr :product, :map, required: true
  attr :from, :string, default: nil

  def book_card(assigns) do
    ~H"""
    <li class="card" id={"product-#{@product.slug}"}>
      <a class="card-link" href={"/books/#{@product.slug}" <> if(@from, do: "?in=#{@from}", else: "")}>
        <img :if={cover_url(@product)} src={cover_url(@product)} alt={"Cover of #{@product.title}"} width="200" height="320" loading="lazy" />
        <h2>{@product.title}</h2>
        <p class="by">by {@product.author}</p>
        <p class="short">{short(@product)}</p>
        <p :if={ArmoredStore.Bundles.bundle?(@product)} class="bundle-line">{ArmoredStore.Bundles.line()}</p>
        <p class={["price", !buyable?(@product) && "unset"]}>{price(@product)}</p>
        <%!-- a placeholder slot (no cover, no preview; e.g. Fail Fast Book 4) says so instead of offering a preview --%>
        <span class="cue">{if @product.cover, do: "Read the preview →", else: "Coming soon"}</span>
      </a>
    </li>
    """
  end

  @doc "A breadcrumb trail: [{label, href}], the last one the current page (href nil)."
  attr :trail, :list, required: true
  attr :primary, :boolean, default: true

  def crumbs(assigns) do
    ~H"""
    <nav class="crumbs" aria-label={if @primary, do: "Breadcrumb", else: nil}>
      <%= for {{label, href}, i} <- Enum.with_index(@trail) do %><span :if={i > 0} class="sep" aria-hidden="true"> › </span><a :if={href} href={href}>{label}</a><span :if={!href} aria-current={@primary && "page"}>{label}</span><% end %>
    </nav>
    """
  end

  @doc "The full HTML document every page renders inside."
  attr :title, :string, required: true
  slot :inner_block, required: true

  def page(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>{@title} · Armored drills</title>
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="stylesheet" href="/assets/store.css" />
      </head>
      <body>
        <header class="site">
          <a class="brand" href="/">Armored drills</a>
          <span class="tagline">and The Traveler's Guide, by Joshua</span>
          <nav class="site-nav" aria-label="Docs">
            <a href="/#project-tree">Tree</a>
            <a href="/docs/readme">README</a>
            <a href="/docs/technical">TECHNICAL</a>
            <a href="/books">Books</a>
          </nav>
        </header>
        {render_slot(@inner_block)}
        <footer class="site">
          <p>Payments run on Stripe. Card numbers never touch this site.</p>
          <p>Course material © WGU, gifted by the author.</p>
        </footer>
      </body>
    </html>
    """
  end
end
