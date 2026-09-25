defmodule LastTenYards.Store.RulesTest do
  use ExUnit.Case, async: true
  alias LastTenYards.Store.Rules

  @good %{"id" => "ride-at-closing", "name" => "Ride at Closing", "cents" => 2500, "stripe_price" => "price_123"}

  test "a complete product passes" do
    assert Rules.product_errors(@good) == []
    assert Rules.valid_product?(@good)
  end

  for {key, bad} <- [{"id", "Ride At Closing"}, {"id", "-x"}, {"id", nil}, {"name", ""}, {"name", "   "},
                     {"name", String.duplicate("a", 81)}, {"cents", 0}, {"cents", -5}, {"cents", 25.0},
                     {"cents", "2500"}, {"stripe_price", "sk_live_1"}, {"stripe_price", nil}] do
    test "product #{key} = #{inspect(bad)} is refused" do
      errs = Rules.product_errors(Map.put(@good, unquote(key), unquote(Macro.escape(bad))))
      assert Enum.any?(errs, fn {k, _} -> k == unquote(key) end)
    end
  end

  test "every missing field is named, in a fixed order" do
    assert Enum.map(Rules.product_errors(%{}), &elem(&1, 0)) == ["id", "name", "cents", "stripe_price"]
  end

  @order %{"stripe_session_id" => "cs_test_1", "amount_cents" => 2500, "currency" => "usd", "status" => "paid"}

  test "a paid order passes" do
    assert Rules.order_errors(@order) == []
  end

  for {key, bad} <- [{"stripe_session_id", "pi_1"}, {"amount_cents", -1}, {"currency", "eur"}, {"status", "pending"}] do
    test "order #{key} = #{inspect(bad)} is refused" do
      assert [{unquote(key), _}] = Rules.order_errors(Map.put(@order, unquote(key), unquote(bad)))
    end
  end

  test "orders keep no card or buyer contact fields" do
    refute Enum.any?(Map.keys(@order), &(&1 =~ ~r/card|email|name|phone|address/))
  end

  test "status moves: paid → refunded only" do
    assert Rules.transition("paid", "refunded") == {:ok, "refunded"}
    assert Rules.transition("paid", "paid") == {:ok, "paid"}
    assert {:error, _} = Rules.transition("refunded", "paid")
  end

  test "dollars" do
    assert Rules.dollars(2500) == "$25.00"
    assert Rules.dollars(5) == "$0.05"
    assert Rules.dollars(100_001) == "$1000.01"
  end
end
