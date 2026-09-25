defmodule TentativeOne.RunTest do
  use ExUnit.Case, async: true
  alias TentativeOne.Run

  defp run(lines), do: Run.new(lines)

  test "new/1 takes one step per non-blank line" do
    r = run("a\n\n b \nc")
    assert Enum.map(r.steps, & &1.text) == ["a", "b", "c"]
    assert r.status == :running
    assert r.west == 0
  end

  test "a tentative 1 moves forward with no input from him" do
    r = run("draft\nformat") |> Run.tick() |> Run.tick()
    assert Enum.map(r.steps, & &1.state) == [:tentative, :tentative]
    assert r.status == :done
    assert r.west == 0
  end

  test "an inflection point holds that step" do
    r = run("draft\nemail it to Gordon\nformat") |> Run.tick() |> Run.tick()
    assert r.status == :held
    assert Enum.at(r.steps, 1).state == {:held, :send}
    # ticking while held does nothing
    assert Run.tick(r) == r
  end

  test "1 at a hold clears that step and the run moves on" do
    r = run("email it\nformat") |> Run.tick() |> Run.input("1") |> Run.tick()
    assert Enum.map(r.steps, & &1.state) == [:approved, :tentative]
    assert r.status == :done
    assert r.west == 1
  end

  test "0 at a hold stops that step only — the rest still finishes" do
    r = run("email it\nformat") |> Run.tick() |> Run.input("0") |> Run.tick()
    assert Enum.map(r.steps, & &1.state) == [:skipped, :tentative]
    assert r.status == :done
    assert r.west == 1
  end

  test "0 while running is a kill — stop is the destination" do
    r = run("a\nb\nc") |> Run.tick() |> Run.input("0")
    assert r.status == :stopped
    assert Enum.map(r.steps, & &1.state) == [:tentative, :pending, :pending]
    assert Run.tick(r) == r
  end

  test "1 while running is a no-op keystroke — still counted West" do
    r = run("a") |> Run.input("1")
    assert r.status == :running
    assert r.west == 1
  end

  test "anything but 1 or 0 is him telling otherwise: it becomes the next step, full cost West" do
    r = run("a\nb") |> Run.tick() |> Run.input("use Gemini instead")
    assert Enum.map(r.steps, & &1.text) == ["a", "use Gemini instead", "b"]
    assert r.west == String.length("use Gemini instead")
  end

  test "input after done or stopped adds a step and resumes" do
    r = run("a") |> Run.tick() |> Run.input("b")
    assert r.status == :running
    r = Run.tick(r)
    assert r.status == :done
    assert List.last(r.steps).state == :tentative
  end

  test "tentatives/1 lists what was assumed, for the end-of-run surface" do
    r = run("a\nemail it\nc") |> Run.tick() |> Run.tick() |> Run.input("0") |> Run.tick()
    assert Run.tentatives(r) == ["a", "c"]
  end
end
