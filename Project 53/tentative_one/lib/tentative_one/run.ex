defmodule TentativeOne.Run do
  @moduledoc """
  A run of steps that moves on a tentative 1.

  * `tick/1` advances one step with no input from him.
  * An inflection point holds its step; `"1"` clears it, `"0"` skips it —
    the step stops, the process does not.
  * `"0"` while running is a kill.
  * Any other text is him telling otherwise: it becomes the next step.
  * `west` counts every character he had to type.
  """
  alias TentativeOne.Gate

  defstruct steps: [], status: :running, west: 0

  @type state :: :pending | :tentative | :approved | :skipped | {:held, Gate.reason()}
  @type t :: %__MODULE__{steps: [%{text: String.t(), state: state}], status: atom, west: non_neg_integer}

  def new(lines) when is_binary(lines) do
    steps =
      lines
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&step/1)

    settle(%__MODULE__{steps: steps})
  end

  def tick(%__MODULE__{status: :running} = r) do
    case next_pending(r) do
      nil ->
        %{r | status: :done}

      i ->
        step = Enum.at(r.steps, i)

        case Gate.classify(step.text) do
          :one -> put(r, i, :tentative) |> settle()
          {:zero, why} -> %{put(r, i, {:held, why}) | status: :held}
        end
    end
  end

  def tick(r), do: r

  def input(r, text) when is_binary(text) do
    text = String.trim(text)
    r = %{r | west: r.west + String.length(text)}

    case {text, r.status} do
      {"", _} -> r
      {"1", :held} -> resolve(r, :approved)
      {"0", :held} -> resolve(r, :skipped)
      {"0", :running} -> %{r | status: :stopped}
      {"1", _} -> r
      {"0", _} -> r
      {other, _} -> insert_next(r, other)
    end
  end

  def tentatives(r), do: for(%{state: :tentative, text: t} <- r.steps, do: t)

  # — internals —

  defp step(text), do: %{text: text, state: :pending}

  defp resolve(r, state) do
    i = Enum.find_index(r.steps, &match?({:held, _}, &1.state))
    settle(%{put(r, i, state) | status: :running})
  end

  defp insert_next(r, text) do
    at = next_pending(r) || length(r.steps)
    %{r | steps: List.insert_at(r.steps, at, step(text)), status: resume(r.status)}
  end

  defp resume(:held), do: :held
  defp resume(_), do: :running

  defp settle(%{status: :running} = r), do: if(next_pending(r), do: r, else: %{r | status: :done})
  defp settle(r), do: r

  defp next_pending(r), do: Enum.find_index(r.steps, &(&1.state == :pending))
  defp put(r, i, s), do: %{r | steps: List.update_at(r.steps, i, &%{&1 | state: s})}
end
