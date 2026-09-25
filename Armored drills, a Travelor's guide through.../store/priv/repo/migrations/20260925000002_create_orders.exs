defmodule ArmoredStore.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :stripe_session_id, :string, null: false
      add :payment_intent, :string
      add :amount_cents, :integer, null: false
      add :currency, :string, size: 3, null: false, default: "usd"
      add :status, :string, null: false, default: "paid"
      add :product_id, references(:products, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:orders, [:stripe_session_id])
    create index(:orders, [:payment_intent])
    create index(:orders, [:product_id])
    create constraint(:orders, :amount_nonneg, check: "amount_cents >= 0")
    create constraint(:orders, :status_known, check: "status IN ('paid','refunded')")
    create constraint(:orders, :currency_usd, check: "currency = 'usd'")
  end
end
