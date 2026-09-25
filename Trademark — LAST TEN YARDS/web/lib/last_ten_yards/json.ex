defmodule LastTenYards.JSON do
  @moduledoc "Decode JSON with Jason when present; a small built-in parser otherwise (lets the pure specs run without Hex)."
  def decode(""), do: {:ok, nil}
  def decode(s) do
    if Code.ensure_loaded?(Jason), do: apply(Jason, :decode, [s]), else: parse(s)
  end

  defp parse(s) do
    case value(ws(s)) do
      {v, rest} -> if ws(rest) == "", do: {:ok, v}, else: {:error, :trailing}
    end
  rescue
    _ -> {:error, :invalid}
  end

  defp ws(<<c, r::binary>>) when c in ~c" \t\r\n", do: ws(r)
  defp ws(s), do: s

  defp value("{" <> r), do: obj(ws(r), %{})
  defp value("[" <> r), do: arr(ws(r), [])
  defp value("\"" <> r), do: str(r, "")
  defp value("true" <> r), do: {true, r}
  defp value("false" <> r), do: {false, r}
  defp value("null" <> r), do: {nil, r}
  defp value(r) do
    [n] = Regex.run(~r/^-?\d+(\.\d+)?([eE][+-]?\d+)?/, r)
    rest = binary_part(r, byte_size(n), byte_size(r) - byte_size(n))
    {if(String.contains?(n, [".", "e", "E"]), do: String.to_float(n), else: String.to_integer(n)), rest}
  end

  defp obj("}" <> r, acc), do: {acc, r}
  defp obj("\"" <> r, acc) do
    {k, r} = str(r, "")
    ":" <> r = ws(r)
    {v, r} = value(ws(r))
    case ws(r) do
      "," <> r -> obj(ws(r), Map.put(acc, k, v))
      "}" <> r -> {Map.put(acc, k, v), r}
    end
  end

  defp arr("]" <> r, acc), do: {Enum.reverse(acc), r}
  defp arr(r, acc) do
    {v, r} = value(r)
    case ws(r) do
      "," <> r -> arr(ws(r), [v | acc])
      "]" <> r -> {Enum.reverse([v | acc]), r}
    end
  end

  defp str("\"" <> r, acc), do: {acc, r}
  defp str("\\\"" <> r, acc), do: str(r, acc <> "\"")
  defp str("\\\\" <> r, acc), do: str(r, acc <> "\\")
  defp str("\\n" <> r, acc), do: str(r, acc <> "\n")
  defp str(<<c::utf8, r::binary>>, acc), do: str(r, acc <> <<c::utf8>>)
end
