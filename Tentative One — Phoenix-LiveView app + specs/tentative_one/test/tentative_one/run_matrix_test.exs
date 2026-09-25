defmodule TentativeOne.RunMatrixTest do
  @moduledoc "Every status × every kind of input, and every reason × 1/0 at a hold."
  use ExUnit.Case, async: true
  alias TentativeOne.{Gate, Run}

  # four starting states
  defp at(:running), do: Run.new("a\nb")
  defp at(:held), do: Run.new("email it\nb") |> Run.tick()
  defp at(:done), do: Run.new("a") |> Run.tick()
  defp at(:stopped), do: Run.new("a\nb") |> Run.input("0")

  #            input      running    held       done       stopped
  @matrix [
    {"1", :running, :running, :done, :stopped},
    {"0", :stopped, :running, :done, :stopped},
    {"", :running, :held, :done, :stopped},
    {"   ", :running, :held, :done, :stopped},
    {" 1 ", :running, :running, :done, :stopped},
    {"\t0\n", :stopped, :running, :done, :stopped},
    {"note", :running, :held, :running, :running},
    {"10", :running, :held, :running, :running},
    {"use Gemini", :running, :held, :running, :running},
    {"one", :running, :held, :running, :running}
  ]

  for {input, r, h, d, s} <- @matrix, {from, to} <- [running: r, held: h, done: d, stopped: s] do
    @input input
    @from from
    @to to
    test "#{from} + #{inspect(input)} → #{to}" do
      before = at(@from)
      after_ = Run.input(before, @input)
      assert after_.status == @to
      assert after_.west == before.west + String.length(String.trim(@input))
    end
  end

  @samples %{
    destroy: "delete the logs",
    send: "email it",
    money: "pay the fee",
    regulated: "export PII",
    address: "cc a@b.co",
    password: "set the password"
  }

  test "the sample table covers every reason the gate knows" do
    assert Enum.sort(Map.keys(@samples)) == Enum.sort(Gate.reasons())
  end

  for {reason, text} <- @samples do
    @reason reason
    @text text

    test "#{reason}: the step holds with its reason named" do
      r = Run.new(@text <> "\nafter") |> Run.tick()
      assert r.status == :held
      assert hd(r.steps).state == {:held, @reason}
    end

    test "#{reason}: 1 approves, the rest still runs" do
      r = Run.new(@text <> "\nafter") |> Run.tick() |> Run.input("1") |> Run.tick()
      assert Enum.map(r.steps, & &1.state) == [:approved, :tentative]
      assert r.status == :done
    end

    test "#{reason}: 0 skips the step, not the process" do
      r = Run.new(@text <> "\nafter") |> Run.tick() |> Run.input("0") |> Run.tick()
      assert Enum.map(r.steps, & &1.state) == [:skipped, :tentative]
      assert r.status == :done
    end
  end
end
