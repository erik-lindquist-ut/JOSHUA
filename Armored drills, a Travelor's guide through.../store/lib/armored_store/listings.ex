defmodule ArmoredStore.Listings do
  @moduledoc """
  Reads Erik's KDP listing data (priv/KDP_LISTINGS.json, a verbatim copy of
  "KDP listing sheet + JSON/KDP_LISTINGS.json") into product attributes.

  Prices come only from each record's `price_usd`. A record without a usable
  price gets `cents: nil`: the store shows "Price not set" and offers no buy button.
  """

  @source "KDP_LISTINGS.json"

  def decode(text) do
    case Jason.decode(text || "") do
      {:ok, list} when is_list(list) -> {:ok, list}
      {:ok, _} -> {:error, :not_a_list}
      {:error, _} = e -> e
    end
  end

  @doc "Listing text → product attribute maps, in listing order."
  def products(text) do
    {:ok, list} = decode(text)
    list |> Enum.with_index() |> Enum.map(fn {entry, i} -> to_attrs(entry, i) end)
  end

  def to_attrs(entry, index) do
    cents = cents(entry["price_usd"])

    %{
      "slug" => slug(entry),
      "title" => entry["title"],
      "subtitle" => entry["subtitle"],
      "author" => entry["author"],
      "series" => entry["series"],
      "edition" => entry["edition"],
      "description" => entry["description"],
      "cover" => cover(entry),
      "cents" => cents,
      "price_source" => if(cents, do: "#{@source} [#{index}] price_usd"),
      "position" => index
    }
  end

  @doc "A positive dollar amount → cents. Anything else → nil (no price)."
  def cents(n) when is_integer(n) and n > 0, do: n * 100
  def cents(n) when is_float(n) and n > 0, do: round(n * 100)
  def cents(_), do: nil

  def slug(%{"manuscript" => m}) when is_binary(m) and m != "", do: m |> Path.basename() |> Path.rootname() |> slugify()
  def slug(%{"title" => t}) when is_binary(t), do: slugify(t)

  def slugify(s), do: s |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, "-") |> String.trim("-")

  def cover(%{"cover" => c}) when is_binary(c) and c != "", do: Path.basename(c)
  def cover(_), do: nil

  @doc "Whole sentences from the start of the description, until about a line long."
  def short(nil), do: ""

  def short(text) do
    text
    |> String.split(~r/(?<=[.!?])\s+/, trim: true)
    |> Enum.reduce_while("", fn s, acc ->
      acc = if acc == "", do: s, else: acc <> " " <> s
      if String.length(acc) >= 80, do: {:halt, acc}, else: {:cont, acc}
    end)
  end
end
