defmodule ArmoredStore.ProjectTree do
  @moduledoc "Fixed project tree for the store home (WGU handoff first view)."

  def lines do
    pdf =
      case File.ls("priv/static/handoff") do
        {:ok, names} ->
          names
          |> Enum.filter(&File.regular?(Path.join("priv/static/handoff", &1)))
          |> Enum.sort()
          |> List.first()

        _ ->
          nil
      end

    pdf_line =
      if pdf,
        do: "│   │       └── #{pdf}   ← WGU handoff PDF (viewable at /handoff/…)",
        else: "│   │       └── (missing handoff PDF)"

    [
      "store/",
      "├── README.md",
      "├── mix.exs",
      "├── lib/",
      "│   ├── armored_store/",
      "│   └── armored_store_web/",
      "├── priv/",
      "│   ├── docs/                         ← WGU handoff briefs",
      "│   │   ├── README.md               ← Provost · Principal Technologist",
      "│   │   └── TECHNICAL.md            ← Engineering (Rails → Elixir)",
      "│   ├── static/",
      "│   │   ├── assets/",
      "│   │   ├── images/covers/",
      "│   │   └── handoff/",
      pdf_line,
      "│   ├── KDP_LISTINGS.json",
      "│   ├── STORE_ADDITIONS.json",
      "│   ├── PREVIEWS.json",
      "│   └── PROGRAMS.json",
      "├── test/",
      "└── …"
    ]
    |> Enum.map(fn line ->
      highlight =
        String.contains?(line, "docs/") or String.contains?(line, "README.md") or
          String.contains?(line, "TECHNICAL.md") or String.contains?(line, "handoff") or
          String.contains?(line, "WGU handoff")

      %{line: line, highlight: highlight}
    end)
  end
end
