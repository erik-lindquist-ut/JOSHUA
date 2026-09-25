defmodule LastTenYards.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :slug, :string, null: false
      add :name, :string, size: 80, null: false
      add :blurb, :text
      add :cents, :integer, null: false
      add :stripe_price, :string, null: false
      add :active, :boolean, null: false, default: true
      add :position, :integer, null: false, default: 0
      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:slug])
    create constraint(:products, :cents_positive, check: "cents > 0")
    create constraint(:products, :slug_shape, check: "slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'")
    create constraint(:products, :stripe_price_shape, check: "stripe_price LIKE 'price\\_%'")
  end
end
