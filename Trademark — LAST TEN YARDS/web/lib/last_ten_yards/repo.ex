defmodule LastTenYards.Repo do
  use Ecto.Repo, otp_app: :last_ten_yards, adapter: Ecto.Adapters.Postgres
end
