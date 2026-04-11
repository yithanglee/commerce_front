defmodule CommerceFront.Repo.Migrations.AddIsMaintenance do
  use Ecto.Migration

  def change do
    alter table("sales") do
      add :is_maintenance, :boolean, default: false
    end
  end
end
