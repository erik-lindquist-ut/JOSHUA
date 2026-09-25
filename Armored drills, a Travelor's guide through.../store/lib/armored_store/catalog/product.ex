defmodule ArmoredStore.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :slug, :string
    field :title, :string
    field :subtitle, :string
    field :author, :string
    field :series, :string
    field :edition, :string
    field :description, :string
    field :cover, :string
    # nil = no price in the listing data: shown as "Price not set", cannot be bought.
    field :cents, :integer
    field :price_source, :string
    field :position, :integer, default: 0
    field :active, :boolean, default: true
    timestamps(type: :utc_datetime)
  end

  @fields [:slug, :title, :subtitle, :author, :series, :edition, :description, :cover, :cents, :price_source, :position, :active]

  def changeset(product, attrs) do
    product
    |> cast(attrs, @fields)
    |> validate_required([:slug, :title, :author])
    |> validate_format(:slug, ~r/\A[a-z0-9]+(-[a-z0-9]+)*\z/)
    |> validate_number(:cents, greater_than: 0)
    |> unique_constraint(:slug)
    |> check_constraint(:cents, name: :cents_positive_or_unset)
  end
end
