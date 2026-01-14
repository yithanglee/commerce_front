defmodule CommerceFront.Repo.Migrations.CreateCumulativePurchaseFreebies do
  use Ecto.Migration

  def change do
    create table(:cumulative_purchase_freebies) do
      add :total_cumulative_rp, :string
      add :product_id, :integer
      add :qty, :integer
      add :pp, :integer
      add :drp, :integer
      add :tp, :integer
      add :reward_type, :string
      add :cumulative_purchase_period_id, references(:cumulative_purchase_periods)

      timestamps()
    end

  end
end
