defmodule CommerceFront.Settings.CumulativePurchaseFreebie do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cumulative_purchase_freebies" do
    # field :cumulative_purchase_period_id, :integer
    field :drp, :integer
    field :pp, :integer
    belongs_to :product, CommerceFront.Settings.Product
    belongs_to :cumulative_purchase_period, CommerceFront.Settings.CumulativePurchasePeriod
    field :qty, :integer
    field :reward_type, :string
    field :total_cumulative_rp, :float
    field :tp, :integer

    timestamps()
  end

  @doc false
  def changeset(cumulative_purchase_freebie, attrs) do
    cumulative_purchase_freebie
    |> cast(attrs, [:total_cumulative_rp,
    :product_id, :qty, :pp, :drp, :tp, :reward_type, :cumulative_purchase_period_id])
    # |> validate_required([:total_cumulative_rp, :product_id, :qty, :pp, :drp, :tp, :reward_type, :cumulative_purchase_period_id])
  end
end
