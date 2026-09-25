defmodule TentativeOne.RunPropertyTest do
  @moduledoc """
  One spec per seed. Each seed builds a random plan and a random stream of
  ticks and keystrokes, then checks the laws after every single move.
  Same seed, same run — a failure names its seed and replays exactly.
  """
  use ExUnit.Case, async: true
  alias TentativeOne.{Gate, Run}

  @pool ["draft", "format", "read MIND.md", "email it", "delete logs", "pay $5",
         "export PII", "cc a@b.co", "set password", "build PDFs", "outline", "compact"]
  @moves [:tick, :tick, :tick, "1", "0", "", "retry with v2", "1", :tick]

  defp laws!(r, typed, seed) do
    ctx = "seed #{seed}"
    assert r.west == typed, ctx
    held = Enum.count(r.steps, &match?({:held, _}, &1.state))
    assert held <= 1, ctx
    assert (r.status == :held) == (held == 1), ctx
    if r.status == :done, do: assert(Enum.all?(r.steps, &(&1.state not in [:pending]) and not match?({:held, _}, &1.state)), ctx)
    for s <- r.steps do
      case s.state do
        :tentative -> assert Gate.classify(s.text) == :one, ctx
        st when st in [:approved, :skipped] -> assert match?({:zero, _}, Gate.classify(s.text)), ctx
        {:held, why} -> assert Gate.classify(s.text) == {:zero, why}, ctx
        :pending -> :ok
      end
    end
    # resolved steps always sit before pending ones — nothing is skipped over
    states = Enum.map(r.steps, &(&1.state == :pending))
    assert states == Enum.sort(states), ctx
    if r.status in [:done, :stopped, :held], do: assert(Run.tick(r) == r, ctx)
  end

  for seed <- 1..100 do
    @seed seed
    test "laws hold on random run, seed #{seed}" do
      :rand.seed(:exsss, {@seed, @seed * 7, @seed * 13})
      plan = Enum.map_join(1..Enum.random(1..8), "\n", fn _ -> Enum.random(@pool) end)
      r0 = Run.new(plan)
      laws!(r0, 0, @seed)

      Enum.reduce(1..40, {r0, 0}, fn _, {r, typed} ->
        {r, typed} =
          case Enum.random(@moves) do
            :tick -> {Run.tick(r), typed}
            key -> {Run.input(r, key), typed + String.length(key)}
          end

        laws!(r, typed, @seed)
        {r, typed}
      end)
    end
  end
end
