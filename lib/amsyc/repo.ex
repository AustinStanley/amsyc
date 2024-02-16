defmodule Amsyc.Repo do
  use Ecto.Repo,
    otp_app: :amsyc,
    adapter: Ecto.Adapters.Postgres
end
