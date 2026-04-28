defmodule CommerceFront.Repo.Migrations.AddIndexForUsersBinaryTree do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create_if_not_exists(index(:users, [:username], concurrently: true))

    create_if_not_exists(index(:placements, [:parent_user_id], concurrently: true))
    create_if_not_exists(index(:placements, [:user_id], concurrently: true))

    create_if_not_exists(
      index(:group_sales_summaries, [:day, :month, :year, :user_id], concurrently: true)
    )

    create_if_not_exists(
      index(:group_sales_summaries, [:month, :year, :user_id], concurrently: true)
    )
  end
end
