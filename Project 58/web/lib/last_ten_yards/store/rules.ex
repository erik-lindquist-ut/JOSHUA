defmodule LastTenYards.Store.Rules do
  @moduledoc """
  The store's rules, with no database and no library, so they can be proven anywhere.
  The Ecto schemas call these; the database enforces the same rules again (see the migrations).
  """

  @slug ~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/
  @statuses ~w(paid refunded)
  @currencies ~w(usd)

  def statuses, do: @statuses

  @doc "A product must have a slug id, a name, a positive price in cents, and a Stripe price id."
  def product_errors(p) do
    []
    |> need(p, "id", &(is_binary(&1) and Regex.match?(@slug, &1)), "must be lowercase words joined by dashes")
    |> need(p, "name", &(is_binary(&1) and String.trim(&1) != "" and String.length(&1) <= 80), "is required, 80 characters or fewer")
    |> need(p, "cents", &(is_integer(&1) and &1 > 0 and &1 <= 10_000_000), "must be a whole number of cents above 0")
    |> need(p, "stripe_price", &(is_binary(&1) and String.starts_with?(&1, "price_")), "must be a Stripe price id (price_…)")
    |> Enum.reverse()
  end

  def valid_product?(p), do: product_errors(p) == []

  @doc "A business line needs a slug and a name; the tagline is short."
  def line_errors(l) do
    []
    |> need(l, "slug", &(is_binary(&1) and Regex.match?(@slug, &1)), "must be lowercase words joined by dashes")
    |> need(l, "name", &(is_binary(&1) and String.trim(&1) != "" and String.length(&1) <= 80), "is required, 80 characters or fewer")
    |> need(l, "tagline", &(is_nil(&1) or (is_binary(&1) and String.length(&1) <= 160)), "must be 160 characters or fewer")
    |> Enum.reverse()
  end

  @doc "A lines file: every line valid, no slug twice."
  def lines_file_errors(list) when is_list(list) do
    bad = for {l, i} <- Enum.with_index(list), e <- line_errors(l), do: {i, e}
    dups = list |> Enum.map(& &1["slug"]) |> Enum.frequencies() |> Enum.filter(fn {_, n} -> n > 1 end) |> Enum.map(&elem(&1, 0))
    bad ++ Enum.map(dups, &{:duplicate, &1})
  end

  @doc "An order exists only once Stripe says it was paid. We keep no card data and no buyer contact data."
  def order_errors(o) do
    []
    |> need(o, "stripe_session_id", &(is_binary(&1) and String.starts_with?(&1, "cs_")), "must be a Stripe checkout session id")
    |> need(o, "amount_cents", &(is_integer(&1) and &1 >= 0), "must be whole cents")
    |> need(o, "currency", &(&1 in @currencies), "must be usd")
    |> need(o, "status", &(&1 in @statuses), "must be paid or refunded")
    |> Enum.reverse()
  end

  @doc "paid → refunded is the only move. Everything else stays put."
  def transition("paid", "refunded"), do: {:ok, "refunded"}
  def transition(same, same), do: {:ok, same}
  def transition(from, to), do: {:error, "cannot go from #{from} to #{to}"}

  @doc "What a buyer sees: $25.00"
  def dollars(cents) when is_integer(cents),
    do: "$" <> Integer.to_string(div(cents, 100)) <> "." <> String.pad_leading(Integer.to_string(rem(cents, 100)), 2, "0")

  defp need(errs, map, key, ok?, msg) do
    if ok?.(Map.get(map, key)), do: errs, else: [{key, msg} | errs]
  end
end
