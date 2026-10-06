defmodule ArmoredStore.ConceptCapsTest do
  @moduledoc """
  Descriptions of the library books (#8 on) list the book's concepts. Each concept keeps the capitals it has in that
  book's own PDF concept list; the only change allowed is lower-casing the first letter of a concept whose first word
  is not a name, since it sits mid-sentence after "concepts: ". test/support/concept_names.json holds, per slug, each
  concept exactly as the PDF concept list writes it and whether its first word is a name (Maslow’s, Doppler, Universal
  Design for Learning, SMART ...). It was read from the 857 PDFs once, because reading them all here takes minutes.
  """
  use ExUnit.Case, async: true
  alias ArmoredStore.Listings

  @names "test/support/concept_names.json" |> File.read!() |> Jason.decode!()

  defp books do
    text = File.read!("priv/STORE_ADDITIONS.json")
    kdp = "priv/KDP_LISTINGS.json" |> File.read!() |> Listings.products()

    Enum.zip(Jason.decode!(text), Listings.additions(text, length(kdp)))
    # the library drills: every PDF addition except the Armored Fail Fast set (#865-#869), which is not from the library
    |> Enum.filter(fn {e, _} -> String.ends_with?(e["manuscript"] || "", ".pdf") and "Armored Fail Fast" not in (e["collections"] || []) end)
    |> Enum.map(fn {_, p} -> p end)
  end

  defp concepts(d), do: d |> String.split(" concepts: ", parts: 2) |> List.last() |> String.split(". Every wrong answer") |> hd()
  defp listing([c]), do: c
  defp listing(cs), do: Enum.join(Enum.drop(cs, -1), ", ") <> " and " <> List.last(cs)
  defp mid([name, true]), do: name
  defp mid([name, false]), do: String.downcase(String.first(name)) <> String.slice(name, 1..-1//1)

  test "every library book in the store has its PDF concept list on file" do
    assert length(books()) == 857
    for p <- books(), do: assert(length(Map.get(@names, p["slug"], [])) >= 1, p["slug"])
    assert map_size(@names) == 857
  end

  test "each description lists its book's concepts with the capitals of its PDF concept list" do
    for p <- books(), p["position"] >= 13 do
      assert concepts(p["description"]) == listing(Enum.map(@names[p["slug"]], &mid/1)), p["slug"]
    end
  end

  test "no concept that starts with a name loses its capital, in any description (the hand-worded #8-#13 too)" do
    for p <- books(), [name, true] <- @names[p["slug"]] do
      d = p["description"]
      if String.contains?(String.downcase(d), String.downcase(name)), do: assert(String.contains?(d, name), "#{p["slug"]}: #{name}")
    end

    names = ~w(Maslow Newton Kotter Bloom Lewin Piaget Herzberg Amdahl Little Hofstede Porter Kirkpatrick Tuckman Schein Dijkstra)
    for p <- books(), n <- names, do: refute(p["description"] =~ ~r/\b#{String.downcase(n)}('|’)s\b/, "#{p["slug"]}: #{n}")
    assert Enum.any?(books(), &(&1["description"] =~ "Maslow’s hierarchy"))
  end

  test "a concept that does not start with a name is lower-cased mid-sentence, never left with a stray capital" do
    for p <- books(), p["position"] >= 13, [name, false] <- @names[p["slug"]] do
      [first | _] = String.split(name)
      refute String.contains?(concepts(p["description"]), ", " <> first <> " ") and first != String.downcase(first) and
               not Enum.any?(@names[p["slug"]], fn [n, k] -> k and String.starts_with?(n, first <> " ") end),
             "#{p["slug"]}: #{name}"
    end
  end
end
