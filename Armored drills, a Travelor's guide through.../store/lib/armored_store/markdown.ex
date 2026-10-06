defmodule ArmoredStore.Markdown do
  @moduledoc "Small Markdown → HTML for priv/docs handoff pages (no extra Hex deps)."

  def to_html(md) when is_binary(md) do
    md
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> blocks([])
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  def to_html(_), do: ""

  defp blocks([], acc), do: acc

  defp blocks(["```" <> _ | rest], acc) do
    {code, rest} = take_until_fence(rest, [])
    html = "<pre><code>" <> escape(Enum.join(Enum.reverse(code), "\n")) <> "</code></pre>"
    blocks(rest, [html | acc])
  end

  defp blocks([line | rest], acc) do
    cond do
      String.match?(line, ~r/^---+$/) ->
        blocks(rest, ["<hr />" | acc])

      String.starts_with?(line, "|") and String.contains?(line, "|") ->
        {rows, rest} = take_table([line | rest], [])
        blocks(rest, [table_html(rows) | acc])

      heading_level(line) ->
        level = heading_level(line)
        text = String.replace_prefix(line, String.duplicate("#", level) <> " ", "")
        blocks(rest, ["<h#{level}>" <> inline(text) <> "</h#{level}>" | acc])

      String.match?(line, ~r/^[-*]\s+/) ->
        {items, rest} = take_list([line | rest], ~r/^[-*]\s+/, [])
        blocks(rest, ["<ul>" <> Enum.map_join(items, "", &("<li>" <> inline(&1) <> "</li>")) <> "</ul>" | acc])

      String.match?(line, ~r/^\d+\.\s+/) ->
        {items, rest} = take_list([line | rest], ~r/^\d+\.\s+/, [])
        blocks(rest, ["<ol>" <> Enum.map_join(items, "", &("<li>" <> inline(&1) <> "</li>")) <> "</ol>" | acc])

      String.trim(line) == "" ->
        blocks(rest, acc)

      true ->
        {paras, rest} = take_para([line | rest], [])
        text = Enum.join(Enum.reverse(paras), " ")
        blocks(rest, ["<p>" <> inline(text) <> "</p>" | acc])
    end
  end

  defp heading_level(<<"###### ", _::binary>>), do: 6
  defp heading_level(<<"##### ", _::binary>>), do: 5
  defp heading_level(<<"#### ", _::binary>>), do: 4
  defp heading_level(<<"### ", _::binary>>), do: 3
  defp heading_level(<<"## ", _::binary>>), do: 2
  defp heading_level(<<"# ", _::binary>>), do: 1
  defp heading_level(_), do: nil

  defp take_until_fence(["```" <> _ | rest], acc), do: {acc, rest}
  defp take_until_fence([line | rest], acc), do: take_until_fence(rest, [line | acc])
  defp take_until_fence([], acc), do: {acc, []}

  defp take_table([line | rest], acc) when is_binary(line) do
    if String.starts_with?(String.trim_leading(line), "|") do
      take_table(rest, [line | acc])
    else
      {Enum.reverse(acc), [line | rest]}
    end
  end

  defp take_table([], acc), do: {Enum.reverse(acc), []}

  defp table_html(rows) do
    cells =
      rows
      |> Enum.map(&table_row/1)
      |> Enum.reject(&is_nil/1)

    case cells do
      [head | body] ->
        "<table class=\"doc-table\"><thead><tr>" <>
          Enum.map_join(head, "", &("<th>" <> inline(&1) <> "</th>")) <>
          "</tr></thead><tbody>" <>
          Enum.map_join(body, "", fn r ->
            "<tr>" <> Enum.map_join(r, "", &("<td>" <> inline(&1) <> "</td>")) <> "</tr>"
          end) <>
          "</tbody></table>"

      [] ->
        ""
    end
  end

  defp table_row(line) do
    cells =
      line
      |> String.trim()
      |> String.trim_leading("|")
      |> String.trim_trailing("|")
      |> String.split("|")
      |> Enum.map(&String.trim/1)

    if Enum.all?(cells, &String.match?(&1, ~r/^:?-+:?$/)), do: nil, else: cells
  end

  defp take_list([line | rest], re, acc) do
    case Regex.run(re, line) do
      [_] ->
        item = Regex.replace(re, line, "")
        take_list(rest, re, [item | acc])

      nil ->
        {Enum.reverse(acc), [line | rest]}
    end
  end

  defp take_list([], _re, acc), do: {Enum.reverse(acc), []}

  defp take_para([line | rest], acc) do
    cond do
      String.trim(line) == "" -> {acc, rest}
      heading_level(line) -> {acc, [line | rest]}
      String.starts_with?(line, "|") -> {acc, [line | rest]}
      String.starts_with?(line, "```") -> {acc, [line | rest]}
      String.match?(line, ~r/^[-*]\s+/) -> {acc, [line | rest]}
      String.match?(line, ~r/^\d+\.\s+/) -> {acc, [line | rest]}
      String.match?(line, ~r/^---+$/) -> {acc, [line | rest]}
      true -> take_para(rest, [line | acc])
    end
  end

  defp take_para([], acc), do: {acc, []}

  defp inline(text) do
    text
    |> escape()
    |> replace_code()
    |> replace_links()
    |> replace_bold()
    |> replace_em()
  end

  defp escape(s),
    do: s |> String.replace("&", "&amp;") |> String.replace("<", "&lt;") |> String.replace(">", "&gt;")

  defp replace_code(s), do: Regex.replace(~r/`([^`]+)`/, s, fn _, c -> "<code>" <> c <> "</code>" end)

  defp replace_links(s),
    do: Regex.replace(~r/\[([^\]]+)\]\(([^)]+)\)/, s, fn _, t, u -> ~s(<a href="#{u}">#{t}</a>) end)

  defp replace_bold(s), do: Regex.replace(~r/\*\*([^*]+)\*\*/, s, fn _, t -> "<strong>" <> t <> "</strong>" end)

  defp replace_em(s), do: Regex.replace(~r/\*([^*]+)\*/, s, fn _, t -> "<em>" <> t <> "</em>" end)
end
