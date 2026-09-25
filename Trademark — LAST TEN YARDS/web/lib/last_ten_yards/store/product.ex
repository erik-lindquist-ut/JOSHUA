defmodule LastTenYards.Store.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias LastTenYards.Store.Rules

  schema "products" do
    field :slug, :string
    field :name, :string
    field :blurb, :string
    field :cents, :integer
    field :stripe_price, :string
    field :active, :boolean, default: true
    field :position, :integer, default: 0
    belongs_to :business_line, LastTenYards.Store.BusinessLine
    timestamps(type: :utc_datetime)
  end

  def changeset(product, attrs) do
    product
    |> cast(attrs, [:slug, :name, :blurb, :cents, :stripe_price, :active, :position, :business_line_id])
    |> validate_required([:slug, :name, :cents, :stripe_price, :business_line_id])
    |> validate_rules()
    |> unique_constraint(:slug)
    |> check_constraint(:cents, name: :cents_positive)
    |> foreign_key_constraint(:business_line_id)
  end

  # Same rules as the pure module, so the tested logic is the running logic.
  defp validate_rules(cs) do
    m = %{
      "id" => get_field(cs, :slug),
      "name" => get_field(cs, :name),
      "cents" => get_field(cs, :cents),
      "stripe_price" => get_field(cs, :stripe_price)
    }

    Enum.reduce(Rules.product_errors(m), cs, fn {k, msg}, acc ->
      add_error(acc, if(k == "id", do: :slug, else: String.to_existing_atom(k)), msg)
    end)
  end

  @doc "The shape the store pages and Checkout already use."
  def to_map(%__MODULE__{} = p),
    do: %{"id" => p.slug, "name" => p.name, "blurb" => p.blurb, "cents" => p.cents, "stripe_price" => p.stripe_price}
end
