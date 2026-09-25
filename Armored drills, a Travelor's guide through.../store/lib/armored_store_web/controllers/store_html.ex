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
        <title>{@title} · Joshua Says</title>
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="stylesheet" href="/assets/store.css" />
      </head>
      <body>
        <header class="site">
          <a class="brand" href="/">Joshua Says</a>
          <span class="tagline">Armored drills and The Traveler's Guide</span>
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
