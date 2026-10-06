defmodule ArmoredStore.PdfText do
  @moduledoc """
  Test helper: a PDF book's text, for checking previews against the book's own file. Uses `pdftotext -layout`
  when poppler is installed, otherwise macOS PDFKit (through osascript), the same two readers
  tools/extract_previews.py uses. Blank form lines (runs of underscores) and line breaks are folded to single spaces,
  so a paragraph that wraps across lines in the PDF still matches.
  """

  @pdfkit """
  function run(argv) {
    ObjC.import("Quartz");
    var d = $.PDFDocument.alloc.initWithURL($.NSURL.fileURLWithPath(argv[0])), out = [];
    for (var i = 0; i < d.pageCount; i++) out.push(d.pageAtIndex(i).string.js);
    return out.join("\\f");
  }
  """

  @doc "Can this machine read PDF text?"
  def available?, do: System.find_executable("pdftotext") != nil or System.find_executable("osascript") != nil

  @doc "The PDF's text, whitespace folded."
  def text(path) do
    path = Path.expand(path)

    {raw, 0} =
      if System.find_executable("pdftotext"),
        do: System.cmd("pdftotext", ["-layout", "-enc", "UTF-8", path, "-"]),
        else: System.cmd("osascript", ["-l", "JavaScript", "-e", @pdfkit, path])

    fold(raw)
  end

  def fold(s), do: s |> String.replace(~r/_{3,}/, " ") |> String.replace(~r/\s+/u, " ") |> String.trim()
end
