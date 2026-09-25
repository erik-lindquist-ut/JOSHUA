defmodule LastTenYards.Store.Order do
  @moduledoc "One paid Stripe checkout. No card data, no buyer name or email — Stripe keeps those."
  use Ecto.Schema
  import Ecto.Changeset
  alias LastTenYards.Store.Rules

  schema "orders" do
    field :stripe_session_id, :string
    field :payment_intent, :string
    field :amount_cents, :integer
    field :currency, :string, default: "usd"
    field :status, :string, default: "paid"
    belongs_to :product, LastTenYards.Store.Product
    timestamps(type: :utc_datetime)
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:stripe_session_id, :payment_intent, :amount_cents, :currency, :status, :product_id])
    |> validate_required([:stripe_session_id, :amount_cents, :currency, :status])
    |> validate_rules()
    |> unique_constraint(:stripe_session_id)
    |> foreign_key_constraint(:product_id)
  end

  def refund_changeset(order) do
    case Rules.transition(order.status, "refunded") do
      {:ok, s} -> change(order, status: s)
      {:error, msg} -> order |> change() |> add_error(:status, msg)
    end
  end

  defp validate_rules(cs) do
    m = Map.new(~w(stripe_session_id amount_cents currency status), &{&1, get_field(cs, String.to_existing_atom(&1))})
    Enum.reduce(Rules.order_errors(m), cs, fn {k, msg}, acc -> add_error(acc, String.to_existing_atom(k), msg) end)
  end
end
