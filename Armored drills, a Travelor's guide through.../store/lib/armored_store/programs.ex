defmodule ArmoredStore.Programs do
  @moduledoc """
  School > Program > Course: the store's navigation, read from priv/PROGRAMS.json (see priv/PROGRAMS_README.md for
  its public source and date). Each program lists its courses in program-guide order; each course names the store
  books (product slugs) that drill it. A course in several programs appears in every one of them. A school's
  "Other courses" entry, when there is one, holds the school's courses that sit in no current program.

  The file is read once, when this module compiles, so the pages never re-read it.
  """

  @path Path.expand("../../priv/PROGRAMS.json", __DIR__)
  @external_resource @path

  # Home-page order.
  @schools ~w(Business Technology Health Education)

  @programs @path
            |> File.read!()
            |> Jason.decode!()
            |> Enum.map(fn p ->
              %{
                school: p["school"],
                name: p["program"],
                slug: p["slug"],
                other?: p["other"] == true,
                courses: Enum.map(p["courses"], &%{name: &1["course"], books: &1["books"]})
              }
            end)

  @by_slug Map.new(@programs, &{&1.slug, &1})

  # book slug -> [{program slug, course name}], in program order
  @by_book @programs
           |> Enum.flat_map(fn p -> Enum.flat_map(p.courses, fn c -> Enum.map(c.books, &{&1, {p.slug, c.name}}) end) |> Enum.uniq_by(&elem(&1, 0)) end)
           |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

  @doc "The four schools, in home-page order."
  def schools, do: @schools

  @doc "A school's URL form: /schools/business"
  def school_slug(school), do: String.downcase(school)

  def school_by_slug(slug) when is_binary(slug), do: Enum.find(@schools, &(school_slug(&1) == slug))
  def school_by_slug(_), do: nil

  @doc "Every program (and any \"Other courses\" entry), schools in home-page order, programs in catalog order."
  def all, do: @programs

  @doc "A school's programs, then its \"Other courses\" entry if it has one."
  def in_school(school), do: Enum.filter(@programs, &(&1.school == school))

  @doc "A school's real programs (not \"Other courses\")."
  def program_count(school), do: school |> in_school() |> Enum.reject(& &1.other?) |> length()

  def get(slug) when is_binary(slug), do: Map.get(@by_slug, slug)
  def get(_), do: nil

  @doc "A program's book slugs in program-guide order, each once."
  def books(%{courses: courses}), do: courses |> Enum.flat_map(& &1.books) |> Enum.uniq()

  @doc "Where a book sits: [{program, course name}], in program order. Empty for a book in no program."
  def for_book(slug) when is_binary(slug), do: @by_book |> Map.get(slug, []) |> Enum.map(fn {ps, c} -> {Map.fetch!(@by_slug, ps), c} end)
  def for_book(_), do: []

  @doc "True when a book sits in at least one program."
  def placed?(slug), do: Map.has_key?(@by_book, slug)
end
