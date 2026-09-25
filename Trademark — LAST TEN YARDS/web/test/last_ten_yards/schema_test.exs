defmodule LastTenYards.SchemaTest do
  # Keeps priv/repo/structure.sql (proven in real Postgres) in step with the Ecto migrations.
  use ExUnit.Case, async: true
  @root Path.expand("../..", __DIR__)
  @sql File.read!(Path.join(@root, "priv/repo/structure.sql"))
  @migs Path.wildcard(Path.join(@root, "priv/repo/migrations/*.exs")) |> Enum.sort() |> Enum.map(&File.read!/1)

  test "three migrations: products, orders, then business lines" do
    assert length(@migs) == 3
    assert Enum.at(@migs, 0) =~ "create table(:products)"
    assert Enum.at(@migs, 1) =~ "create table(:orders)"
    assert Enum.at(@migs, 2) =~ "create table(:business_lines)"
  end

  test "every product hangs off a line; a line with products can't be deleted" do
    assert Enum.at(@migs, 2) =~ "references(:business_lines, on_delete: :restrict)"
    assert @sql =~ "REFERENCES business_lines(id) ON DELETE RESTRICT"
    assert Enum.at(@migs, 2) =~ "line_slug_shape"
    assert @sql =~ "CONSTRAINT line_slug_shape CHECK"
  end

  for {name, check} <- [cents_positive: "cents > 0", amount_nonneg: "amount_cents >= 0",
                        status_known: "status IN ('paid','refunded')", currency_usd: "currency = 'usd'"] do
    test "constraint #{name} is in both the migration and structure.sql" do
      assert Enum.any?(@migs, &(&1 =~ ":#{unquote(name)}, check: \"#{unquote(check)}\""))
      assert @sql =~ "CONSTRAINT #{unquote(name)} CHECK (#{unquote(check)})"
    end
  end

  test "slug and price shapes match" do
    assert Enum.any?(@migs, &(&1 =~ "^[a-z0-9]+(-[a-z0-9]+)*$"))
    assert @sql =~ "^[a-z0-9]+(-[a-z0-9]+)*$"
    assert @sql =~ "LIKE 'price\\_%'"
  end

  for idx <- ~w(business_lines_slug_index products_business_line_id_index products_slug_index orders_stripe_session_id_index orders_payment_intent_index orders_product_id_index) do
    test "index #{idx} exists" do
      assert @sql =~ unquote(idx)
    end
  end

  test "unique: one product per slug, one order per Stripe session" do
    assert Enum.at(@migs, 0) =~ "unique_index(:products, [:slug])"
    assert Enum.at(@migs, 1) =~ "unique_index(:orders, [:stripe_session_id])"
  end

  test "deleting a product keeps its orders" do
    assert Enum.at(@migs, 1) =~ "on_delete: :nilify_all"
    assert @sql =~ "ON DELETE SET NULL"
  end

  test "Heroku runs migrations before each release" do
    assert File.read!(Path.join(@root, "Procfile")) =~ ~r/^release: mix ecto.migrate$/m
    assert File.read!(Path.join(@root, "config/runtime.exs")) =~ ~s[System.fetch_env!("DATABASE_URL")]
  end
end
