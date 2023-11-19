defmodule CommerceFront.Settings.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field(:amount, :float)
    field(:billplz_code, :string)
    field(:payment_url, :string)
    # field(:sales_id, :integer)
    belongs_to(:sales, CommerceFront.Settings.Sale)
    field(:webhook_details, :binary)

    timestamps()
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:sales_id, :amount, :billplz_code, :payment_url, :webhook_details])

    # |> validate_required([:sales_id, :amount, :billplz_code, :payment_url, :webhook_details])
  end
end
