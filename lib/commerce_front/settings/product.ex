defmodule CommerceFront.Settings.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field(:qty, :integer, virtual: true)
    field(:category, :string)
    field(:category_id, :integer)
    field(:cname, :string)
    field(:desc, :binary)
    field(:img_url, :string)
    field(:name, :string)
    field(:point_value, :integer)
    field(:retail_price, :float)

    field(:can_pay_by_drp, :boolean, default: true)
    belongs_to(:first_payment_product, CommerceFront.Settings.Product)
    belongs_to(:instalment, CommerceFront.Settings.Instalment)

    has_many(:instalment_packages, CommerceFront.Settings.Product,
      foreign_key: :first_payment_product_id
    )

    has_many(:instalment_products, CommerceFront.Settings.InstalmentProduct,
      foreign_key: :instalment_product_id
    )

    # field(:instalment_id, :integer)
    field(:is_instalment, :boolean, default: false)
    # field(:first_payment_product_id, :integer)
    # field(:country_id, :integer)

    field(:override_pv_amount, :integer)

    field(:override_pv, :boolean, default: false)
    field(:override_perc, :float, default: 0.5)
    field(:override_perc_max, :float, default: 0.8)
    field(:override_special_share_payout, :boolean, default: false)
    field(:override_special_share_payout_perc, :float, default: 0.5)

    has_many(:product_stock, CommerceFront.Settings.ProductStock)

    has_many(:stocks, through: [:product_stock, :stock])
    has_many(:product_country, CommerceFront.Settings.ProductCountry)

    has_many(:countries, through: [:product_country, :country])

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :can_pay_by_drp,
      :first_payment_product_id,
      :instalment_id,
      :is_instalment,
      :override_perc,
      :override_perc_max,
      :override_pv,
      :override_pv_amount,
      :override_special_share_payout_perc,
      :override_special_share_payout,
      :img_url,
      :name,
      :cname,
      :category,
      :category_id,
      :desc,
      :retail_price,
      :point_value
    ])

    # |> validate_required([
    #   :img_url,
    #   :name,
    #   :cname,
    #   :category,
    #   :category_id,
    #   :desc,
    #   :retail_price,
    #   :point_value
    # ])
  end
end
