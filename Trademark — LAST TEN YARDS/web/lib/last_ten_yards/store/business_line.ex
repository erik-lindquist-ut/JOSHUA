defmodule LastTenYards.Store.BusinessLine do
  @moduledoc "One of his business lines. Every line gets its own storefront at /l/:slug on the same app and database."
  use Ecto.Schema
  import Ecto.Changeset
  alias LastTenYards.Store.Rules

  schema "business_lines" do
    field :slug, :string
    field :name, :string
    field :tagline, :string
    field :source, :string
    field :active, :boolean, default: true
    field :position, :integer, default: 0
    has_many :products, LastTenYards.Store.Product
    timestamps(type: :utc_datetime)
  end

  def changeset(line, attrs) do
    line
    |> cast(attrs, [:slug, :name, :tagline, :source, :active, :position])
    |> validate_required([:slug, :name])
    |> then(fn cs ->
      m = %{"slug" => get_field(cs, :slug), "name" => get_field(cs, :name), "tagline" => get_field(cs, :tagline)}
      Enum.reduce(Rules.line_errors(m), cs, fn {k, msg}, acc -> add_error(acc, String.to_existing_atom(k), msg) end)
    end)
    |> unique_constraint(:slug)
    |> check_constraint(:slug, name: :line_slug_shape)
  end

  def to_map(%__MODULE__{} = l), do: %{"slug" => l.slug, "name" => l.name, "tagline" => l.tagline}
end
