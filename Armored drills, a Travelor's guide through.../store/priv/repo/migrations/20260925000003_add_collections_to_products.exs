defmodule ArmoredStore.Repo.Migrations.AddCollectionsToProducts do
  use Ecto.Migration

  # The collections a product is shown in (the library shelf it came from, or "Originals" for #1-#7).
  # A list, so one product can sit in more than one collection.
  def change do
    alter table(:products) do
      add :collections, {:array, :string}, null: false, default: []
    end
  end
end
