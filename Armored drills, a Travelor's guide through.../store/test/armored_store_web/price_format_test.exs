defmodule ArmoredStoreWeb.PriceFormatTest do
  @moduledoc "Prices display as US dollars with thousands separators and two decimals, from integer cents."
  use ExUnit.Case, async: true
  import ArmoredStoreWeb.StoreHTML, only: [price: 1, buyable?: 1]

  test "cents format with thousands separators and two decimals" do
    for {cents, want} <- [
          {99, "$0.99"},
          {1, "$0.01"},
          {100, "$1.00"},
          {99_999, "$999.99"},
          {100_000, "$1,000.00"},
          {6_400_000, "$64,000.00"},
          {6_400_001, "$64,000.01"},
          {100_000_000, "$1,000,000.00"},
          {123_456_789, "$1,234,567.89"}
        ] do
      assert price(%{cents: cents}) == want, "#{cents}"
    end
  end

  test "never prints a float form" do
    s = price(%{cents: 6_400_000})
    refute s =~ "64000"
    refute s =~ "e+"
  end

  test "no price shows 'Price not set' and is not buyable" do
    for c <- [nil, 0, -5, 9.99], do: assert(price(%{cents: c}) == "Price not set")
    refute buyable?(%{cents: nil})
    assert buyable?(%{cents: 6_400_000})
  end
end
