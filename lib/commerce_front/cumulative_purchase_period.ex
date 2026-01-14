defmodule CommerceFront.Settings.CumulativePurchasePeriod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cumulative_purchase_periods" do
    field :country_id, :integer
    field :desc, :string
    field :end_date, :naive_datetime
    field :label, :string
    field :start_date, :naive_datetime

    has_many :freebies, CommerceFront.Settings.CumulativePurchaseFreebie, foreign_key: :cumulative_purchase_period_id

    timestamps()
  end

  @doc false
  def changeset(cumulative_purchase_period, attrs) do
    cumulative_purchase_period
    |> cast(attrs, [:start_date, :end_date, :country_id, :label, :desc])
    # |> validate_required([:start_date, :end_date, :country_id, :label, :desc])
  end
end
