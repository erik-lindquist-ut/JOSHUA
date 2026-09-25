defmodule LastTenYardsWeb.ErrorHTML do
  use LastTenYardsWeb, :html
  def render(t, _), do: Phoenix.Controller.status_message_from_template(t)
end
