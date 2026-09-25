defmodule LastTenYardsWeb.StoreHTML do
  use LastTenYardsWeb, :html
  embed_templates "store_html/*"
  def price(%{"cents" => c}) when is_integer(c), do: "$" <> :erlang.float_to_binary(c / 100, decimals: 2)
  def price(_), do: ""
end
