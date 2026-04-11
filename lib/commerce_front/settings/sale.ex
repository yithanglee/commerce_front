defmodule CommerceFront.Settings.Sale do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum

  defenum(
    StatusEnum,
    ~w(
      processing
      pending_confirmation
      preparing
      pending_delivery
      already_pickup
      pending_payment
      paid
      complete
      sent
      refund
      cancelled
    )
  )

  schema "sales" do
    field(:is_instalment, :boolean, default: false)
    field(:is_maintenance, :boolean, default: false)
    field(:has_freebies, :boolean, default: false)
    field(:month, :integer)
    field(:remarks, :string)
    field(:sale_date, :date)
    field(:status, StatusEnum, default: :pending_confirmation)
    field(:subtotal, :float)
    field(:shipping_method, :string)
    field(:shipping_company, :string)
    field(:shipping_ref, :string)
    field(:shipping_fee, :float, default: 0.0)
    field(:grand_total, :float, default: 0.0)
    field(:total_point_value, :float)
    field(:registration_details, :binary)
    # field(:payment_id, :integer)
    has_one(:payment, CommerceFront.Settings.Payment, foreign_key: :sales_id)
    has_many(:sales_items, CommerceFront.Settings.SalesItem, foreign_key: :sales_id)
    # field(:country_id, :integer)
    belongs_to(:country, CommerceFront.Settings.Country)
    # add :sales_person_id, :integer
    # field(:pick_up_point_id, :integer)
    belongs_to(:pick_up_point, CommerceFront.Settings.PickUpPoint)
    # field(:user_id, :integer)
    # this is the new user
    belongs_to(:user, CommerceFront.Settings.User)

    belongs_to(:sales_person, CommerceFront.Settings.User)
    field(:year, :integer)

    # field(:merchant_id, :integer)
    belongs_to(:merchant, CommerceFront.Settings.Merchant)
    timestamps()
  end

  @doc false
  def changeset(sale, attrs) do
    sale
    |> cast(attrs, [
      :is_maintenance,
      :is_instalment,
      :has_freebies,
      :merchant_id,
      :shipping_method,
      :shipping_company,
      :pick_up_point_id,
      :country_id,
      :shipping_ref,
      :shipping_fee,
      :grand_total,
      :sales_person_id,
      :registration_details,
      # :payment_id,
      :sale_date,
      :month,
      :year,
      :subtotal,
      :user_id,
      :status,
      :total_point_value,
      :remarks
    ])
    |> validate_required([
      :sale_date,
      :month,
      :year,
      :subtotal,
      # :user_id,
      :status,
      :total_point_value
    ])
  end
end
