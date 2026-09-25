defmodule ArmoredStore.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :slug, :string, null: false
      add :title, :string, null: false
      add :subtitle, :string
      add :author, :string, null: false
      add :series, :string
      add :edition, :string
      add :description, :text
      add :cover, :string
      # NULL = no price in the listing data ("Price not set", not buyable)
      add :cents, :integer
      add :price_source, :string
      add :position, :integer, null: false, default: 0
      add :active, :boolean, null: false, default: true
      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:slug])
    create constraint(:products, :cents_positive_or_unset, check: "cents IS NULL OR cents > 0")
  end
end
