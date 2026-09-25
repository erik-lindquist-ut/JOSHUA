defmodule LastTenYards.Repo.Migrations.CreateBusinessLines do
  use Ecto.Migration

  def change do
    create table(:business_lines) do
      add :slug, :string, null: false
      add :name, :string, size: 80, null: false
      add :tagline, :string, size: 160
      add :source, :string
      add :active, :boolean, null: false, default: true
      add :position, :integer, null: false, default: 0
      timestamps(type: :utc_datetime)
    end

    create unique_index(:business_lines, [:slug])
    create constraint(:business_lines, :line_slug_shape, check: "slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'")

    alter table(:products) do
      add :business_line_id, references(:business_lines, on_delete: :restrict)
    end

    create index(:products, [:business_line_id])
  end
end
