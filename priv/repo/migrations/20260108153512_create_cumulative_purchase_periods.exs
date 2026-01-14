defmodule CommerceFront.Repo.Migrations.CreateCumulativePurchasePeriods do
  use Ecto.Migration

  def change do
    create table(:cumulative_purchase_periods) do
      add :start_date, :naive_datetime
      add :end_date, :naive_datetime
      add :country_id, references(:countries)
      add :label, :string
      add :desc, :string

      timestamps()
    end

  end
end
