defmodule CommerceFront.Settings.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:approved, :boolean, default: false)
    field(:bank_account_holder, :string)
    field(:bank_account_no, :string)
    field(:bank_name, :string)
    field(:blocked, :boolean, default: false)
    field(:crypted_password, :string)
    field(:password, :string, virtual: true)

    field(:temp_pin, :string)
    field(:email, :string)
    field(:fullname, :string)
    field(:ic_no, :string)
    field(:phone, :string)
    field(:rank_name, :string)
    field(:username, :string)
    belongs_to(:rank, CommerceFront.Settings.Rank)
    has_one(:royalty_user, CommerceFront.Settings.RoyaltyUser)
    has_one(:referral, CommerceFront.Settings.Referral)
    has_one(:sponsor, through: [:referral, :parent_user])
    field(:u2, :string, virtual: true)
    field(:u3, :string, virtual: true)
    has_one(:merchant, CommerceFront.Settings.Merchant)
    # field(:placement, :string, virtual: true)

    # field(:country_id, :integer)
    belongs_to(:country, CommerceFront.Settings.Country)
    field(:is_stockist, :boolean, default: false)
    has_one(:placement, CommerceFront.Settings.Placement)
    field(:stockist_user_id, :integer)

    has_many(:stockist_users, CommerceFront.Settings.User, foreign_key: :stockist_user_id)
    has_many(:ewallets, CommerceFront.Settings.Ewallet)
    has_many(:parent_ewallets, through: [:sponsor, :ewallets])
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :temp_pin,
      :country_id,
      :is_stockist,
      :stockist_user_id,
      :rank_id,
      :email,
      :username,
      :fullname,
      :phone,
      :ic_no,
      :crypted_password,
      :approved,
      :blocked,
      :rank_name,
      :bank_account_holder,
      :bank_account_no,
      :bank_name
    ])
    |> validate_required([
      # :email,
      :username
      # :fullname,
      # :phone
      # :ic_no,
      # :crypted_password,
      # :approved,
      # :blocked,
      # :rank_name,
      # :bank_account_holder,
      # :bank_account_no,
      # :bank_name
    ])
  end
end
