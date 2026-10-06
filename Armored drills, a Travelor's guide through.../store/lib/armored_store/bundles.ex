defmodule ArmoredStore.Bundles do
  @moduledoc """
  Every course product is sold as one bundle: the course's Armored drill plus the five shared Armored Fail Fast books.
  A course product is a book that sits in a program (ArmoredStore.Programs): #7 and every library drill, #8-#864.
  The Originals #1-#6 are not courses, and the Fail Fast books stay their own products, so neither is bundled.
  No book is copied: the bundle is how the store shows and (once priced) sells the course.
  """
  import Ecto.Query
  alias ArmoredStore.{Catalog, Programs, Repo}
  alias ArmoredStore.Catalog.Product

  @doc "The card and book-page line."
  def line, do: "Bundle: this drill + the Armored Fail Fast set (5 books)"

  @doc "Is this product a course, sold as a bundle?"
  def bundle?(%{slug: slug}), do: Programs.placed?(slug)
  def bundle?(_), do: false

  @doc "The shared books every bundle includes: the Armored Fail Fast set, in book order."
  def shared_books do
    ff = Catalog.fail_fast()
    from(p in Product, where: p.active and ^ff in p.collections, order_by: [asc: p.position, asc: p.id]) |> Repo.all()
  end
end
