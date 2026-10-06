defmodule ArmoredStore.Catalog do
  @moduledoc "The store's data: products (seeded from the KDP listing data) and orders Stripe has confirmed."
  import Ecto.Query
  alias ArmoredStore.{Listings, Repo}
  alias ArmoredStore.Catalog.{Order, Product}

  # A product's collections name the shelf it came from: its school for a library drill (Business, Technology,
  # Health, Education), "Originals" for #1-#7, which are not from the library, and "Armored Fail Fast" for that
  # five-book set. The home page shows the Fail Fast set and the Originals as their own sections and counts each
  # school's books by it; programs come from ArmoredStore.Programs.
  @fail_fast "Armored Fail Fast"
  @originals "Originals"

  def fail_fast, do: @fail_fast
  def originals, do: @originals

  @doc "The products in one collection, keeping their order."
  def in_collection(products, name), do: Enum.filter(products, &(name in (&1.collections || [])))

  @doc "Active products with these slugs, in the order the slugs are given (unknown slugs are skipped)."
  def list_by_slugs(slugs) when is_list(slugs) do
    found = from(p in Product, where: p.active and p.slug in ^slugs) |> Repo.all() |> Map.new(&{&1.slug, &1})
    slugs |> Enum.uniq() |> Enum.flat_map(&List.wrap(Map.get(found, &1)))
  end

  @doc "Active products, in listing order."
  def list_products, do: from(p in Product, where: p.active, order_by: [asc: p.position, asc: p.id]) |> Repo.all()

  def get_product(slug) when is_binary(slug), do: Repo.get_by(Product, slug: slug, active: true)
  def get_product(_), do: nil

  def upsert_product(attrs) do
    (Repo.get_by(Product, slug: attrs["slug"]) || %Product{})
    |> Product.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc "Load (or refresh) every product from a KDP listing JSON file. Safe to run again."
  def seed_from_listings(path) do
    path
    |> File.read!()
    |> Listings.products()
    |> Enum.map(fn attrs ->
      {:ok, p} = upsert_product(attrs)
      p
    end)
  end

  @doc """
  Load (or refresh) the whole store: the KDP listing products, then the store additions
  (priv/STORE_ADDITIONS.json) after them. Additions never carry a price. Safe to run again.
  """
  def seed_store(listings_path, additions_path) do
    listed = seed_from_listings(listings_path)

    added =
      additions_path
      |> File.read!()
      |> Listings.additions(length(listed))
      |> Enum.map(fn attrs ->
        {:ok, p} = upsert_product(attrs)
        p
      end)

    listed ++ added
  end

  @doc "Record a paid checkout. Stripe may send the same event twice; the second is a no-op."
  def record_paid(%{"product_id" => slug} = attrs) do
    product = is_binary(slug) && Repo.get_by(Product, slug: slug)

    %Order{}
    |> Order.changeset(Map.put(attrs, "product_id", product && product.id))
    |> Repo.insert(on_conflict: :nothing, conflict_target: :stripe_session_id)
  end

  def record_refund(%{"payment_intent" => pi}) when is_binary(pi) do
    case Repo.get_by(Order, payment_intent: pi) do
      nil -> {:error, :not_found}
      order -> order |> Ecto.Changeset.change(status: "refunded") |> Repo.update()
    end
  end

  def record_refund(_), do: {:error, :not_found}

  def paid_total_cents,
    do: Repo.one(from o in Order, where: o.status == "paid", select: coalesce(sum(o.amount_cents), 0))
end
