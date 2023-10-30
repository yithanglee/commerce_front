defmodule CommerceFront.Settings.SalesItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sales_items" do
    field :item_name, :string
    field :item_price, :float
    field :qty, :integer
    field :remarks, :string
    field :sales_id, :integer

    timestamps()
  end

  @doc false
  def changeset(sales_item, attrs) do
    sales_item
    |> cast(attrs, [:sales_id, :item_name, :qty, :item_price, :remarks])
    |> validate_required([:sales_id, :item_name, :qty, :item_price, :remarks])
  end
end
