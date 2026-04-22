defmodule CommerceFront.Repo.Migrations.AddStockistFeePercToUsers do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS stockist_fee_perc double precision DEFAULT 0.03"
    execute "UPDATE users SET stockist_fee_perc = 0.03 WHERE stockist_fee_perc IS NULL"
    execute "ALTER TABLE users ALTER COLUMN stockist_fee_perc SET NOT NULL"
  end

  def down do
    execute "ALTER TABLE users DROP COLUMN IF EXISTS stockist_fee_perc"
  end
end
