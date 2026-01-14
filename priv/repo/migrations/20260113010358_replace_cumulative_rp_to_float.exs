defmodule CommerceFront.Repo.Migrations.ReplaceCumulativeRpToFloat do
  use Ecto.Migration

  def change do
    alter table(:cumulative_purchase_freebies) do
      remove :total_cumulative_rp
      add :total_cumulative_rp, :float
    end

  end
end
