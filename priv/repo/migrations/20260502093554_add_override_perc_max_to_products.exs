defmodule CommerceFront.Repo.Migrations.AddOverridePercMaxToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :override_perc_max, :float
    end
  end
end
