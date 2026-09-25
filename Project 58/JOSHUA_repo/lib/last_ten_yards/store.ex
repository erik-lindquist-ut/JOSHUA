defmodule LastTenYards.Store do
  @moduledoc "The store's data: products for sale, and orders Stripe has confirmed."
  import Ecto.Query
  alias LastTenYards.Repo
  alias LastTenYards.Store.{BusinessLine, Product, Order}

  @doc "Every active business line, in order."
  def list_lines do
    from(l in BusinessLine, where: l.active, order_by: [asc: l.position, asc: l.id])
    |> Repo.all()
    |> Enum.map(&BusinessLine.to_map/1)
  end

  def get_line(slug), do: Repo.get_by(BusinessLine, slug: slug, active: true)

  def upsert_line(attrs) do
    (Repo.get_by(BusinessLine, slug: attrs["slug"]) || %BusinessLine{})
    |> BusinessLine.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc "Active products, in shelf order, as the maps the pages use. Pass a line slug for one storefront."
  def list_products(line_slug \\ nil) do
    q = from(p in Product, join: l in assoc(p, :business_line), where: p.active and l.active, order_by: [asc: p.position, asc: p.id])
    q = if line_slug, do: where(q, [_p, l], l.slug == ^line_slug), else: q
    q |> Repo.all() |> Enum.map(&Product.to_map/1)
  end

  def get_product(slug), do: Repo.get_by(Product, slug: slug, active: true)

  @doc "attrs may name its line by slug under \"line\"."
  def upsert_product(attrs) do
    attrs =
      case attrs["line"] && Repo.get_by(BusinessLine, slug: attrs["line"]) do
        %BusinessLine{id: id} -> Map.put(attrs, "business_line_id", id)
        _ -> attrs
      end

    (Repo.get_by(Product, slug: attrs["slug"] || attrs[:slug]) || %Product{})
    |> Product.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc "Record a paid checkout. Stripe may send the same event twice; the second is a no-op."
  def record_paid(%{"product_id" => slug} = attrs) do
    product = slug && Repo.get_by(Product, slug: slug)

    %Order{}
    |> Order.changeset(Map.put(attrs, "product_id", product && product.id))
    |> Repo.insert(on_conflict: :nothing, conflict_target: :stripe_session_id)
  end

  def record_refund(%{"payment_intent" => pi}) when is_binary(pi) do
    case Repo.get_by(Order, payment_intent: pi) do
      nil -> {:error, :not_found}
      o -> o |> Order.refund_changeset() |> Repo.update()
    end
  end

  def record_refund(_), do: {:error, :not_found}

  def paid_total_cents do
    Repo.one(from o in Order, where: o.status == "paid", select: coalesce(sum(o.amount_cents), 0))
  end
end
