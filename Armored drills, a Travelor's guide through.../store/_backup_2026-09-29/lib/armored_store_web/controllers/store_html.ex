defmodule ArmoredStoreWeb.StoreHTML do
  use ArmoredStoreWeb, :html
  embed_templates "store_html/*"

  def price(%{cents: c}) when is_integer(c) and c > 0, do: "$" <> :erlang.float_to_binary(c / 100, decimals: 2)
  def price(_), do: "Price not set"

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
        <span class="cue">Read the preview →</span>
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
        </header>
        {render_slot(@inner_block)}
        <footer class="site">
          <p>Payments run on Stripe. Card numbers never touch this site.</p>
        </footer>
      </body>
    </html>
    """
  end
end
