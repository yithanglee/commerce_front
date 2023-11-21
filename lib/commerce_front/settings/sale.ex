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
      canceled
    )
  )

  schema "sales" do
    field(:month, :integer)
    field(:remarks, :string)
    field(:sale_date, :date)
    field(:status, StatusEnum, default: :pending_confirmation)
    field(:subtotal, :float)
    field(:total_point_value, :integer)
    field(:registration_details, :binary)
    # field(:payment_id, :integer)
    has_one(:payment, CommerceFront.Settings.Payment, foreign_key: :sales_id)
    has_many(:sales_items, CommerceFront.Settings.SalesItem, foreign_key: :sales_id)

    # add :sales_person_id, :integer
    # field(:user_id, :integer)
    # this is the new user
    belongs_to(:user, CommerceFront.Settings.User)

    belongs_to(:sales_person, CommerceFront.Settings.User)
    field(:year, :integer)

    timestamps()
  end

  @doc false
  def changeset(sale, attrs) do
    sale
    |> cast(attrs, [
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
