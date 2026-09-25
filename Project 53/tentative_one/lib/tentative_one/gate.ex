defmodule TentativeOne.Gate do
  @moduledoc """
  Assume 1. A step is a 0 only when it hits an inflection point:
  destroy, send, money, regulated data, an email address, a password.

  Word edges treat a hyphen as part of the word, so "pay-off" and
  "pii-free" stay 1s.
  """

  @l "(?<![\\w-])"
  @r "(?![\\w-])"

  @rules [
    password: Regex.compile!("#{@l}pass(word|code)s?#{@r}", "i"),
    regulated: Regex.compile!("#{@l}(ferpa|fti|glba|hipaa|pci|pii|ssn|social security)#{@r}|wgu\\.edu", "i"),
    address: ~r/[\w.+-]+@[\w-]+\.[\w.]+/,
    money:
      Regex.compile!(
        "\\$\\s?\\d|#{@l}(pay|pays|paid|buy|purchase|charge|refund|venmo)#{@r}" <>
          "|#{@l}wire#{@r}\\s+(it|the|money|funds|\\$)",
        "i"
      ),
    destroy: Regex.compile!("#{@l}(delete|remove|overwrite|erase|wipe|trash)#{@r}|#{@l}rm\\s+-", "i"),
    send: Regex.compile!("#{@l}(send|email|e-mail|post|publish|share|push|submit|tweet)#{@r}", "i")
  ]

  @type reason :: :destroy | :send | :money | :regulated | :address | :password

  @doc "The six reasons, in the order they are checked."
  def reasons, do: Keyword.keys(@rules)

  @spec classify(String.t()) :: :one | {:zero, reason}
  def classify(text) when is_binary(text) do
    case Enum.find(@rules, fn {_k, re} -> Regex.match?(re, text) end) do
      nil -> :one
      {reason, _} -> {:zero, reason}
    end
  end
end
