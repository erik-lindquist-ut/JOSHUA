defmodule ArmoredStore.Catalog.Order do
  @moduledoc "One paid Stripe checkout. No card data, no buyer name or email: Stripe keeps those."
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :stripe_session_id, :string
    field :payment_intent, :string
    field :amount_cents, :integer
    field :currency, :string, default: "usd"
    field :status, :string, default: "paid"
    belongs_to :product, ArmoredStore.Catalog.Product
    timestamps(type: :utc_datetime)
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:stripe_session_id, :payment_intent, :amount_cents, :currency, :status, :product_id])
    |> validate_required([:stripe_session_id, :amount_cents, :currency, :status])
    |> validate_format(:stripe_session_id, ~r/\Acs_/)
    |> validate_number(:amount_cents, greater_than_or_equal_to: 0)
    |> validate_inclusion(:currency, ["usd"])
    |> validate_inclusion(:status, ["paid", "refunded"])
    |> unique_constraint(:stripe_session_id)
    |> foreign_key_constraint(:product_id)
  end
end
