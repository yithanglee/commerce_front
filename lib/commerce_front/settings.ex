defmodule CommerceFront.Settings do
  @moduledoc """
  The Settings context.
  """
  require Logger
  # import Mogrify
  import Ecto.Query, warn: false
  alias CommerceFront.Repo
  require IEx
  alias Ecto.Multi

  import CommerceFront.Calculation,
    only: [
      biz_incentive_bonus: 4,
      matching_biz_incentive_bonus: 2,
      special_share_reward: 3,
      special_share_reward: 4,
      sharing_bonus: 4,
      team_bonus: 5,
      stockist_register_bonus: 4
    ]

  alias CommerceFront.Settings.Slide

  def list_slides(is_show) do
    Repo.all(from(s in Slide, where: s.is_show == ^is_show))
  end

  def get_slide!(id) do
    Repo.get!(Slide, id)
  end

  def append_bool_key(params, bool_key) do
    if bool_key in Map.keys(params) do
      params |> Map.put(bool_key, Map.get(params, bool_key) == "on")
    else
      params |> Map.put(bool_key, false)
    end
  end

  def create_slide(params \\ %{}) do
    bool_key = "is_show"
    params = append_bool_key(params, bool_key)

    Slide.changeset(%Slide{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_slide(model, params) do
    bool_key = "is_show"
    params = append_bool_key(params, bool_key)

    Slide.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_slide(%Slide{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.PickUpPoint

  def list_pick_up_points() do
    Repo.all(PickUpPoint)
  end

  def list_pick_up_point_by_country(country_id) do
    Repo.all(from(pup in PickUpPoint, where: pup.country_id == ^country_id))
  end

  def get_pick_up_point!(id) do
    Repo.get!(PickUpPoint, id)
  end

  def create_pick_up_point(params \\ %{}) do
    PickUpPoint.changeset(%PickUpPoint{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_pick_up_point(model, params) do
    PickUpPoint.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_pick_up_point(%PickUpPoint{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.UserSalesAddress

  def list_user_sales_addresses() do
    Repo.all(UserSalesAddress)
  end

  def list_user_sales_addresses_by_username(username) do
    Repo.all(
      from(usa in UserSalesAddress,
        left_join: u in CommerceFront.Settings.User,
        on: usa.user_id == u.id,
        where: u.username == ^username
      )
    )
  end

  def get_user_sales_address!(id) do
    Repo.get!(UserSalesAddress, id)
  end

  def create_user_sales_address(params \\ %{}) do
    check =
      Repo.all(
        from(usa in UserSalesAddress,
          where:
            usa.user_id == ^params["user_id"] and
              usa.line1 == ^params["line1"] and usa.line2 == ^params["line2"] and
              usa.city == ^params["city"]
        )
      )

    if check == [] do
      UserSalesAddress.changeset(%UserSalesAddress{}, params) |> Repo.insert() |> IO.inspect()
    else
      usa = check |> List.first()
      {:ok, usa}
    end
  end

  def update_user_sales_address(model, params) do
    UserSalesAddress.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_user_sales_address(%UserSalesAddress{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.State

  def list_states() do
    Repo.all(State)
  end

  def get_state!(id) do
    Repo.get!(State, id)
  end

  def create_state(params \\ %{}) do
    State.changeset(%State{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_state(model, params) do
    State.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_state(%State{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Country

  def list_countries() do
    Repo.all(Country)
  end

  def get_country_by_name(name) do
    Repo.all(from(c in Country, where: c.name == ^name)) |> List.first()
  end

  def get_malaysia() do
    Repo.get_by(Country, name: "Malaysia")
  end

  def get_country!(id) do
    Repo.get!(Country, id)
  end

  def create_country(params \\ %{}) do
    Country.changeset(%Country{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_country(model, params) do
    Country.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_country(%Country{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.RoyaltyUser

  def list_royalty_users() do
    Repo.all(RoyaltyUser)
  end

  def get_royalty_user!(id) do
    Repo.get!(RoyaltyUser, id)
  end

  def create_royalty_user(params \\ %{}) do
    RoyaltyUser.changeset(%RoyaltyUser{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_royalty_user(model, params) do
    RoyaltyUser.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_royalty_user(%RoyaltyUser{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.SessionUser

  def get_member_by_cookie(cookie) do
    Repo.all(from(s in SessionUser, where: s.cookie == ^cookie))
    |> List.first()
  end

  def get_cookie_user_by_cookie(cookie) do
    Repo.all(
      from(s in SessionUser, where: s.cookie == ^cookie, preload: [user: [role: :app_routes]])
    )
    |> List.first()
  end

  def list_session_users() do
    Repo.all(SessionUser)
  end

  def get_session_user!(id) do
    Repo.get!(SessionUser, id)
  end

  def create_session_user(params \\ %{}) do
    SessionUser.changeset(%SessionUser{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_session_user(model, params) do
    SessionUser.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_session_user(%SessionUser{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.AppRoute

  def list_app_routes() do
    Repo.all(AppRoute)
  end

  def get_app_route!(id) do
    Repo.get!(AppRoute, id)
  end

  def create_app_route(params \\ %{}) do
    bool_key = "can_get"
    params = append_bool_key(params, bool_key)

    bool_key = "can_post"
    params = append_bool_key(params, bool_key)

    check =
      Repo.all(
        from(ar in AppRoute, where: ar.name == ^params["name"] and ar.route == ^params["route"])
      )
      |> List.first()

    if check == nil do
      AppRoute.changeset(%AppRoute{}, params) |> Repo.insert() |> IO.inspect()
    else
      {:ok, check}
    end
  end

  def update_app_route(model, params) do
    bool_key = "can_get"
    params = append_bool_key(params, bool_key)

    bool_key = "can_post"
    params = append_bool_key(params, bool_key)
    AppRoute.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_app_route(%AppRoute{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Role

  def list_roles() do
    Repo.all(Role)
  end

  def get_role!(id) do
    Repo.get!(Role, id) |> Repo.preload(:app_routes)
  end

  def create_role(params \\ %{}) do
    Role.changeset(%Role{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_role(model, params) do
    Role.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_role(%Role{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.RoleAppRoute

  def list_role_app_routes() do
    Repo.all(RoleAppRoute)
  end

  def get_role_app_route!(id) do
    Repo.get!(RoleAppRoute, id)
  end

  def create_role_app_route(params \\ %{}) do
    sample = %{"AppRoute" => %{"1" => %{"1" => "on", "2" => "on"}}, "id" => "0"}

    role_id = Map.keys(params["AppRoute"]) |> List.first()

    items = params["AppRoute"][role_id] |> Map.keys()
    Repo.delete_all(from(rap in RoleAppRoute, where: rap.role_id == ^role_id))

    for item <- items do
      params = %{"role_id" => role_id, "app_route_id" => item}
      RoleAppRoute.changeset(%RoleAppRoute{}, params) |> Repo.insert() |> IO.inspect()
    end

    {:ok, %RoleAppRoute{id: 0}}
  end

  def update_role_app_route(model, params) do
    RoleAppRoute.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_role_app_route(%RoleAppRoute{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.ProductCountry

  def list_product_countries() do
    Repo.all(ProductCountry)
  end

  def get_product_country!(id) do
    Repo.get!(ProductCountry, id)
  end

  def create_product_country(params \\ %{}) do
    ProductCountry.changeset(%ProductCountry{}, params) |> Repo.insert() |> IO.inspect()

    product_id = Map.keys(params["Country"]) |> List.first()

    items = params["Country"][product_id] |> Map.keys()
    Repo.delete_all(from(rap in ProductCountry, where: rap.product_id == ^product_id))

    for item <- items do
      params = %{"product_id" => product_id, "country_id" => item}
      ProductCountry.changeset(%ProductCountry{}, params) |> Repo.insert() |> IO.inspect()
    end

    {:ok, %ProductCountry{id: 0}}
  end

  def update_product_country(model, params) do
    ProductCountry.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_product_country(%ProductCountry{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Staff

  def list_staffs() do
    Repo.all(Staff)
  end

  def get_staff!(id) do
    Repo.get!(Staff, id)
  end

  def create_staff(params \\ %{}) do
    Staff.changeset(%Staff{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_staff(model, attrs) do
    attrs =
      with true <- "password" in Map.keys(attrs),
           true <- attrs["password"] != "" do
        crypted_password =
          :crypto.hash(:sha512, attrs["password"]) |> Base.encode16() |> String.downcase()

        attrs |> Map.put("crypted_password", crypted_password)
      else
        _ ->
          attrs
      end

    Staff.changeset(model, attrs) |> Repo.update() |> IO.inspect()
  end

  def delete_staff(%Staff{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.WithdrawalBatch

  def list_withdrawal_batches() do
    Repo.all(WithdrawalBatch)
  end

  def get_withdrawal_batch!(id) do
    Repo.get!(WithdrawalBatch, id)
  end

  def create_withdrawal_batch(params \\ %{}) do
    bool_key = "is_open"
    params = append_bool_key(params, bool_key)

    WithdrawalBatch.changeset(%WithdrawalBatch{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_withdrawal_batch(model, params) do
    WithdrawalBatch.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_withdrawal_batch(%WithdrawalBatch{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.MerchantWithdrawal

  def list_merchant_withdrawals() do
    Repo.all(MerchantWithdrawal)
  end

  def get_merchant_withdrawal!(id) do
    Repo.get!(MerchantWithdrawal, id)
  end

  def create_merchant_withdrawal(params \\ %{}) do
    # MerchantWithdrawal.changeset(%MerchantWithdrawal{}, params) |> Repo.insert() |> IO.inspect()
    cg = MerchantWithdrawal.changeset(%MerchantWithdrawal{}, params)

    merchant = CommerceFront.Settings.get_merchant!(params["merchant_id"])

    wallet =
      list_ewallets_by_user_id(merchant.user_id)
      |> Enum.filter(&(&1.wallet_type == :merchant_bonus))
      |> List.first()

    cond do
      wallet == nil ->
        # String.to_integer(params["amount"]) < 100 ->
        {:error, Ecto.Changeset.add_error(cg, :amount, "You dont have merchant wallet")}

      String.to_integer(params["amount"]) > wallet.total ->
        {:error,
         Ecto.Changeset.add_error(
           cg,
           :amount,
           "Wallet insufficient, can withdraw: #{wallet.total}"
         )}

      true ->
        cg |> Repo.insert() |> IO.inspect()
    end
  end

  def update_merchant_withdrawal(model, params) do
    MerchantWithdrawal.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_merchant_withdrawal(%MerchantWithdrawal{} = model) do
    Repo.delete(model)
  end

  def delete_merchant_withdrawal_by_id(id) do
    Repo.delete(get_merchant_withdrawal!(id))
  end

  alias CommerceFront.Settings.WalletWithdrawal

  def list_wallet_withdrawals() do
    Repo.all(WalletWithdrawal)
  end

  def get_wallet_withdrawal!(id) do
    Repo.get!(WalletWithdrawal, id)
  end

  def create_wallet_withdrawal(params \\ %{}) do
    params =
      if "amount" in Map.keys(params) do
        amount = params |> Map.get("amount") |> Float.parse() |> elem(0)

        params =
          Map.merge(params, %{
            "final_amount_in_myr" => amount * 0.97 * 5,
            "amount_in_myr" => amount * 5,
            "processing_fee" => amount * 0.03,
            "processing_fee_in_myr" => amount * 0.03 * 5
          })
      else
        params
      end

    cg = WalletWithdrawal.changeset(%WalletWithdrawal{}, params)

    wallet =
      list_ewallets_by_user_id(params["user_id"])
      |> Enum.filter(&(&1.wallet_type == :bonus))
      |> List.first()

    {amount, _tail} = Float.parse(params["amount"])

    cond do
      amount < 50 ->
        {:error, Ecto.Changeset.add_error(cg, :amount, "Cannot be less than 50")}

      amount > wallet.total ->
        {:error,
         Ecto.Changeset.add_error(
           cg,
           :amount,
           "Wallet insufficient, can withdraw: #{wallet.total}"
         )}

      true ->
        cg |> Repo.insert() |> IO.inspect()
    end
  end

  def update_wallet_withdrawal(model, params) do
    params =
      if "amount" in Map.keys(params) do
        amount = params |> Map.get("amount") |> Float.parse() |> elem(0)

        params =
          Map.merge(params, %{
            "final_amount_in_myr" => amount * 0.97 * 5,
            "amount_in_myr" => amount * 5,
            "processing_fee" => amount * 0.03,
            "processing_fee_in_myr" => amount * 0.03 * 5
          })
      else
        params
      end

    WalletWithdrawal.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_wallet_withdrawal_by_id(id) do
    Repo.delete(get_wallet_withdrawal!(id))
  end

  def delete_wallet_withdrawal(%WalletWithdrawal{} = model) do
    Repo.delete(model)
  end

  def approve_merchant_withdrawal(id) do
    wb = CommerceFront.Settings.get_merchant_withdrawal!(id)

    merchant = CommerceFront.Settings.get_merchant!(wb.merchant_id)

    if wb.is_paid == false do
      Multi.new()
      |> Multi.run(:approve_withdrawal, fn _repo, %{} ->
        withdrawal = wb

        update_merchant_withdrawal(withdrawal, %{is_paid: true})

        CommerceFront.Settings.create_wallet_transaction(%{
          user_id: merchant.user_id,
          amount: (withdrawal.amount * -1) |> Float.round(2),
          remarks: "withdrawal to #{withdrawal.bank_name} #{withdrawal.bank_account_number}",
          wallet_type: "merchant_bonus"
        })

        {:ok, nil}
      end)
      |> Repo.transaction()
      |> case do
        {:ok, multi_res} ->
          {:ok, multi_res |> Map.get(:approve_withdrawal)}

        _ ->
          {:error, []}
      end
    else
      {:error, "already paid"}
    end
  end

  def approve_withdrawal_batch(id) do
    wb = get_withdrawal_batch!(id)

    if wb.paid_date == nil do
      withdrawals = Repo.all(from(ww in WalletWithdrawal, where: ww.withdrawal_batch_id == ^id))

      Multi.new()
      |> Multi.run(:approve_withdrawal, fn _repo, %{} ->
        res =
          for withdrawal <- withdrawals do
            update_wallet_withdrawal(withdrawal, %{is_paid: true})

            CommerceFront.Settings.create_wallet_transaction(%{
              user_id: withdrawal.user_id,
              amount: (withdrawal.amount * -0.97) |> Float.round(2),
              remarks:
                "withdrawal #{wb.code} to #{withdrawal.bank_name} #{withdrawal.bank_account_number}",
              wallet_type: "bonus"
            })

            CommerceFront.Settings.create_wallet_transaction(%{
              user_id: withdrawal.user_id,
              amount: (withdrawal.amount * -0.03) |> Float.round(2),
              remarks:
                "#{wb.code} processing fee #{withdrawal.amount} * 0.03 = #{withdrawal.amount * 0.03} ",
              wallet_type: "bonus"
            })
          end

        update_withdrawal_batch(wb, %{"paid_date" => Date.utc_today()})

        {:ok, nil}
      end)
      |> Repo.transaction()
      |> case do
        {:ok, multi_res} ->
          {:ok, multi_res |> Map.get(:approve_withdrawal)}

        _ ->
          {:error, []}
      end
    else
      {:error, "already paid"}
    end
  end

  alias CommerceFront.Settings.WalletTopup

  def list_wallet_topups() do
    Repo.all(WalletTopup)
  end

  def get_wallet_topup!(id) do
    Repo.get!(WalletTopup, id)
  end

  def create_wallet_topup(params \\ %{}) do
    IO.inspect(params)

    sample = %{
      "amount" => "120 ",
      "bank" => "MB2U",
      "id" => "0",
      "remarks" => "MYR 600",
      "user_id" => "292"
    }

    params = Map.put(params, "amount", String.replace(params["amount"], " ", ""))

    Multi.new()
    |> Multi.run(:wallet_topup, fn _repo, %{} ->
      WalletTopup.changeset(%WalletTopup{}, params) |> Repo.insert() |> IO.inspect()
    end)
    |> Multi.run(:payment, fn _repo, %{wallet_topup: wallet_topup} ->
      if wallet_topup.payment_method == "fpx" do
        wallet_topup = wallet_topup |> Repo.preload(:user)
        # res = Billplz.create_collection("Topup Order: #{wallet_topup.id}")
        # collection_id = Map.get(res, "id")

        # bill_res =
        #   Billplz.create_bill(collection_id, %{
        #     description: "Topup Order: #{wallet_topup.id}",
        #     email: wallet_topup.user.email,
        #     name: wallet_topup.user.fullname,
        #     amount: wallet_topup.amount * 5,
        #     phone: wallet_topup.user.phone
        #   })

        server_url = Application.get_env(:commerce_front, :url)

        payment_url =
          "#{server_url}/test_razer?chan=#{wallet_topup.bank}&amt=#{(wallet_topup.amount * 5) |> :erlang.float_to_binary(decimals: 2)}&ref_no=HAHOTOPUP#{wallet_topup.id}"

        create_payment(%{
          amount: wallet_topup.amount,
          wallet_topup_id: wallet_topup.id,
          billplz_code: "HAHOTOPUP#{wallet_topup.id}",
          payment_url: payment_url
          # webhook_details: params |> Jason.encode!()
        })

        # create_payment(%{
        #   payment_method: "fpx",
        #   amount: wallet_topup.amount,
        #   wallet_topup_id: wallet_topup.id,
        #   billplz_code: Map.get(bill_res, "id"),
        #   payment_url: Map.get(bill_res, "url")
        # })
      else
        create_payment(%{
          payment_method: wallet_topup.payment_method,
          amount: wallet_topup.amount,
          wallet_topup_id: wallet_topup.id
        })
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, multi_res} ->
        payment =
          if multi_res.wallet_topup.payment_method != "bank in slip" do
            case Razer.init(
                   multi_res.wallet_topup.bank,
                   (multi_res.wallet_topup.amount * 5) |> :erlang.float_to_binary(decimals: 2),
                   "HAHOTOPUP#{multi_res.wallet_topup.id}"
                 ) do
              %{status: :ok, url: url, params: params} ->
                payment_url = url

                {:ok, payment} =
                  update_payment(multi_res.payment, %{
                    payment_url: payment_url,
                    webhook_details: params |> Jason.encode!()
                  })

                payment

              _ ->
                multi_res.payment
            end
          else
            multi_res.payment
          end

        {:ok, multi_res |> Map.get(:wallet_topup) |> Map.put(:payment, payment)}

      _ ->
        {:error, []}
    end
  end

  def update_wallet_topup(model, params) do
    WalletTopup.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_wallet_topup(%WalletTopup{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Payment

  def list_payments() do
    Repo.all(Payment)
  end

  def get_payment_by_billplz_code(code) do
    Repo.get_by(Payment, billplz_code: code)
    |> Repo.preload(sales: [:user], wallet_topup: [:user])
  end

  def get_payment!(id) do
    Repo.get!(Payment, id)
  end

  def create_payment(params \\ %{}) do
    Payment.changeset(%Payment{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_payment(model, params) do
    Payment.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_payment(%Payment{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.PaymentChannel

  def list_payment_channels() do
    Repo.all(PaymentChannel)
  end

  def get_payment_channel_by_code(code) do
    Repo.get_by(PaymentChannel, code: code)
  end

  def get_payment_channel!(id) do
    Repo.get!(PaymentChannel, id)
  end

  def create_payment_channel(params \\ %{}) do
    sample = %{"active" => true, "category" => "razerpay", "code" => "BP-RZRMB2QR"}

    check = get_payment_channel_by_code(params["code"])

    if check == nil do
      PaymentChannel.changeset(%PaymentChannel{}, params) |> Repo.insert()
    else
      PaymentChannel.changeset(check, params) |> Repo.update()
    end
    |> IO.inspect()
  end

  def update_payment_channel(model, params) do
    PaymentChannel.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_payment_channel(%PaymentChannel{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.WalletType

  def list_wallet_types() do
    Repo.all(WalletType)
  end

  def get_wallet_type!(id) do
    Repo.get!(WalletType, id)
  end

  def create_wallet_type(params \\ %{}) do
    WalletType.changeset(%WalletType{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_wallet_type(model, params) do
    WalletType.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_wallet_type(%WalletType{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.EwalletTransfer

  def list_ewallet_transfers() do
    Repo.all(EwalletTransfer)
  end

  def get_ewallet_transfer!(id) do
    Repo.get!(EwalletTransfer, id)
  end

  def create_ewallet_transfer(params \\ %{}) do
    IO.inspect(params)

    from_username =
      Map.get(params, "from_username") |> CommerceFront.Settings.get_user_by_username()

    to_username = Map.get(params, "to_username") |> CommerceFront.Settings.get_user_by_username()

    with true <- from_username != nil,
         true <- to_username != nil do
      params =
        Map.merge(params, %{
          "from_user_id" => from_username.id,
          "to_user_id" => to_username.id
        })
        |> IO.inspect()

      EwalletTransfer.changeset(%EwalletTransfer{}, params) |> Repo.insert() |> IO.inspect()
    else
      _ ->
        nil
    end
  end

  def update_ewallet_transfer(model, params) do
    EwalletTransfer.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_ewallet_transfer(%EwalletTransfer{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Announcement

  def list_announcements() do
    Repo.all(Announcement)
  end

  def get_announcement!(id) do
    Repo.get!(Announcement, id)
  end

  def create_announcement(params \\ %{}) do
    Announcement.changeset(%Announcement{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_announcement(model, params) do
    Announcement.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_announcement(%Announcement{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Reward

  def list_rewards() do
    Repo.all(from(r in Reward, preload: :user))
  end

  def get_reward!(id) do
    Repo.get!(Reward, id)
  end

  def create_reward(params \\ %{}) do
    Reward.changeset(%Reward{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_reward(model, params) do
    Reward.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_reward(%Reward{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.WalletTransaction

  def list_wallet_transactions() do
    Repo.all(WalletTransaction)
  end

  def get_wallet_transaction!(id) do
    Repo.get!(WalletTransaction, id)
  end

  def update_wallet_transaction(model, params) do
    WalletTransaction.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_wallet_transaction(%WalletTransaction{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Ewallet

  def get_latest_wallet_transaction_by_user_id(user_id, wallet_type) do
    Repo.all(
      from(wt in WalletTransaction,
        left_join: ew in Ewallet,
        on: ew.id == wt.ewallet_id,
        where: wt.user_id == ^user_id and ew.wallet_type == ^wallet_type,
        order_by: [desc: wt.id],
        preload: [:ewallet]
      )
    )
    |> List.first()
  end

  def list_ewallets_by_user_id(id) do
    Repo.all(from(e in Ewallet, where: e.user_id == ^id))
  end

  def list_ewallets() do
    Repo.all(Ewallet)
  end

  def get_ewallet!(id) do
    Repo.get!(Ewallet, id)
  end

  def create_ewallet(params \\ %{}) do
    params |> IO.inspect()

    Multi.new()
    |> Multi.run(:ewallet, fn _repo, %{} ->
      Ewallet.changeset(%Ewallet{}, params) |> Repo.insert()
    end)
    |> Multi.run(:wallet_transaction, fn _repo, %{ewallet: ewallet} ->
      WalletTransaction.changeset(%WalletTransaction{}, %{
        ewallet_id: ewallet.id,
        user_id: ewallet.user_id,
        before: 0.00,
        amount: 0.00,
        after: 0.00,
        remarks: "initial"
      })
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> IO.inspect()
    |> case do
      {:ok, multi_res} ->
        {:ok, multi_res}

      _ ->
        {:error, []}
    end
  end

  @doc """

  this transaction need to have

  CommerceFront.Settings.create_wallet_transaction(  %{user_id: CommerceFront.Settings.finance_user.id, amount: 1.00, remarks: "something", wallet_type: "reserve" })

  CommerceFront.Settings.create_wallet_transaction(  %{user_id: 609, amount: 1100.00, remarks: "something", wallet_type: "direct_recruitment" })
  CommerceFront.Settings.create_wallet_transaction(  %{user_id: 695, amount: 0.00, remarks: "Initial", wallet_type: "merchant" })

  %{
    user_id: 1,
    amount: 100.00,
    remarks: "something",
    wallet_type: "bonus"
  }
  it will first find the wallet transaction first, if nid, need to create
  """
  def create_wallet_transaction(params \\ %{}) do
    Multi.new()
    |> Multi.run(:ewallet_n_transaction, fn _repo, %{} ->
      check = get_latest_wallet_transaction_by_user_id(params.user_id, params.wallet_type)

      if check == nil do
        create_ewallet(params |> Map.put(:total, 0.00))
      else
        {:ok, %{wallet_transaction: check, ewallet: check.ewallet}}
      end
      |> IO.inspect()
    end)
    |> Multi.run(:wallet_transaction, fn _repo, %{ewallet_n_transaction: ewallet} ->
      WalletTransaction.changeset(
        %WalletTransaction{},
        params
        |> Map.merge(%{
          before: ewallet.wallet_transaction.after |> Float.round(2),
          after: (ewallet.wallet_transaction.after + params.amount) |> Float.round(2),
          ewallet_id: ewallet.ewallet.id
        })
        |> IO.inspect()
      )
      |> Repo.insert()
    end)
    |> Multi.run(:ewallet, fn _repo,
                              %{
                                ewallet_n_transaction: ewallet,
                                wallet_transaction: wallet_transaction
                              } ->
      Ewallet.changeset(ewallet.ewallet, %{total: wallet_transaction.after}) |> Repo.update()
    end)
    |> Repo.transaction()
    |> IO.inspect()
    |> case do
      {:ok, multi_res} ->
        # {:ok, multi_res |> Map.get(:ewallet)}
        {:ok, multi_res}

      _ ->
        {:error, []}
    end
  end

  def update_ewallet(model, params) do
    Ewallet.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_ewallet(%Ewallet{} = model) do
    Repo.delete(model)
  end

  def reset_all_ewallet() do
    Repo.delete_all(WalletTransaction)
    Repo.delete_all(from(e in Ewallet))
  end

  alias CommerceFront.Settings.GroupSalesSummary

  def list_group_sales_summaries() do
    Repo.all(GroupSalesSummary)
  end

  def get_group_sales_summary!(id) do
    Repo.get!(GroupSalesSummary, id)
  end

  def get_latest_gs_summary_by_user_id(user_id, back_date \\ nil) do
    {y, m, d} =
      if back_date != nil do
        back_date
      else
        Date.utc_today()
      end
      |> Date.to_erl()

    subquery2 =
      from(gss in GroupSalesSummary,
        where:
          gss.month == ^m and
            gss.year == ^y and gss.user_id == ^user_id,
        select: %{
          sum_left: sum(gss.new_left),
          sum_right: sum(gss.new_right),
          user_id: gss.user_id
        },
        order_by: [asc: gss.user_id],
        group_by: [gss.user_id, gss.month, gss.year]
      )

    Repo.all(subquery2) |> IO.inspect()

    Repo.all(
      from(gss in GroupSalesSummary,
        full_join: gs2 in subquery(subquery2),
        on: gs2.user_id == gss.user_id,
        where:
          gss.user_id == ^user_id and
            gss.day == ^d and gss.month == ^m and
            gss.year == ^y,
        select: gss,
        select_merge: %{sum_left: gs2.sum_left, sum_right: gs2.sum_right}
      )
    )
    |> List.first()
  end

  def create_group_sales_summary(params \\ %{}) do
    GroupSalesSummary.changeset(%GroupSalesSummary{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_group_sales_summary(model, params) do
    GroupSalesSummary.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_group_sales_summary(%GroupSalesSummary{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.PlacementGroupSalesDetail

  def list_placement_group_sales_details() do
    Repo.all(PlacementGroupSalesDetail)
  end

  def get_placement_group_sales_detail!(id) do
    Repo.get!(PlacementGroupSalesDetail, id)
  end

  def create_placement_group_sales_detail(params \\ %{}, back_date \\ nil) do
    Multi.new()
    |> Multi.run(:gsd, fn _repo, %{} ->
      PlacementGroupSalesDetail.changeset(%PlacementGroupSalesDetail{}, params)
      |> Repo.insert()
    end)
    |> Multi.run(:gs_summary, fn _repo, %{gsd: gsd} ->
      check = get_latest_gs_summary_by_user_id(gsd.to_user_id, back_date)

      case check do
        nil ->
          map =
            if gsd.position == "left" do
              %{
                new_left: gsd.amount,
                total_left: gsd.amount,
                total_right: 0,
                balance_left: gsd.amount
              }
            else
              %{
                new_right: gsd.amount,
                total_left: 0,
                total_right: gsd.amount,
                balance_right: gsd.amount
              }
            end

          {y, m, d} =
            if back_date != nil do
              back_date |> Date.to_erl()
            else
              Date.utc_today() |> Date.to_erl()
            end

          create_group_sales_summary(
            %{
              total_left: 0,
              total_right: 0,
              user_id: gsd.to_user_id,
              day: d,
              month: m,
              year: y
            }
            |> Map.merge(map)
          )

        _ ->
          map =
            if gsd.position == "left" do
              %{
                new_left: check.new_left + gsd.amount,
                total_left: check.total_left + gsd.amount,
                balance_left: check.total_left + gsd.amount
              }
            else
              %{
                new_right: check.new_right + gsd.amount,
                total_right: check.total_right + gsd.amount,
                balance_right: check.total_right + gsd.amount
              }
            end

          {y, m, d} =
            if back_date != nil do
              back_date |> Date.to_erl()
            else
              Date.utc_today() |> Date.to_erl()
            end

          update_group_sales_summary(
            check,
            %{
              user_id: gsd.to_user_id,
              day: d,
              month: m,
              year: y
            }
            |> Map.merge(map)
          )
      end
    end)
    |> Multi.run(:gsd2, fn _repo, %{gsd: gsd, gs_summary: gs_summary} ->
      PlacementGroupSalesDetail.changeset(gsd, %{gs_summary_id: gs_summary.id})
      |> Repo.update()
    end)
    |> Repo.transaction()
    |> IO.inspect()
    |> case do
      {:ok, multi_res} ->
        gs_summary = multi_res |> Map.get(:gs_summary)
        {:ok, multi_res |> Map.get(:gsd) |> Map.put(:gs_summary, gs_summary)}

      _ ->
        {:error, []}
    end
  end

  def update_placement_group_sales_detail(model, params) do
    PlacementGroupSalesDetail.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_placement_group_sales_detail(%PlacementGroupSalesDetail{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.SalesItem

  def list_sales_items() do
    Repo.all(SalesItem)
  end

  def get_sales_item!(id) do
    Repo.get!(SalesItem, id)
  end

  def create_sales_item(params \\ %{}) do
    SalesItem.changeset(%SalesItem{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_sales_item(model, params) do
    SalesItem.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_sales_item(%SalesItem{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Sale

  def list_sales() do
    Repo.all(Sale)
  end

  def get_sale!(id) do
    Repo.get!(Sale, id)
    |> Repo.preload([:payment, :sales_person, :user, :sales_items, :pick_up_point])
  end

  def get_first_sales_by_user_id(id) do
    Repo.all(from(s in Sale, where: s.user_id == ^id))
  end

  def create_sale(params \\ %{}) do
    Sale.changeset(%Sale{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_sale(model, params) do
    Sale.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_sale(%Sale{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Product

  def list_products() do
    Repo.all(Product)
  end

  def get_product_by_name(name) do
    Repo.all(from(p in Product, where: p.name == ^name)) |> List.first()
  end

  def get_product!(id) do
    Repo.get!(Product, id)
    |> Repo.preload([:stocks, :countries, :instalment_packages, :first_payment_product])
  end

  def create_product(params \\ %{}) do
    Product.changeset(%Product{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_product(model, params) do
    Product.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_product(%Product{} = model) do
    Repo.delete(model)
  end

  @doc """
  Seed Luckydraw Event Promo Pack products (Malaysia only) and their component stock mappings.

  Intended to be run from terminal:

      mix run -e 'CommerceFront.Settings.seed_luckydraw_event_promo_packs()'
  """
  def seed_luckydraw_event_promo_packs() do
    country =
      case get_malaysia() do
        nil ->
          # Keep this safe + idempotent: Country schema doesn't require fields.
          {:ok, c} =
            create_country(%{
              name: "Malaysia",
              alias: "MY",
              currency: "MYR",
              conversion: 1.0,
              img_url: ""
            })

          c

        c ->
          c
      end

    get_or_create_stock = fn stock_name ->
      case Repo.get_by(CommerceFront.Settings.Stock, name: stock_name) do
        nil ->
          # Stocks are expected to already exist in your main DB.
          # But for fresh/local DBs, auto-create them so the seed can run end-to-end.
          {:ok, stock} =
            create_stock(%{
              name: stock_name,
              desc: "Auto-created by seed_luckydraw_event_promo_packs"
            })

          stock

        stock ->
          stock
      end
    end

    upsert_product_by_name = fn attrs ->
      name = Map.fetch!(attrs, :name)

      case get_product_by_name(name) do
        nil ->
          {:ok, p} = create_product(attrs)
          p

        product ->
          {:ok, p} = update_product(product, attrs)
          p
      end
    end

    set_product_country = fn product ->
      Repo.delete_all(
        from(pc in CommerceFront.Settings.ProductCountry, where: pc.product_id == ^product.id)
      )

      CommerceFront.Settings.ProductCountry.changeset(struct(CommerceFront.Settings.ProductCountry), %{
        product_id: product.id,
        country_id: country.id
      })
      |> Repo.insert()

      :ok
    end

    set_product_stocks = fn product, stock_qty_list ->
      Repo.delete_all(from(ps in CommerceFront.Settings.ProductStock, where: ps.product_id == ^product.id))

      for {stock_name, qty} <- stock_qty_list do
        stock = get_or_create_stock.(stock_name)

        CommerceFront.Settings.ProductStock.changeset(struct(CommerceFront.Settings.ProductStock), %{
          product_id: product.id,
          stock_id: stock.id,
          qty: qty
        })
        |> Repo.insert()
      end

      :ok
    end

    promo_a =
      upsert_product_by_name.(%{
        name: "Luckydraw Event Promo Pack A",
        cname: "Luckydraw Event Promo Pack A",
        category: "Luckydraw",
        category_id: 0,
        img_url: "null",
        retail_price: 100.0,
        point_value: 30,
        desc: """
        RP100 | 30PV

        Luckydraw Event Promo Pack A

        Includes:
        - Portable Air Purifier x1
        - Hsavior x1
        - Grand Convention Event Ticket x1
        - Lucky Draw Entry Ticket x1
        """
      })

    promo_b =
      upsert_product_by_name.(%{
        name: "Luckydraw Event Promo Pack B",
        cname: "Luckydraw Event Promo Pack B",
        category: "Luckydraw",
        category_id: 0,
        img_url: "null",
        retail_price: 100.0,
        point_value: 30,
        desc: """
        RP100 | 30PV

        Luckydraw Event Promo Pack B

        Includes:
        - Portable Air Purifier x1
        - RibenTox x1
        - TigerM x1
        - Grand Convention Event Ticket x1
        - Lucky Draw Entry Ticket x1
        """
      })

    promo_c =
      upsert_product_by_name.(%{
        name: "Luckydraw Event Promo Pack C",
        cname: "Luckydraw Event Promo Pack C",
        category: "Luckydraw",
        category_id: 0,
        img_url: "null",
        retail_price: 100.0,
        point_value: 30,
        desc: """
        RP100 | 30PV

        Luckydraw Event Promo Pack C

        Includes:
        - Hsavior x2
        - RibenTox x1
        - TigerM x1
        - Grand Convention Event Ticket x1
        - Lucky Draw Entry Ticket x1
        """
      })

    promo_d =
      upsert_product_by_name.(%{
        name: "Luckydraw Event Promo Pack D",
        cname: "Luckydraw Event Promo Pack D",
        category: "Luckydraw",
        category_id: 0,
        img_url: "null",
        retail_price: 100.0,
        point_value: 30,
        desc: """
        RP100 | 30PV

        Luckydraw Event Promo Pack D

        Includes:
        - LutiGlo x2
        - RibenTox x1
        - TigerM x1
        - Grand Convention Event Ticket x1
        - Lucky Draw Entry Ticket x1
        """
      })

    promo_e =
      upsert_product_by_name.(%{
        name: "Luckydraw Event Promo Pack E",
        cname: "Luckydraw Event Promo Pack E",
        category: "Luckydraw",
        category_id: 0,
        img_url: "null",
        retail_price: 100.0,
        point_value: 30,
        desc: """
        RP100 | 30PV

        Luckydraw Event Promo Pack E

        Includes:
        - Hsavior x1
        - LutiGlo x1
        - RibenTox x1
        - TigerM x1
        - Grand Convention Event Ticket x1
        - Lucky Draw Entry Ticket x1
        """
      })

    promo_f =
      upsert_product_by_name.(%{
        name: "Luckydraw Event Promo Pack F",
        cname: "Luckydraw Event Promo Pack F",
        category: "Luckydraw",
        category_id: 0,
        img_url: "null",
        retail_price: 100.0,
        point_value: 30,
        desc: """
        RP100 | 30PV

        Luckydraw Event Promo Pack F

        Includes:
        - FeCare x2
        - RibenTox x1
        - TigerM x1
        - Grand Convention Event Ticket x1
        - Lucky Draw Entry Ticket x1
        """
      })

    promo_g =
      upsert_product_by_name.(%{
        name: "Luckydraw Event Promo Pack G",
        cname: "Luckydraw Event Promo Pack G",
        category: "Luckydraw",
        category_id: 0,
        img_url: "null",
        retail_price: 100.0,
        point_value: 30,
        desc: """
        RP100 | 30PV

        Luckydraw Event Promo Pack G

        Includes:
        - RibenTox x5
        - Grand Convention Event Ticket x1
        - Lucky Draw Entry Ticket x1
        """
      })

    promo_h =
      upsert_product_by_name.(%{
        name: "Luckydraw Event Promo Pack H",
        cname: "Luckydraw Event Promo Pack H",
        category: "Luckydraw",
        category_id: 0,
        img_url: "null",
        retail_price: 100.0,
        point_value: 30,
        desc: """
        RP100 | 30PV

        Luckydraw Event Promo Pack H

        Includes:
        - TigerM x7
        - Grand Convention Event Ticket x1
        - Lucky Draw Entry Ticket x1
        """
      })

    promo_i =
      upsert_product_by_name.(%{
        name: "Luckydraw Event Promo Pack I",
        cname: "Luckydraw Event Promo Pack I",
        category: "Luckydraw",
        category_id: 0,
        img_url: "null",
        retail_price: 100.0,
        point_value: 30,
        desc: """
        RP100 | 30PV

        Luckydraw Event Promo Pack I

        Includes:
        - RibenTox x3
        - TigerM x3
        - Grand Convention Event Ticket x1
        - Lucky Draw Entry Ticket x1
        """
      })

    set_product_country.(promo_a)
    set_product_country.(promo_b)
    set_product_country.(promo_c)
    set_product_country.(promo_d)
    set_product_country.(promo_e)
    set_product_country.(promo_f)
    set_product_country.(promo_g)
    set_product_country.(promo_h)
    set_product_country.(promo_i)

    tickets = [{"Grand Convention Event Ticket", 1}, {"Lucky Draw Entry Ticket", 1}]

    set_product_stocks.(promo_a, [{"Portable Air Purifier", 1}, {"Hsavior", 1}] ++ tickets)
    set_product_stocks.(promo_b, [{"Portable Air Purifier", 1}, {"RibenTox", 1}, {"TigerM", 1}] ++ tickets)
    set_product_stocks.(promo_c, [{"Hsavior", 2}, {"RibenTox", 1}, {"TigerM", 1}] ++ tickets)
    set_product_stocks.(promo_d, [{"LutiGlo", 2}, {"RibenTox", 1}, {"TigerM", 1}] ++ tickets)
    set_product_stocks.(promo_e, [{"Hsavior", 1}, {"LutiGlo", 1}, {"RibenTox", 1}, {"TigerM", 1}] ++ tickets)
    set_product_stocks.(promo_f, [{"FeCare", 2}, {"RibenTox", 1}, {"TigerM", 1}] ++ tickets)
    set_product_stocks.(promo_g, [{"RibenTox", 5}] ++ tickets)
    set_product_stocks.(promo_h, [{"TigerM", 7}] ++ tickets)
    set_product_stocks.(promo_i, [{"RibenTox", 3}, {"TigerM", 3}] ++ tickets)

    %{
      status: :ok,
      country: country.name,
      products: [
        %{id: promo_a.id, name: promo_a.name, rp: promo_a.retail_price, pv: promo_a.point_value},
        %{id: promo_b.id, name: promo_b.name, rp: promo_b.retail_price, pv: promo_b.point_value},
        %{id: promo_c.id, name: promo_c.name, rp: promo_c.retail_price, pv: promo_c.point_value},
        %{id: promo_d.id, name: promo_d.name, rp: promo_d.retail_price, pv: promo_d.point_value},
        %{id: promo_e.id, name: promo_e.name, rp: promo_e.retail_price, pv: promo_e.point_value},
        %{id: promo_f.id, name: promo_f.name, rp: promo_f.retail_price, pv: promo_f.point_value},
        %{id: promo_g.id, name: promo_g.name, rp: promo_g.retail_price, pv: promo_g.point_value},
        %{id: promo_h.id, name: promo_h.name, rp: promo_h.retail_price, pv: promo_h.point_value},
        %{id: promo_i.id, name: promo_i.name, rp: promo_i.retail_price, pv: promo_i.point_value}
      ]
    }
    |> IO.inspect(label: "seed_luckydraw_event_promo_packs")
  end

  alias CommerceFront.Settings.Rank

  def list_ranks() do
    Repo.all(Rank)
  end

  def get_rank!(id) do
    Repo.get!(Rank, id)
  end

  def create_rank(params \\ %{}) do
    Rank.changeset(%Rank{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_rank(model, params) do
    Rank.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_rank(%Rank{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.User

  def member_token(id) do
    Repo.delete_all(from(su in CommerceFront.Settings.SessionUser, where: su.user_id == ^id))

    Phoenix.Token.sign(
      CommerceFrontWeb.Endpoint,
      "member_signature",
      %{id: id}
    )
  end

  def decode_admin_token(token) do
    case Phoenix.Token.verify(CommerceFrontWeb.Endpoint, "admin_signature", token) do
      {:ok, map} ->
        map

      {:error, _reason} ->
        nil
    end
  end

  def decode_token(token) do
    case Phoenix.Token.verify(CommerceFrontWeb.Endpoint, "member_signature", token) do
      {:ok, map} ->
        map

      {:error, _reason} ->
        nil
    end
  end

  def override_user(params) do
    user =
      Repo.all(from(u in User, where: u.username == ^params["username"]))
      |> List.first()

    with true <- user != nil,
         crypted_password <-
           :crypto.hash(:sha512, params["password"]) |> Base.encode16() |> String.downcase(),
         true <- crypted_password == user.temp_pin do
      {:ok, user} = User.changeset(user, %{temp_pin: nil}) |> Repo.update()
      user = user |> Repo.preload([:merchant, :rank, :stockist_users])
      {:ok, user}
    else
      _ ->
        {:error}
    end
  end

  def auth_user(params) do
    res =
      Repo.all(
        from(u in User,
          where: u.username == ^params["username"],
          preload: [:merchant, :rank, :stockist_users]
        )
      )

    user = res |> List.first() |> IO.inspect()

    with true <- user != nil,
         crypted_password <-
           :crypto.hash(:sha512, params["password"]) |> Base.encode16() |> String.downcase(),
         true <- crypted_password == user.crypted_password do
      {:ok, user}
    else
      _ ->
        {:error, res}
    end
  end

  def list_users() do
    Repo.all(User)
  end

  def get_user!(id) do
    Repo.all(from(u in User, where: u.id == ^id, preload: [:rank, :merchant])) |> List.first()
  end

  def create_user(attrs \\ %{}) do
    attrs =
      if "password" in Map.keys(attrs) do
        crypted_password =
          :crypto.hash(:sha512, attrs["password"]) |> Base.encode16() |> String.downcase()

        attrs |> Map.put("crypted_password", crypted_password)
      else
        attrs
      end

    User.changeset(%User{}, attrs) |> Repo.insert() |> IO.inspect()
  end

  def update_user(model, attrs) do
    attrs =
      with true <- "password" in Map.keys(attrs),
           true <- attrs["password"] != "" do
        crypted_password =
          :crypto.hash(:sha512, attrs["password"]) |> Base.encode16() |> String.downcase()

        attrs |> Map.put("crypted_password", crypted_password)
      else
        _ ->
          attrs
      end

    attrs =
      with true <- "temp_pin" in Map.keys(attrs),
           true <- attrs["temp_pin"] != "" do
        crypted_password =
          :crypto.hash(:sha512, attrs["temp_pin"]) |> Base.encode16() |> String.downcase()

        attrs |> Map.put("temp_pin", crypted_password)
      else
        _ ->
          attrs
      end

    # attrs =
    #   if "is_stockist" in Map.keys(attrs) do
    #     attrs |> Map.put("is_stockist", attrs["is_stockist"] == "on")
    #   else
    #     attrs
    #   end

    attrs =
      if "rank_id" in Map.keys(attrs) do
        attrs |> Map.put("rank_name", CommerceFront.Settings.get_rank!(attrs["rank_id"]).name)
      else
        attrs
      end

    cg =
      Multi.new()
      |> Multi.run(:user, fn _repo, %{} ->
        User.changeset(model, attrs) |> Repo.update()
      end)
      |> Multi.run(:placements, fn _repo, %{user: user} ->
        # user has many placements if its a stockist

        if user.is_stockist do
          stockist_users = user |> Repo.preload(:stockist_users) |> Map.get(:stockist_users)

          for stockist_user <- stockist_users do
            case stockist_user.username |> String.split("-") |> IO.inspect() do
              [username, position] ->
                {:ok, u} =
                  User.changeset(
                    stockist_user,
                    attrs
                    |> Map.take([
                      "fullname",
                      "phone",
                      "email",
                      "country_id",
                      "bank_account_holder",
                      "bank_account_no",
                      "bank_name"
                    ])
                    |> Map.put("username", attrs["username"] <> "-" <> position)
                  )
                  |> Repo.update()
                  |> IO.inspect()

              _ ->
                nil
            end
          end
        else
        end

        {:ok, nil}
      end)
      |> Repo.transaction()
      |> IO.inspect()

    # |> Multi.run(:merchant, fn _repo, %{user: user} ->
    #   if user.merchant != nil do
    #     Merchant.changeset(user.merchant, %{name: attrs["fullname"]}) |> Repo.update()
    #   else
    #     Merchant.changeset(%Merchant{}, %{name: attrs["fullname"], user_id: user.id}) |> Repo.insert()
    #   end
    # end)

    # User.changeset(model, attrs) |> Repo.update() |> IO.inspect()

    case cg do
      {:ok, multi_res} ->
        u =
          multi_res
          |> Map.get(:user)
          |> Repo.preload([:merchant, :rank])
          |> Map.put(
            :token,
            CommerceFront.Settings.member_token(multi_res |> Map.get(:user) |> Map.get(:id))
          )

        {:ok, u}

      {:error, cg} ->
        {:error, cg}
    end
  end

  def delete_user(%User{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Referral

  def list_referrals() do
    Repo.all(Referral)
  end

  def get_referral_by_username(username) do
    if username == "admin" do
      %{id: 0, user_id: 0}
    else
      res = Repo.all(from(u in User, where: u.username == ^username)) |> List.first()

      if res != nil do
        gs_summary = get_latest_gs_summary_by_user_id(res.id) |> BluePotion.sanitize_struct()

        gs_summary =
          if gs_summary != nil do
            gs_summary
          else
            %{
              total_left: 0,
              total_right: 0,
              balance_left: 0,
              balance_right: 0,
              new_left: 0,
              new_right: 0,
              sum_left: 0,
              sum_right: 0
            }
          end

        Repo.get_by(Referral, user_id: res.id)
        |> Repo.preload(:user)
        |> BluePotion.sanitize_struct()
        |> Map.merge(%{
          sum_left: gs_summary.sum_left,
          sum_right: gs_summary.sum_right
        })
      end
    end
  end

  def get_referral!(id) do
    Repo.get!(Referral, id)
  end

  def create_referral(params \\ %{}) do
    Referral.changeset(%Referral{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_referral(model, params) do
    Referral.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_referral(%Referral{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Placement

  def list_placements() do
    Repo.all(Placement)
  end

  def get_placement_by_username(username) do
    if username == "admin" do
      %{id: 0, user_id: 0}
    else
      res = Repo.all(from(u in User, where: u.username == ^username)) |> List.first()

      if res != nil do
        gs_summary = get_latest_gs_summary_by_user_id(res.id) |> BluePotion.sanitize_struct()

        gs_summary =
          if gs_summary != nil do
            gs_summary
          else
            %{
              total_left: 0,
              total_right: 0,
              balance_left: 0,
              balance_right: 0,
              new_left: 0,
              new_right: 0,
              sum_left: 0,
              sum_right: 0
            }
          end

        Repo.get_by(Placement, user_id: res.id)
        |> IO.inspect()
        |> Repo.preload(:user)
        |> BluePotion.sanitize_struct()
        |> Map.merge(%{
          total_left: gs_summary.total_left,
          total_right: gs_summary.total_right,
          balance_left: gs_summary.balance_left,
          balance_right: gs_summary.balance_right,
          new_left: gs_summary.new_left,
          new_right: gs_summary.new_right,
          sum_left: gs_summary.sum_left,
          sum_right: gs_summary.sum_right
        })
      end
    end
  end

  def get_placement!(id) do
    Repo.get!(Placement, id)
  end

  def create_placement(params \\ %{}) do
    Placement.changeset(%Placement{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_placement(model, params) do
    Placement.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_placement(%Placement{} = model) do
    Repo.delete(model)
  end

  def display_refer_tree(username) do
    list = check_downlines(username, :referral)
    display_tree(username, list, [], :referral, false, 0)
  end

  def display_place_tree(username, full \\ false) do
    username =
      if username == "first" do
        Repo.all(from(p in Placement, order_by: [asc: p.id], limit: 1, preload: :user))
        |> List.first()
        |> Map.get(:user)
        |> Map.get(:username)
      else
        username
      end

    list = check_downlines(username)

    tree = display_tree(username, list, [], :placement, false, 0, full)

    if tree != nil do
      [fl_child, far_left_data] = far_node("left", username, %{})

      [fr_child, far_right_data] = far_node("right", username, %{})

      map = %{
        far_left: far_left_data,
        far_left_child: fl_child,
        far_right: far_right_data,
        far_right_child: fr_child
      }

      tree
      |> Map.merge(map)
    end

    # tree
  end

  def far_node(position, username, tree \\ %{}, parent_username \\ nil) do
    IO.inspect("far #{username}")

    if username |> String.contains?("~") do
      [parent_username, parent_username]
    else
      list = check_downlines(username)

      tree =
        if tree == %{} do
          display_tree(username, list, [], :placement, false, 0, true)
        else
          tree
        end

      children = tree |> Map.get(:children)

      if :position in (Enum.map(children, &Map.keys(&1)) |> List.flatten() |> Enum.uniq()) do
        new_tree = children |> Enum.filter(&(&1.position == position)) |> List.first()

        if new_tree != nil do
          parent_username =
            if List.first(list) == nil do
              "~空"
            else
              List.first(list) |> Map.get(:parent_username)
            end

          far_node(
            position,
            new_tree |> Map.get(:name),
            new_tree,
            parent_username
          )
        else
          parent_username =
            if List.first(list) == nil do
              "~空"
            else
              List.first(list) |> Map.get(:parent_username)
            end

          [
            parent_username,
            parent_username
          ]
        end
      else
        [username, parent_username]
      end
    end
  end

  def find_weak_placement(
        tree,
        use_one_direction,
        first_node,
        prev_node \\ nil,
        forced_direction \\ nil
      ) do
    IO.inspect("from tree")
    IO.inspect(tree)

    if tree == nil do
      if first_node.left > first_node.right do
        # need to add to left + 1

        left = prev_node.left

        prev_node |> Map.put(:left, left + 1)
      else
        right = prev_node.right

        prev_node |> Map.put(:right, right + 1)
      end
    else
      items = tree |> Map.get(:children) |> Enum.reject(&(&1.id == 0))

      if use_one_direction do
        if forced_direction != nil do
          node = items |> Enum.filter(&(&1.position == forced_direction)) |> List.first()

          find_weak_placement(node, use_one_direction, first_node, tree, forced_direction)
        else
          node =
            if first_node.left > first_node.right do
              items |> Enum.filter(&(&1.position == "right")) |> List.first()
            else
              items |> Enum.filter(&(&1.position == "left")) |> List.first()
            end

          find_weak_placement(node, use_one_direction, first_node, tree)
        end
      else
        left = items |> Enum.filter(&(&1.position == "left")) |> List.first()

        right = items |> Enum.filter(&(&1.position == "right")) |> List.first()

        if tree.left > tree.right do
          find_weak_placement(right, use_one_direction, first_node, tree)
        else
          find_weak_placement(left, use_one_direction, first_node, tree)
        end
      end
    end
  end

  @doc """

  list = CommerceFront.Settings.check_downlines("elis", true)
      tree = CommerceFront.Settings.display_tree("elis", list, [], :placement, false, 0, full)
  """
  def display_tree(
        username \\ "damien",
        ori_data,
        transformed_children \\ [],
        tree \\ :placement,
        include_empty \\ true,
        count,
        full \\ false
      ) do
    Logger.info("[display tree] - Count: #{count} - #{username}")

    to_map = fn list ->
      if tree == :placement do
        [
          username,
          id,
          fullname,
          position,
          left,
          right,
          total_left,
          total_right,
          balance_left,
          balance_right,
          new_left,
          new_right,
          sum_left,
          sum_right
        ] = list |> String.split("|")

        zchildren =
          if include_empty do
            [%{id: 0, name: "~"}, %{id: 0, name: "~"}]
          else
            [%{id: 0, name: "~空"}]
          end

        map = %{
          left: left |> String.to_integer(),
          right: right |> String.to_integer(),
          name: username,
          children: zchildren,
          username: username,
          id: id |> String.to_integer(),
          fullname: fullname,
          position: position
        }

        if full do
          map
        else
          ranks = [
            "Bronze Package",
            "Silver Package",
            "Gold Package",
            "Shopper",
            "PreferredShopper"
          ]

          cranks = ["铜级套餐", "银级套餐", "金级套餐", "Shopper", "PreferredShopper"]
          display_rank = ranks |> Enum.at(cranks |> Enum.find_index(&(&1 == fullname)))

          map = %{
            left: left |> String.to_integer(),
            right: right |> String.to_integer(),
            total_left: total_left || 0,
            total_right: total_right || 0,
            balance_left: balance_left || 0,
            balance_right: balance_right || 0,
            sum_left: sum_left || 0,
            sum_right: sum_right || 0,
            new_left: new_left || 0,
            new_right: new_right || 0,
            name: username,
            children: zchildren,
            username: username,
            id: id |> String.to_integer(),
            fullname: fullname,
            rank_name: display_rank,
            position: position
          }

          map
          |> Map.put(
            :value,
            %{
              level: count,
              username: username,
              fullname: fullname,
              rank_name: display_rank,
              left: left |> String.to_integer(),
              right: right |> String.to_integer(),
              total_left: total_left || 0,
              total_right: total_right || 0,
              balance_left: balance_left || 0,
              balance_right: balance_right || 0,
              sum_left: sum_left || 0,
              sum_right: sum_right || 0,
              new_left: new_left || 0,
              new_right: new_right || 0,
              position: position
            }
            |> Jason.encode!()
          )
        end
      else
        [username, id, fullname, rank_name, sum_left, sum_right] = list |> String.split("|")

        zchildren =
          if include_empty do
            []
          else
            []
          end

        ranks = [
          "Bronze Package",
          "Silver Package",
          "Gold Package",
          "Shopper",
          "PreferredShopper"
        ]

        cranks = ["铜级套餐", "银级套餐", "金级套餐", "Shopper", "PreferredShopper"]
        display_rank = ranks |> Enum.at(cranks |> Enum.find_index(&(&1 == rank_name)))

        bg =
          case rank_name do
            "金级套餐" ->
              "bg-warning"

            "银级套餐" ->
              "bg-info"

            "PreferredShopper" ->
              "bg-danger"

            "Shopper" ->
              "bg-outline-primary text-primary"

            _ ->
              "bg-primary"
          end

        %{
          icon: "fa fa-user text-info",
          name: username <> " #{id}",
          text: """
          <span class='my-2'>
            <span class='p-1 my-2 left-box'>#{username}</span>
            <span class='m-0 px-1 ' style="width: 40%; position: absolute;right: 0px;">
              <span class="badge #{bg}"> #{display_rank}</span>
              <span class="text-sm text-secondary">(Placement Grp Sales: #{sum_left}PV | #{sum_right}PV)</span>
            </span>
          </span>
          """,
          children: zchildren,
          username: username,
          id: id |> String.to_integer(),
          fullname: fullname,
          sum_left: sum_left,
          sum_right: sum_right
        }
      end
    end

    transformed_children =
      ori_data
      |> Enum.map(&(&1 |> Map.get(:children)))
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.map(&(&1 |> to_map.()))

    # initial data
    map = ori_data |> Enum.filter(&(&1.parent_username == username)) |> List.first()

    # this transform will recursively call
    transform = fn list, ori_data ->
      if tree == :placement do
        [
          username,
          id,
          fullname,
          position,
          left,
          right,
          total_left,
          total_right,
          balance_left,
          balance_right,
          new_left,
          new_right,
          sum_left,
          sum_right
        ] = list

        display_tree(
          username,
          ori_data,
          transformed_children |> Enum.uniq(),
          tree,
          include_empty,
          count + 1,
          full
        )
      else
        [username, id, fullname, rank_name, sum_left, sum_right] = list

        # map = ori_data |> Enum.filter(&(&1.parent_username == username)) |> List.first()

        display_tree(
          username,
          ori_data,
          transformed_children,
          :referral,
          include_empty,
          count + 1,
          full
        )
      end
    end

    # this children is where all the branching start...
    children =
      if map != nil do
        if full do
          if Enum.count(map.children) < 2 do
            l =
              map.children
              |> Enum.uniq()
              |> Enum.map(&(&1 |> String.split("|") |> transform.(ori_data)))

            if tree == :placement do
              l ++ [%{id: 0, name: "~空", position: "left"}]
            else
              l
            end
          else
            if tree == :placement do
              map.children
              |> Enum.uniq()
              |> Enum.map(&(&1 |> String.split("|") |> transform.(ori_data)))
            else
              map.children
              |> Enum.uniq()
              |> Enum.map(&(&1 |> String.split("|") |> transform.(ori_data)))
            end
          end
        else
          if Enum.count(map.children) < 2 && count < 2 do
            l =
              map.children
              |> Enum.map(&(&1 |> String.split("|") |> transform.(ori_data)))

            if tree == :placement do
              l ++ [%{id: 0, name: "~空", position: "left"}]
            else
              l
            end
          else
            if tree == :placement do
              if count < 2 do
                map.children |> Enum.map(&(&1 |> String.split("|") |> transform.(ori_data)))
              else
                [
                  %{id: 0, name: "~ More", position: "left"}
                ]
              end
            else
              map.children |> Enum.map(&(&1 |> String.split("|") |> transform.(ori_data)))
            end
          end
        end
      else
        if tree == :placement do
          [
            %{id: 0, name: "~空", position: "right"}
          ]
        else
          []
        end
      end

    if map == nil do
      transformed_children
      |> Enum.filter(&(&1.username == username))
      |> Enum.uniq()
      |> List.first()

      # transformed_children   |> Enum.filter(&(&1.username == username))     |> Enum.uniq()    |> List.first()
    else
      smap =
        transformed_children
        |> Enum.filter(&(&1.username == username))
        |> Enum.uniq()
        |> List.first()

      if tree == :placement do
        smap =
          if smap == nil do
            get_placement_by_username(map.parent_username)
          else
            smap
          end

        inner_map = %{
          id: map.parent_id,
          name: map.parent_username,
          position: if(smap != nil, do: smap.position, else: "n/a"),
          left: if(smap != nil, do: smap.left, else: "n/a"),
          right: if(smap != nil, do: smap.right, else: "n/a"),
          children: children |> Enum.sort_by(& &1.position)
        }

        if full do
          inner_map
        else
          rank_name =
            if :fullname in Map.keys(smap) do
              smap.fullname
            else
              smap.user.rank_name
            end

          ranks = [
            "Bronze Package",
            "Silver Package",
            "Gold Package",
            "Shopper",
            "PreferredShopper"
          ]

          cranks = ["铜级套餐", "银级套餐", "金级套餐", "Shopper", "PreferredShopper"]
          display_rank = ranks |> Enum.at(cranks |> Enum.find_index(&(&1 == rank_name)))

          inner_map = %{
            id: map.parent_id,
            name: map.parent_username,
            fullname: if(smap != nil, do: display_rank, else: "n/a"),
            rank_name: display_rank,
            position: if(smap != nil, do: smap.position, else: "n/a"),
            left: if(smap != nil, do: smap.left, else: "n/a"),
            right: if(smap != nil, do: smap.right, else: "n/a"),
            total_left: if(smap != nil, do: smap.total_left, else: "n/a"),
            total_right: if(smap != nil, do: smap.total_right, else: "n/a"),
            new_left: if(smap != nil, do: smap.new_left, else: "n/a"),
            new_right: if(smap != nil, do: smap.new_right, else: "n/a"),
            balance_left: if(smap != nil, do: smap.balance_left, else: "n/a"),
            balance_right: if(smap != nil, do: smap.balance_right, else: "n/a"),
            sum_left: if(smap != nil, do: smap.sum_left, else: "n/a"),
            sum_right: if(smap != nil, do: smap.sum_right, else: "n/a"),
            children: children |> Enum.sort_by(& &1.position)
          }

          inner_map
          |> Map.put(
            :value,
            %{
              level: count,
              username: map.parent_username,
              fullname: if(smap != nil, do: display_rank, else: "n/a"),
              rank_name: display_rank,
              position: if(smap != nil, do: smap.position, else: "n/a"),
              left: if(smap != nil, do: smap.left, else: "n/a"),
              right: if(smap != nil, do: smap.right, else: "n/a"),
              total_left: if(smap != nil, do: smap.total_left, else: "n/a"),
              total_right: if(smap != nil, do: smap.total_right, else: "n/a"),
              balance_left: if(smap != nil, do: smap.balance_left, else: "n/a"),
              balance_right: if(smap != nil, do: smap.balance_right, else: "n/a"),
              sum_left: if(smap != nil, do: smap.sum_left, else: "n/a"),
              sum_right: if(smap != nil, do: smap.sum_right, else: "n/a"),
              new_left: if(smap != nil, do: smap.new_left, else: "n/a"),
              new_right: if(smap != nil, do: smap.new_right, else: "n/a")
            }
            |> Jason.encode!()
          )
        end
      else
        smap =
          if smap == nil do
            get_referral_by_username(map.parent_username)
          else
            smap
          end

        ranks = [
          "Bronze Package",
          "Silver Package",
          "Gold Package",
          "Shopper",
          "PreferredShopper"
        ]

        cranks = ["铜级套餐", "银级套餐", "金级套餐", "Shopper", "PreferredShopper"]
        display_rank = ranks |> Enum.at(cranks |> Enum.find_index(&(&1 == map.rank_name)))

        bg =
          case map.rank_name do
            "金级套餐" ->
              "bg-warning"

            "银级套餐" ->
              "bg-info"

            "PreferredShopper" ->
              "bg-danger"

            "Shopper" ->
              "bg-outline-primary text-primary"

            _ ->
              "bg-primary"
          end

        %{
          icon: "fa fa-user text-success",
          text: """
          <span class='my-2'>
            <span class='p-1 my-2 left-box'>#{username}</span>
            <span class='m-0 px-1 ' style="width: 40%;position: absolute;right: 0px;">

            <span class="badge #{bg}"> #{display_rank}</span>
                   <span class="text-sm text-secondary">(Placement Grp Sales: #{smap |> Map.get(:sum_left, 0)}PV | #{smap |> Map.get(:sum_right, 0)}PV)</span>

            </span>
          </span>
          """,
          id: map.parent_id,
          rank_name: display_rank,
          name: map.parent_username <> " #{if(smap != nil, do: smap.id, else: "n/a")}",
          sum_left: smap |> Map.get(:sum_left),
          sum_right: smap |> Map.get(:sum_right),
          children: children |> Enum.sort_by(& &1.id)
        }
      end
    end
  end

  def register_without_products(params) do
    multi =
      Multi.new()
      # |> Multi.run(:sales_person, fn _repo, %{} ->
      #   user = CommerceFront.Settings.get_user!(params["sales_person_id"]) |> Repo.preload(:rank)
      #   {:ok, user}
      # end)
      |> Multi.run(:user, fn _repo, %{} ->
        rank = CommerceFront.Settings.lowest_rank()

        create_user(params |> Map.merge(%{"rank_name" => rank.name, "rank_id" => rank.id}))
      end)
      |> Multi.run(:ewallets, fn _repo, %{user: user} ->
        wallets = ["bonus", "product", "register", "direct_recruitment"]

        for wallet_type <- wallets do
          CommerceFront.Settings.create_wallet_transaction(%{
            user_id: user.id,
            amount: 0.00,
            remarks: "initial",
            wallet_type: wallet_type
          })
        end

        {:ok, nil}
      end)
      |> Multi.run(:referral, fn _repo, %{user: user} ->
        parent_r = get_referral_by_username(params["sponsor"])

        create_referral(%{
          parent_user_id: parent_r.user_id,
          parent_referral_id: parent_r.id,
          user_id: user.id
        })
      end)
      |> Multi.run(:placement, fn _repo, %{user: user} ->
        {position, parent_p} =
          determine_position(params["sponsor"], true, params["placement"]["position"])

        create_placement(%{
          parent_user_id: parent_p.user_id,
          parent_placement_id: parent_p.id,
          position: position,
          user_id: user.id
        })
      end)
      |> Repo.transaction()
      |> IO.inspect()
  end

  def placement_counter_reset(id \\ nil) do
    if id != nil do
      item = CommerceFront.Settings.get_placement!(id) |> Repo.preload(:user)
      Logger.info("[check upline] - #{item.user.username}")
      uplines = CommerceFront.Settings.check_uplines(item.user.username) |> IO.inspect()

      for upline <- uplines do
        p = CommerceFront.Settings.get_placement!(upline.pt_parent_id)
        # c = CommerceFront.Settings.get_placement!(upline.pt_child_id) |> Repo.preload(:user)

        changes =
          if upline.pt_position == "left" do
            %{
              left: p.left + 1,
              right: p.right
            }
          else
            %{
              left: p.left,
              right: p.right + 1
            }
          end

        CommerceFront.Settings.Placement.changeset(p, changes) |> Repo.update()
      end
    else
      Repo.update_all(Placement, set: [left: 0, right: 0])

      items = Repo.all(from(p in Placement, order_by: [desc: p.id], preload: [:user]))

      for item <- items do
        Logger.info("[check upline] - #{item.user.username}")
        uplines = CommerceFront.Settings.check_uplines(item.user.username) |> IO.inspect()

        for upline <- uplines do
          p = CommerceFront.Settings.get_placement!(upline.pt_parent_id)
          # c = CommerceFront.Settings.get_placement!(upline.pt_child_id) |> Repo.preload(:user)

          changes =
            if upline.pt_position == "left" do
              %{
                left: p.left + 1,
                right: p.right
              }
            else
              %{
                left: p.left,
                right: p.right + 1
              }
            end

          CommerceFront.Settings.Placement.changeset(p, changes) |> Repo.update()
        end
      end
    end

    {:ok}
  end

  def latest_group_sales_details(username, position, back_date \\ nil) do
    Repo.all(
      from(pgsd in PlacementGroupSalesDetail,
        left_join: u in User,
        on: pgsd.to_user_id == u.id,
        where: u.username == ^username and pgsd.position == ^position,
        order_by: [desc: pgsd.id]
      )
    )
    |> List.first()
  end

  @doc """
  CommerceFront.Settings.contribute_group_sales("chingyee", 100, sales, placement)

  sales = CommerceFront.Settings.get_sale!(627)
  placement = CommerceFront.Settings.get_placement_by_username("yokechu")

  CommerceFront.Settings.contribute_group_sales("chingyee", 100, sales, placement)

  CommerceFront.Settings.contribute_group_sales("yokechu", -700, sales, placement)

  """

  def contribute_group_sales(
        from_username,
        amount,
        sales,
        placement,
        prev_multi \\ nil,
        back_date \\ nil
      ) do
    from_user = get_user_by_username(from_username)
    amount = amount |> :erlang.trunc()

    add_gs = fn upline, multi_query ->
      multi_query
      |> Multi.run(String.to_atom("parent_#{upline.parent}"), fn _repo, %{} ->
        latest = latest_group_sales_details(upline.parent, upline.pt_position)
        # position has to be the first upline's position

        case latest do
          nil ->
            create_placement_group_sales_detail(
              %{
                before: 0,
                after: amount,
                amount: amount,
                from_user_id: from_user.id,
                to_user_id: upline.parent_id,
                position: upline.pt_position,
                sales_id: sales.id,
                remarks: "from sales-#{sales.id}"
              },
              back_date
            )

          _ ->
            create_placement_group_sales_detail(
              %{
                before: latest.after,
                after: latest.after + amount,
                amount: amount,
                from_user_id: from_user.id,
                to_user_id: upline.parent_id,
                position: upline.pt_position,
                sales_id: sales.id,
                remarks: "from sales-#{sales.id}"
              },
              back_date
            )
        end

        # find the latest group sales details
        # create group sales details
      end)
    end

    uplines = check_uplines(from_username)

    if prev_multi != nil do
      multi = prev_multi
      Enum.reduce(uplines, multi, &add_gs.(&1, &2))
    else
      multi = Multi.new()

      Enum.reduce(uplines, multi, &add_gs.(&1, &2))
      |> Repo.transaction()
    end
  end

  def contribute_referral_group_sales(
        from_username,
        amount,
        sales,
        prev_multi \\ nil,
        back_date \\ nil
      ) do
    from_user = get_user_by_username(from_username)

    add_gs = fn upline, multi_query ->
      multi_query
      |> Multi.run(String.to_atom("parent_#{upline.parent}"), fn _repo, %{} ->
        latest = latest_referral_group_sales_details(upline.parent)
        # position has to be the first upline's position

        case latest do
          nil ->
            create_referral_group_sales_detail(
              %{
                before: 0,
                after: amount,
                amount: amount,
                user_id: upline.parent_id,
                sale_id: sales.id
                # remarks: "from sales-#{sales.id}"
              },
              back_date
            )

          _ ->
            create_referral_group_sales_detail(
              %{
                before: latest.after,
                after: latest.after + amount,
                amount: amount,
                # from_user_id: from_user.id,
                user_id: upline.parent_id,
                sale_id: sales.id
                # remarks: "from sales-#{sales.id}"
              },
              back_date
            )
        end

        # find the latest group sales details
        # create group sales details
      end)
    end

    uplines = check_uplines(from_username, :referral)

    if prev_multi != nil do
      multi = prev_multi
      Enum.reduce(uplines, multi, &add_gs.(&1, &2))
    else
      multi = Multi.new()

      Enum.reduce(uplines, multi, &add_gs.(&1, &2))
      |> Repo.transaction()
    end
  end

  @doc """
  from this sponsor_username,
  the placement itself have a left right counter,
  depending on the position that has a lowest number,
  dive deep down to the lowest , use that placement
  after placing it, need to get the upline and update the counter
  """

  def determine_position(sponsor_username, use_tree \\ true, forced_direction \\ nil) do
    if sponsor_username != "admin" do
      if use_tree do
        tree = CommerceFront.Settings.display_place_tree(sponsor_username, true)

        Logger.info("[determine_position] - ...")

        if tree != nil do
          card =
            CommerceFront.Settings.find_weak_placement(tree, true, tree, nil, forced_direction)

          position =
            cond do
              forced_direction != nil ->
                forced_direction

              card.left == card.right ->
                "left"

              card.left > card.right ->
                "right"

              card.right > card.left ->
                "left"
            end

          p = Repo.get_by(Placement, user_id: card.id) |> Repo.preload(:user)

          {position, p}
        else
          if forced_direction != nil do
            {forced_direction, get_placement_by_username(sponsor_username)}
          else
            {"left", get_placement_by_username(sponsor_username)}
          end
        end
      else
        placement = get_placement_by_username(sponsor_username)

        position =
          if placement.left > placement.right do
            "right"
          else
            "left"
          end

        {position, placement}
      end
    else
      {"left", get_placement_by_username(sponsor_username)}
    end
  end

  def today_bonus(bonus_name, date \\ Date.utc_today()) do
    {y, m, d} =
      date
      |> Date.to_erl()

    datetime = NaiveDateTime.from_erl!({{y, m, d}, {0, 0, 0}})
    end_datetime = datetime |> Timex.shift(days: 1)
    # check today's team bonus reward
    # check today's sales
    sales =
      Repo.all(
        from(r in CommerceFront.Settings.Reward,
          where: r.day == ^d and r.month == ^m and r.year == ^y and r.name == ^bonus_name,
          group_by: [r.name],
          select: %{sum: sum(r.amount), name: r.name}
        )
      )
  end

  def today_sales(date \\ Date.utc_today()) do
    {y, m, d} =
      date
      |> Date.to_erl()

    datetime = NaiveDateTime.from_erl!({{y, m, d}, {0, 0, 0}})
    end_datetime = datetime |> Timex.shift(days: 1)
    # check today's team bonus reward
    # check today's sales
    sales =
      Repo.all(
        from(s in CommerceFront.Settings.Sale,
          where:
            s.inserted_at > ^datetime and s.inserted_at < ^end_datetime and
              s.status not in ^[:pending_payment, :cancelled, :refund],
          select: %{total_pv: sum(s.total_point_value), sum: sum(s.subtotal), date: s.sale_date},
          group_by: [s.sale_date]
        )
      )
  end

  def this_month_sales(date \\ Date.utc_today()) do
    {y, m, d} =
      date
      |> Date.to_erl()

    datetime = NaiveDateTime.from_erl!({{y, m, 1}, {0, 0, 0}})
    end_datetime = datetime |> Timex.shift(months: 1)
    # check today's team bonus reward
    # check today's sales
    sales =
      Repo.all(
        from(s in CommerceFront.Settings.Sale,
          where:
            s.inserted_at > ^datetime and s.inserted_at < ^end_datetime and
              s.status not in ^[:pending_payment, :cancelled, :refund],
          select: %{total_pv: sum(s.total_point_value), sum: sum(s.subtotal), date: s.sale_date},
          group_by: [s.sale_date]
        )
      )
  end

  def reconstruct_monthly_referral_group_sales_summary(date \\ Date.utc_today()) do
    {y, m, d} =
      date
      |> Date.to_erl()

    {y, m, sd} = Timex.beginning_of_month(date) |> Date.to_erl()
    {y, m, ed} = Timex.end_of_month(date) |> Date.to_erl()

    datetime = NaiveDateTime.from_erl!({{y, m, sd}, {0, 0, 0}})
    end_datetime = NaiveDateTime.from_erl!({{y, m, ed}, {0, 0, 0}}) |> Timex.shift(days: 1)

    Multi.new()
    |> Multi.run(:delete_initial_entries, fn _repo, %{} ->
      {:ok, nil}
    end)
    |> Multi.run(:delete_remaining_entries, fn _repo, %{} ->
      ids =
        Repo.all(
          from(gss in CommerceFront.Settings.ReferralGroupSalesSummary,
            where:
              gss.month == ^m and
                gss.year == ^y,
            select: gss.id
          )
        )

      q2 =
        from(pgsd in CommerceFront.Settings.ReferralGroupSalesDetail)
        |> where(
          [pgsd],
          pgsd.referral_group_sales_summary_id in ^ids
        )

      Repo.delete_all(q2)

      Repo.delete_all(
        from(gss in CommerceFront.Settings.ReferralGroupSalesSummary,
          where:
            gss.month == ^m and
              gss.year == ^y
        )
      )

      Repo.delete_all(
        from(r in Reward,
          where:
            r.name == ^"royalty bonus" and r.month == ^m and r.year == ^y and r.is_paid == ^false
        )
      )

      {:ok, nil}
    end)
    |> Multi.run(:sales, fn _repo, %{} ->
      sales =
        Repo.all(
          from(s in CommerceFront.Settings.Sale,
            where: s.inserted_at > ^datetime and s.inserted_at < ^end_datetime,
            where: is_nil(s.merchant_id),
            preload: [:user, :sales_person],
            order_by: [asc: s.id]
          )
        )

      for sale <- sales do
        if sale.user != nil do
          {:ok, pgsd} =
            contribute_referral_group_sales(
              sale.user.username,
              sale.total_point_value,
              sale,
              nil,
              date
            )

          CommerceFront.Calculation.royalty_bonus(sale, sale.user, Date.from_erl!({y, m, ed}))
        end

        # after contribute you should be able to see the unilevel royalty bonus
      end

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  @doc """
  when the placement group sales details is in place, based on the inserted at date to reconstruct the group sales sumary

  maybe redo from the start of the month?
  CommerceFront.Settings.reconstruct_daily_group_sales_summary(~D[2024-07-15], :monthly)

  """
  def reconstruct_daily_group_sales_summary(date \\ Date.utc_today(), period \\ :daily) do
    {y, m, d} = date |> Date.to_erl()

    beginning_of_month = date |> Timex.beginning_of_month()

    {sy, sm, sd} =
      beginning_of_month
      |> Date.to_erl()

    datetime = NaiveDateTime.from_erl!({{y, m, d}, {0, 0, 0}})
    end_datetime = datetime |> Timex.shift(days: 1)
    start_datetime = NaiveDateTime.from_erl!({{sy, sm, sd}, {0, 0, 0}})

    Multi.new()
    |> Multi.run(:delete_initial_entries, fn _repo, %{} ->
      if date == ~D[2023-12-16] do
        # why need delete all?
        # if recalculate from offset?
        # mismatch between dates

        Repo.delete_all(GroupSalesSummary)
        Repo.delete_all(PlacementGroupSalesDetail)

        Repo.delete_all(
          from(r in Reward,
            where: r.name == "team bonus"
          )
        )
      else
        if period == :monthly do
          q4 =
            GroupSalesSummary
            |> where([gss], gss.day >= ^sd and gss.month == ^sm and gss.year == ^sy)

          r4 = Repo.delete_all(q4)

          Repo.delete_all(
            from(pgsd in PlacementGroupSalesDetail,
              where: pgsd.inserted_at > ^start_datetime and pgsd.inserted_at < ^end_datetime
            )
          )

          r5 =
            Repo.delete_all(
              from(r in Reward,
                where:
                  r.name == "team bonus" and r.day >= ^sd and r.month == ^sm and r.year == ^sy
              )
            )

          res =
            Repo.all(
              from(pgsd in PlacementGroupSalesDetail,
                full_join: gs in GroupSalesSummary,
                on: gs.id == pgsd.gs_summary_id,
                select: %{gs_id: gs.id, pgsd_id: pgsd.id}
              )
            )

          ids = res |> Enum.filter(&(&1.gs_id == nil)) |> Enum.map(& &1.pgsd_id)

          Repo.delete_all(from(pgsd in PlacementGroupSalesDetail, where: pgsd.id in ^ids))
        end
      end

      {:ok, nil}
    end)
    |> Multi.run(:delete_remaining_entries, fn _repo, %{} ->
      if period == :monthly do
        ids =
          Repo.all(
            from(gss in GroupSalesSummary,
              where:
                gss.day >= ^d and gss.month == ^m and
                  gss.year == ^y,
              select: gss.id
            )
          )

        q2 =
          from(pgsd in PlacementGroupSalesDetail)
          |> where(
            [pgsd],
            not ilike(pgsd.remarks, "bring forward%") and pgsd.gs_summary_id in ^ids
          )

        Repo.delete_all(q2)
      else
        check =
          CommerceFront.Repo.all(
            from(gss in CommerceFront.Settings.GroupSalesSummary,
              where:
                gss.day == ^d and gss.month == ^m and
                  gss.year == ^y
            )
          )

        ids =
          CommerceFront.Repo.all(
            from(gss in CommerceFront.Settings.GroupSalesSummary,
              where:
                gss.day == ^d and gss.month == ^m and
                  gss.year == ^y,
              select: gss.id
            )
          )

        q2 =
          from(pgsd in CommerceFront.Settings.PlacementGroupSalesDetail)
          |> where(
            [pgsd],
            not ilike(pgsd.remarks, "bring forward%") and pgsd.gs_summary_id in ^ids
          )

        q3 =
          from(pgsd in CommerceFront.Settings.PlacementGroupSalesDetail)
          |> where(
            [pgsd],
            ilike(pgsd.remarks, "bring forward%") and pgsd.gs_summary_id in ^ids
          )

        left_right_list = CommerceFront.Repo.all(q3)

        for gss <- check do
          left_right = left_right_list |> Enum.filter(&(&1.gs_summary_id == gss.id))

          left = left_right |> Enum.filter(&(&1.position == "left"))
          right = left_right |> Enum.filter(&(&1.position == "right"))

          beginning_left =
            if left != [] do
              left |> Enum.at(0) |> Map.get(:after) |> IO.inspect()
            else
              0
            end

          beginning_right =
            if right != [] do
              right |> Enum.at(0) |> Map.get(:after) |> IO.inspect()
            else
              0
            end

          cg =
            CommerceFront.Settings.GroupSalesSummary.changeset(gss, %{
              balance_left: beginning_left,
              balance_right: beginning_right,
              new_left: 0,
              new_right: 0,
              paired: nil,
              sum_left: nil,
              sum_right: nil,
              total_left: beginning_left,
              total_right: beginning_right
            })

          Repo.update(cg) |> IO.inspect()
        end

        CommerceFront.Repo.delete_all(q2)
      end

      {:ok, nil}
    end)
    |> Multi.run(:sales, fn _repo, %{} ->
      sales =
        if period == :monthly do
          Repo.all(
            from(s in CommerceFront.Settings.Sale,
              where: s.inserted_at > ^start_datetime and s.inserted_at < ^end_datetime,
              where: s.status not in ^[:cancelled, :pending_payment, :refund],
              preload: :user,
              order_by: [asc: s.id]
            )
          )
        else
          Repo.all(
            from(s in CommerceFront.Settings.Sale,
              where: s.inserted_at > ^datetime and s.inserted_at < ^end_datetime,
              where: s.status not in ^[:cancelled, :pending_payment, :refund],
              preload: :user,
              order_by: [asc: s.id]
            )
          )
        end

      if period == :monthly do
        group_date_sales = sales |> Enum.group_by(& &1.sale_date)

        # group_date_sales |> Map.keys() |> Enum.sort() |> IO.inspect()

        drange = Date.range(beginning_of_month |> Date.add(-1), date)

        for date_sale <- drange do
          sales = group_date_sales[date_sale]

          if sales != nil do
            for sale <- sales do
              if sale.user != nil do
                {:ok, pgsd} =
                  contribute_group_sales(
                    sale.user.username,
                    sale.total_point_value,
                    sale,
                    nil,
                    nil,
                    date_sale
                  )
              end
            end
          end

          # ~D[2024-04-19]
          CommerceFront.Calculation.daily_team_bonus(date_sale)

          CommerceFront.Settings.carry_forward_entry(date_sale)
        end
      else
        for sale <- sales do
          if sale.user != nil do
            {:ok, pgsd} =
              contribute_group_sales(
                sale.user.username,
                sale.total_point_value,
                sale,
                nil,
                nil,
                date
              )
          end
        end
      end

      # team_bonus(sale.user.username, sale.total_point_value, sale, nil, pgsd)

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  def _reconstruct_daily_group_sales_summary(date \\ Date.utc_today()) do
    {y, m, d} =
      date
      |> Date.to_erl()

    datetime = NaiveDateTime.from_erl!({{y, m, d}, {0, 0, 0}})
    end_datetime = datetime |> Timex.shift(days: 1)

    Multi.new()
    |> Multi.run(:delete_initial_entries, fn _repo, %{} ->
      if date == ~D[2023-12-16] do
        Repo.delete_all(GroupSalesSummary)
        Repo.delete_all(PlacementGroupSalesDetail)

        Repo.delete_all(
          from(r in Reward,
            where: r.name == "team bonus"
          )
        )
      end

      {:ok, nil}
    end)
    |> Multi.run(:delete_remaining_entries, fn _repo, %{} ->
      ids =
        Repo.all(
          from(gss in GroupSalesSummary,
            where:
              gss.day == ^d and gss.month == ^m and
                gss.year == ^y,
            select: gss.id
          )
        )

      q2 =
        from(pgsd in PlacementGroupSalesDetail)
        |> where(
          [pgsd],
          not ilike(pgsd.remarks, "bring forward%") and pgsd.gs_summary_id in ^ids
        )

      # need to exlude those carry forward and bring forward..

      # Repo.delete_all(
      #   from(gss in GroupSalesSummary,
      #     where:
      #       gss.day == ^d and gss.month == ^m and
      #         gss.year == ^y
      #   )
      # )

      Repo.delete_all(q2)

      {:ok, nil}
    end)
    |> Multi.run(:sales, fn _repo, %{} ->
      sales =
        Repo.all(
          from(s in CommerceFront.Settings.Sale,
            where: s.inserted_at > ^datetime and s.inserted_at < ^end_datetime,
            where: s.status not in ^[:cancelled, :pending_payment, :refund],
            preload: :user,
            order_by: [asc: s.id]
          )
        )

      for sale <- sales do
        if sale.user != nil do
          {:ok, pgsd} =
            contribute_group_sales(
              sale.user.username,
              sale.total_point_value,
              sale,
              nil,
              nil,
              date
            )
        end
      end

      # team_bonus(sale.user.username, sale.total_point_value, sale, nil, pgsd)

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  @doc """
  end of day, the balance from the summary need to carry forward to next day
  CommerceFront.Settings.carry_forward_entry(Date.utc_today() |> Timex.shift(days: -1))
  """
  def carry_forward_entry(from_date \\ Date.utc_today()) do
    query =
      from(pgsd in GroupSalesSummary,
        left_join: u in User,
        on: u.id == pgsd.user_id,
        where:
          pgsd.day == ^from_date.day and pgsd.month == ^from_date.month and
            pgsd.year == ^from_date.year and not is_nil(u.username),
        order_by: [asc: pgsd.id]
      )

    gs_summaries = Repo.all(query)

    sample = %CommerceFront.Settings.GroupSalesSummary{
      balance_left: 0,
      balance_right: 0,
      day: 19,
      id: 63363,
      inserted_at: ~N[2024-04-20 14:37:32],
      month: 4,
      new_left: 0,
      new_right: 690,
      paired: nil,
      sum_left: nil,
      sum_right: nil,
      total_left: 690,
      total_right: 690,
      updated_at: ~N[2024-04-20 14:37:35],
      user_id: 197,
      year: 2024
    }

    Multi.new()
    |> Multi.run(:carry_forward, fn _repo, %{} ->
      res =
        for gs_summary <-
              gs_summaries
              |> Enum.reject(&(&1.balance_left == nil && &1.balance_right == nil)) do
          gs_summary = gs_summary |> Repo.preload(:user)

          if gs_summary.user.username == "johortai" &&
               from_date in [~D[2024-04-19], ~D[2024-04-20]] do
            IO.inspect(gs_summary)
          end

          gs_summary =
            if gs_summary.new_left == 0 && gs_summary.new_right == 0 &&
                 gs_summary.balance_left == 0 && gs_summary.balance_right == 0 do
              gs_summary
              |> Map.put(:balance_left, gs_summary.total_left)
              |> Map.put(:balance_right, gs_summary.total_right)
            else
              # possible that bal left and right are 0, even without pairing

              with true <- gs_summary.new_left == 0 && gs_summary.new_right == 0 do
                if gs_summary.new_left > gs_summary.new_right do
                  gs_summary |> Map.put(:balance_left, gs_summary.total_left)
                else
                  gs_summary |> Map.put(:balance_right, gs_summary.total_right)
                end
              else
                # please test new 3 units
                _ ->
                  if gs_summary.new_left != 0 || gs_summary.new_right != 0 do
                    if gs_summary.balance_left == 0 && gs_summary.balance_right == 0 do
                      if gs_summary.new_left > gs_summary.new_right do
                        if gs_summary.total_left == gs_summary.total_right do
                          gs_summary |> Map.put(:balance_left, 0)
                        else
                          gs_summary |> Map.put(:balance_left, gs_summary.total_left)
                        end
                      else
                        if gs_summary.total_left == gs_summary.total_right do
                          gs_summary |> Map.put(:balance_right, 0)
                        else
                          gs_summary |> Map.put(:balance_right, gs_summary.total_right)
                        end
                      end
                    else
                      gs_summary
                    end
                  else
                    gs_summary
                  end
              end
            end

          {:ok, left} =
            CommerceFront.Settings.PlacementGroupSalesDetail.changeset(
              %CommerceFront.Settings.PlacementGroupSalesDetail{},
              %{
                before: gs_summary.balance_left,
                after: 0,
                amount: gs_summary.balance_left * -1,
                remarks: "carry forward",
                from_user_id: gs_summary.user_id,
                to_user_id: gs_summary.user_id,
                sales_id: 0,
                position: "left",
                gs_summary_id: gs_summary.id
              }
            )
            |> Repo.insert()

          {:ok, right} =
            CommerceFront.Settings.PlacementGroupSalesDetail.changeset(
              %CommerceFront.Settings.PlacementGroupSalesDetail{},
              %{
                before: gs_summary.balance_right,
                after: 0,
                amount: gs_summary.balance_right * -1,
                remarks: "carry forward",
                from_user_id: gs_summary.user_id,
                to_user_id: gs_summary.user_id,
                sales_id: 0,
                position: "right",
                gs_summary_id: gs_summary.id
              }
            )
            |> Repo.insert()

          to_date = from_date |> Timex.shift(days: 1)

          check_gs =
            Repo.all(
              from(gs in CommerceFront.Settings.GroupSalesSummary,
                where:
                  gs.user_id == ^gs_summary.user_id and gs.day == ^to_date.day and
                    gs.month == ^to_date.month and gs.year == ^to_date.year
              )
            )
            |> List.first()

          {:ok, gs} =
            if check_gs != nil do
              CommerceFront.Settings.GroupSalesSummary.changeset(
                check_gs,
                %{
                  new_left: 0,
                  new_right: 0,
                  total_left: 0,
                  total_right: 0,
                  user_id: gs_summary.user_id,
                  day: to_date.day,
                  month: to_date.month,
                  year: to_date.year
                }
              )
              |> Repo.update()
            else
              CommerceFront.Settings.GroupSalesSummary.changeset(
                %CommerceFront.Settings.GroupSalesSummary{},
                %{
                  new_left: 0,
                  new_right: 0,
                  total_left: 0,
                  total_right: 0,
                  user_id: gs_summary.user_id,
                  day: to_date.day,
                  month: to_date.month,
                  year: to_date.year
                }
              )
              |> Repo.insert()
            end

          # todo, check for existing PGSD entries

          CommerceFront.Settings.PlacementGroupSalesDetail.changeset(
            %CommerceFront.Settings.PlacementGroupSalesDetail{},
            %{
              before: 0,
              after: gs_summary.balance_left,
              amount: gs_summary.balance_left,
              remarks: "bring forward from #{left.id}",
              from_user_id: gs_summary.user_id,
              to_user_id: gs_summary.user_id,
              sales_id: 0,
              position: "left",
              gs_summary_id: gs.id
            }
          )
          |> Repo.insert()

          CommerceFront.Settings.PlacementGroupSalesDetail.changeset(
            %CommerceFront.Settings.PlacementGroupSalesDetail{},
            %{
              before: 0,
              after: gs_summary.balance_right,
              amount: gs_summary.balance_right,
              remarks: "bring forward from #{right.id}",
              from_user_id: gs_summary.user_id,
              to_user_id: gs_summary.user_id,
              sales_id: 0,
              position: "right",
              gs_summary_id: gs.id
            }
          )
          |> Repo.insert()

          CommerceFront.Settings.GroupSalesSummary.changeset(
            gs,
            %{
              total_left: gs_summary.balance_left,
              total_right: gs_summary.balance_right,
              balance_left: gs_summary.balance_left,
              balance_right: gs_summary.balance_right
            }
          )
          |> Repo.update()
        end

      {:ok, res}
    end)
    |> Repo.transaction()
  end

  def create_topup_transaction(params) do
    IO.inspect(params)

    Multi.new()
    |> Multi.run(:topup, fn _repo, %{} ->
      create_wallet_topup(params)
    end)
    |> Multi.run(:payment, fn _repo, %{topup: topup} ->
      # change to razer
      # res = Billplz.create_collection("Topup Order: #{topup.id}")
      # collection_id = Map.get(res, "id")

      # bill_res =
      #   Billplz.create_bill(collection_id, %{
      #     description: "Topup Order: #{topup.id}",
      #     email: params["user"]["email"],
      #     name: params["user"]["fullname"],
      #     amount: topup.amount * 5
      #   })
      server_url = Application.get_env(:commerce_front, :url) |> IO.inspect()

      create_payment(%{
        amount: topup.amount,
        wallet_topup_id: topup.id,
        billplz_code: "HAHOTOPUP#{topup.id}",
        payment_url:
          "#{server_url}/test_razer?chan=#{topup.bank}&amt=#{topup.amount * 5}&ref_no=HAHOTOPUP#{topup.id}"
      })
      |> IO.inspect()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, multi_res} ->
        {:ok, multi_res |> Map.get(:topup) |> Map.put(:payment, multi_res.payment)}

      _ ->
        {:error, []}
    end
  end

  @doc """
  this is to create the billplz link and let user to complete the flow



  """
  def create_sales_transaction(params) do
    sample = %{
      "_csrf_token" => "M1oBJw0lSBksOFRmMDwNei4NES0iHTIfykmjOKytbwmPbikBYiDFIDTo",
      "scope" => "register",
      "user" => %{
        "country_id" => "1",
        "email" => "a@1.com",
        "fullname" => "1",
        "password" => "[FILTERED]",
        "phone" => "1",
        "pick_up_point_id" => "2",
        "placement" => %{"position" => ""},
        "products" => %{
          "0" => %{
            "img_url" => "/images/uploads/5.jpg",
            "item_name" => "Product D",
            "item_price" => "50",
            "item_pv" => "25",
            "qty" => "6"
          },
          "1" => %{
            "img_url" => "/images/uploads/3.jpg",
            "item_name" => "Product C",
            "item_price" => "200",
            "item_pv" => "100",
            "qty" => "1"
          }
        },
        "rank_id" => "2",
        "sales_person_id" => "",
        "share_code" => "bc165de9-b13e-460f-9200-731ec7d599cb",
        "shipping" => %{
          "fullname" => "LEE YIT LIN",
          "phone" => "0122774254",
          "city" => "",
          "line1" => "",
          "line2" => "",
          "postcode" => "",
          "state" => "Johor"
        },
        "sponsor" => "",
        "username" => "susan1"
      }
    }

    stockist_user_id = params |> Map.get("user") |> Map.get("stockist_user_id")

    title =
      cond do
        params["user"] |> Map.get("redeem") != nil ->
          "Redeem"

        params["user"] |> Map.get("instalment") != nil ->
          "Instalment"

        params["user"] |> Map.get("upgrade") != nil ->
          "Upgrade"

        true ->
          "Sales"
      end

    # {:error, Ecto.Changeset.add_error(cg, :amount, "Cannot be less than 100")}
    share_link =
      if params["user"]["share_code"] != nil do
        CommerceFront.Settings.get_share_link_by_code(params["user"]["share_code"])
        |> Repo.preload(:user)
      end

    sponsor =
      cond do
        params["scope"] == "link_register" ->
          CommerceFront.Settings.get_user_by_username(share_link.user.username)
          |> Repo.preload(:rank)

        params["scope"] == "register" ->
          CommerceFront.Settings.get_user_by_username(params["user"]["sponsor"])
          |> Repo.preload(:rank)

        params["scope"] == "upgrade" ->
          target_user =
            if params["user"]["upgrade"] == "" do
              CommerceFront.Settings.get_user!(params["user"]["sales_person_id"])
            else
              CommerceFront.Settings.get_user_by_username(params["user"]["upgrade"])
            end

          referral =
            Repo.all(
              from(r in CommerceFront.Settings.Referral,
                where: r.user_id == ^target_user.id
              )
            )
            |> List.first()

          sponsor =
            with true <- referral.parent_user_id != nil,
                 refr <-
                   CommerceFront.Settings.get_user!(referral.parent_user_id),
                 true <- refr != nil do
              refr |> Repo.preload(:rank)
            else
              _ ->
                %{rank: %{name: "upgrade"}}
            end

          sponsor

        params["scope"] == "redeem" ->
          %{rank: %{name: "redeem"}}

        params["scope"] == "merchant_checkout" ->
          %{rank: %{name: "merchant_checkout"}}

        true ->
          nil
      end

    params =
      if params["scope"] == "link_register" do
        params =
          params
          |> Kernel.get_and_update_in(
            ["user", "sales_person_id"],
            &{&1, sponsor.id}
          )
          |> elem(1)

        # params =
        #   params
        #   |> Kernel.get_and_update_in(
        #     ["user", "payment"],
        #     &{&1, %{"method" => "bank_in"}}
        #   )
        #   |> elem(1)

        params =
          params
          |> Kernel.get_and_update_in(
            ["user", "placement", "position"],
            &{&1, share_link.position}
          )
          |> elem(1)

        params
        |> Kernel.get_and_update_in(
          ["user", "sponsor"],
          &{&1, sponsor.username}
        )
        |> elem(1)
      else
        params
      end

    form_drp =
      with true <- params["user"]["payment"]["drp"] != "",
           true <- params["user"]["payment"]["drp"] != nil do
        {amt, _p} = Float.parse(params["user"]["payment"]["drp"])
        amt
      else
        _ ->
          0
      end

    products = params |> Kernel.get_in(["user", "products"])
    shipping_fee = 0

    pres =
      for key <- Map.keys(products) do
        product_params = products[key] |> IO.inspect()

        p =
          if params["scope"] == "merchant_checkout" do
            CommerceFront.Settings.get_merchant_product_by_name(product_params["item_name"])
          else
            with true <- params["scope"] == "link_register",
                 true <- params |> Kernel.get_in(["user", "merchant"]) == "" do
              CommerceFront.Settings.get_merchant_product_by_name(product_params["item_name"])
            else
              _ ->
                get_product_by_name(product_params["item_name"])
            end
          end
          |> IO.inspect()

        r = p |> Map.put(:qty, product_params["qty"] |> String.to_integer())

        if title == "Instalment" do
          r
          |> Map.put(:remarks, params["user"]["instalment"])
        else
          r
        end
      end

    calc_rp = fn product, acc ->
      acc + product.retail_price * product.qty
    end

    total_rp = Enum.reduce(pres, 0, &calc_rp.(&1, &2))
    shipping_fee = 0

    shipping_fee =
      if CommerceFront.Settings.get_malaysia().id ==
           String.to_integer(params["user"]["country_id"]) do
        if params["user"]["pick_up_point_id"] != nil &&
             params["user"]["pick_up_point_id"] != "" do
          0
        else
          if params["scope"] == "merchant_checkout" do
            # Float.ceil(total_rp / 200) * 2
            total_rp * 0.025
            0
          else
            with true <- params["scope"] == "link_register",
                 true <- params |> Kernel.get_in(["user", "merchant"]) == "" do
              total_rp * 0.025
              0
            else
              _ ->
                if params["user"]["shipping"]["state"] in ["Sabah", "Sarawak", "Labuan"] do
                  Float.ceil(total_rp / 200) * 4
                else
                  if total_rp >= 36 do
                    shipping_fee
                  else
                    2
                  end
                end
            end
          end
        end
      else
        country_id = params |> Kernel.get_in(["user", "country_id"]) |> Integer.parse() |> elem(0)

        cond do
          get_country_by_name("Singapore").id == country_id ->
            if params["scope"] == "merchant_checkout" do
              total_rp * 0.1
              0
            else
              with true <- params["scope"] == "link_register",
                   true <- params |> Kernel.get_in(["user", "merchant"]) == "" do
                total_rp * 0.1
                0
              else
                _ ->
                  total_rp * 0.05
              end
            end

          true ->
            if params["scope"] == "merchant_checkout" do
              total_rp * 0.1
              0
            else
              with true <- params["scope"] == "link_register",
                   true <- params |> Kernel.get_in(["user", "merchant"]) == "" do
                total_rp * 0.1
                0
              else
                _ ->
                  total_rp * 0.1
              end
            end
        end
      end
      |> IO.inspect()

    shipping_fee =
      if title == "Instalment" do
        0
      else
        if stockist_user_id != nil do
          0
        else
          shipping_fee
        end
      end

    cond do
      total_rp - form_drp + shipping_fee < 0 ->
        {:error, "Too much drp used."}

      params |> Kernel.get_in(["user", "password"]) == "" ->
        {:error, "Please enter a password."}

      params |> Kernel.get_in(["user", "products"]) == nil ->
        {:error, "Please check cart items."}

      sponsor == nil && params["scope"] == "register" ->
        {:error, "Sponsor username not matched"}

      true ->
        Multi.new()
        |> Multi.run(:user_sale_address, fn _repo, %{} ->
          re =
            if params["user"]["pick_up_point_id"] != "" do
              {:ok, nil}
            else
              create_user_sales_address(
                params["user"]["shipping"]
                |> Map.put("user_id", params["user"]["sales_person_id"])
                |> Map.put("country_id", params["user"]["country_id"])
              )
            end

          re
        end)
        |> Multi.run(:sale, fn _repo, %{} ->
          pv = 0
          # need to check if DRP was used
          create_sale(%{
            is_instalment: title == "Instalment",
            pick_up_point_id: params["user"]["pick_up_point_id"],
            country_id: params["user"]["country_id"],
            month: Date.utc_today().month,
            year: Date.utc_today().year,
            sale_date: Date.utc_today(),
            status: :pending_payment,
            subtotal: 0,
            total_point_value: pv,
            registration_details: Jason.encode!(params),
            sales_person_id: params["user"]["sales_person_id"]
            # user_id: user.id
          })
        end)
        |> Multi.run(:sales2, fn _repo, %{sale: sale} ->
          sample = %{
            "0" => %{"item_name" => "Product C", "item_price" => "200", "qty" => "3"},
            "1" => %{"item_name" => "Product B", "item_price" => "500", "qty" => "2"},
            "2" => %{"item_name" => "Product A", "item_price" => "1000", "qty" => "1"}
          }

          products = params |> Kernel.get_in(["user", "products"])
          # shipping_fee = 0

          res =
            for key <- Map.keys(products) do
              product_params =
                if title == "Instalment" do
                  products[key]
                  |> Map.put("sales_id", sale.id)
                  |> Map.put("remarks", params["user"]["instalment"])
                else
                  products[key]
                  |> Map.put("sales_id", sale.id)
                end

              product_params =
                if product_params["item_pv"] == "null" do
                  product_params |> Map.put("item_pv", 0)
                else
                  product_params
                end

              {:ok, pres} = product_params |> CommerceFront.Settings.create_sales_item()

              p =
                if params["scope"] == "merchant_checkout" do
                  CommerceFront.Settings.get_merchant_product_by_name(product_params["item_name"])
                else
                  with true <- params["scope"] == "link_register",
                       true <- params |> Kernel.get_in(["user", "merchant"]) == "" do
                    CommerceFront.Settings.get_merchant_product_by_name(
                      product_params["item_name"]
                    )
                  else
                    _ ->
                      get_product_by_name(product_params["item_name"])
                  end
                end

              p |> Map.put(:qty, product_params["qty"] |> String.to_integer())
            end

          calc_rp = fn product, acc ->
            acc + product.retail_price * product.qty
          end

          total_rp = Enum.reduce(res, 0, &calc_rp.(&1, &2))

          calc_pv = fn product, acc ->
            if params["scope"] == "merchant_checkout" do
              acc + product.retail_price * product.qty
            else
              with true <- params["scope"] == "link_register",
                   true <- params |> Kernel.get_in(["user", "merchant"]) == "" do
                acc + product.retail_price * product.qty
              else
                _ ->
                  acc + product.point_value * product.qty
              end
            end
          end

          total_pv =
            with true <- params["user"]["rank_id"] != nil,
                 rank <- CommerceFront.Settings.get_rank!(params["user"]["rank_id"]),
                 true <- rank.point_value == 0 do
              0
            else
              _ ->
                Enum.reduce(res, 0, &calc_pv.(&1, &2)) |> :erlang.trunc()
            end
            |> IO.inspect()

          cg =
            %{
              total_point_value: total_pv |> IO.inspect(),
              subtotal: total_rp |> IO.inspect(),
              shipping_fee: shipping_fee |> IO.inspect(),
              grand_total: (total_rp + shipping_fee) |> IO.inspect()
            }
            |> IO.inspect()

          cg =
            if params["scope"] == "merchant_checkout" do
              mid = res |> List.first() |> Map.get(:merchant_id)
              Map.merge(cg, %{user_id: params["user"]["sales_person_id"], merchant_id: mid})
            else
              with true <- params["scope"] == "link_register",
                   true <- params |> Kernel.get_in(["user", "merchant"]) == "" do
                mid = res |> List.first() |> Map.get(:merchant_id)
                Map.merge(cg, %{user_id: params["user"]["sales_person_id"], merchant_id: mid})
              else
                _ ->
                  cg
              end
            end

          update_sale(sale, cg)
          |> IO.inspect()
        end)
        |> Multi.run(:sale3, fn _repo, %{sales2: sale} ->
          if params |> Kernel.get_in(["user", "back_month"]) == "" do
            Ecto.Changeset.cast(
              sale,
              %{inserted_at: DateTime.utc_now() |> Timex.shift(months: -1)},
              [:inserted_at]
            )
            |> Repo.update()
          else
            {:ok, nil}
          end
        end)
        |> Multi.run(:payment, fn _repo, %{sales2: sale} ->
          case params["user"]["payment"]["method"] do
            "product_point" ->
              wallets = CommerceFront.Settings.list_ewallets_by_user_id(sale.sales_person_id)
              pp = wallets |> Enum.filter(&(&1.wallet_type == :product)) |> List.first()

              check_sufficient = fn subtotal ->
                # deduct the ewallet

                with true <- (pp.total >= sale.subtotal) |> IO.inspect() do
                  {:ok, sale} = update_sale(sale, %{total_point_value: 0, status: :processing})

                  create_wallet_transaction(%{
                    user_id: sale.sales_person_id,
                    amount: sale.grand_total * -1,
                    remarks: "#{title}: #{sale.id}",
                    wallet_type: "product"
                  })

                  create_payment(%{
                    payment_method: "product_point",
                    amount: sale.grand_total,
                    sales_id: sale.id,
                    webhook_details: "pp paid: #{subtotal}"
                  })

                  {:ok, sale}
                else
                  _ ->
                    {:error, nil}
                end
              end

              case check_sufficient.(sale.grand_total) do
                # direct register liao...
                {:ok, sale} ->
                  {:ok, %CommerceFront.Settings.Payment{payment_url: "/sales/#{sale.id}"}}

                _ ->
                  {:error, "not sufficient"}
              end

            "bank_in" ->
              {:ok, %CommerceFront.Settings.Payment{payment_url: "/thank_you", user: nil}}

            "razer" ->
              chan = params["user"]["payment"]["channel"]
              server_url = Application.get_env(:commerce_front, :url)

              payment_url =
                "#{server_url}/test_razer?chan=#{chan}&amt=#{(sale.grand_total * 5) |> :erlang.float_to_binary(decimals: 2)}&ref_no=HAHOSALE#{sale.id}"

              {:ok, payment} =
                create_payment(%{
                  amount: sale.grand_total,
                  sales_id: sale.id,
                  billplz_code: "HAHOSALE#{sale.id}",
                  payment_url: payment_url
                  # webhook_details: params |> Jason.encode!()
                })

              payment =
                case Razer.init(
                       chan,
                       (sale.grand_total * 5) |> :erlang.float_to_binary(decimals: 2),
                       "HAHOSALE#{sale.id}"
                     ) do
                  %{status: :ok, url: url, params: params} ->
                    payment_url = url

                    {:ok, payment} =
                      update_payment(payment, %{
                        payment_url: payment_url,
                        webhook_details: params |> Jason.encode!()
                      })

                    payment

                  _ ->
                    payment
                end

              {:ok, payment}

            "fpx" ->
              res = Billplz.create_collection("#{title} Order: #{sale.id}")
              collection_id = Map.get(res, "id")

              bill_res =
                Billplz.create_bill(collection_id, %{
                  description: "#{title} Order: #{sale.id}",
                  email: params["user"]["email"],
                  name: params["user"]["shipping"]["fullname"],
                  amount: sale.grand_total * 5,
                  phone: params["user"]["shipping"]["phone"]
                })

              if Map.get(bill_res, "url") != nil do
                create_payment(%{
                  payment_method: "fpx",
                  amount: sale.grand_total,
                  sales_id: sale.id,
                  billplz_code: Map.get(bill_res, "id"),
                  payment_url: Map.get(bill_res, "url")
                })
              else
                {:error, nil}
              end

            "only_register_point" ->
              # check sales person... register point sufficient
              wallets = CommerceFront.Settings.list_ewallets_by_user_id(sale.sales_person_id)

              # drp = wallets |> Enum.filter(&(&1.wallet_type == :direct_recruitment)) |> List.first()
              rp = wallets |> Enum.filter(&(&1.wallet_type == :register)) |> List.first()

              check_sufficient = fn subtotal ->
                # here proceed to normal registration and deduct the ewallet

                with true <- (rp.total >= sale.grand_total) |> IO.inspect() do
                  {:ok, sale} =
                    update_sale(sale, %{
                      total_point_value: sale.total_point_value
                    })

                  create_wallet_transaction(%{
                    user_id: sale.sales_person_id,
                    amount: subtotal * -1,
                    remarks: "#{title}: #{sale.id}",
                    wallet_type: "register"
                  })

                  if params["scope"] == "register" || params["scope"] == "link_register" do
                    sponsor_username =
                      Jason.decode!(sale.registration_details)
                      |> Kernel.get_in(["user", "sponsor"])

                    sponsor = CommerceFront.Settings.get_user_by_username(sponsor_username)

                    create_wallet_transaction(%{
                      user_id: sponsor.id,
                      amount: (subtotal * 0.5) |> Float.round(2),
                      remarks: "#{title}: #{sale.id}",
                      wallet_type: "merchant"
                    })
                  end

                  if params["scope"] == "upgrade" do
                    target_user =
                      if params["user"]["upgrade"] == "" do
                        CommerceFront.Settings.get_user!(params["user"]["sales_person_id"])
                      else
                        CommerceFront.Settings.get_user_by_username(params["user"]["upgrade"])
                      end

                    referral =
                      Repo.all(
                        from(r in CommerceFront.Settings.Referral,
                          where: r.user_id == ^target_user.id
                        )
                      )
                      |> List.first()

                    sponsor = CommerceFront.Settings.get_user!(referral.parent_user_id)

                    if sponsor != nil do
                      create_wallet_transaction(%{
                        user_id: sponsor.id,
                        amount: (subtotal * 0.5) |> Float.round(2),
                        remarks: "#{title}: #{sale.id}",
                        wallet_type: "merchant"
                      })
                    end
                  end

                  create_payment(%{
                    payment_method: "only_register_point",
                    amount: sale.grand_total,
                    sales_id: sale.id,
                    webhook_details: "rp paid: #{subtotal}"
                  })

                  {:ok, sale}
                else
                  _ ->
                    {:error, nil}
                end
              end

              case check_sufficient.(sale.grand_total) do
                # direct register liao...

                {:ok, sale} ->
                  if params["scope"] != "merchant_checkout" do
                    # {:ok, user} = register(params["user"], sale)

                    # create_wallet_transaction(%{
                    #   user_id: user.id,
                    #   amount: sale.subtotal,
                    #   remarks: "#{title}: #{sale.id}",
                    #   wallet_type: "merchant"
                    # })

                    Elixir.Task.start_link(__MODULE__, :post_registration, [
                      params["user"],
                      sale,
                      title,
                      0
                    ])

                    # post_registration(
                    #   params["user"],
                    #   sale,
                    #   title,
                    #   0
                    # )

                    # CommerceFront.send_sqs(%{
                    #   "scope" => "register",
                    #   "user" => params["user"],
                    #   "sale_id" => sale.id,
                    #   "title" => title,
                    #   "form_drp" => 0
                    # })

                    if share_link != nil do
                      {:ok,
                       %CommerceFront.Settings.Payment{
                         payment_url: "/login",
                         user: %CommerceFront.Settings.User{}
                       }}
                    else
                      {:ok,
                       %CommerceFront.Settings.Payment{
                         payment_url: "/home",
                         user: %CommerceFront.Settings.User{}
                       }}
                    end
                  else
                    {:ok, sale} =
                      update_sale(sale, %{
                        status: :processing
                      })

                    sale = sale |> Repo.preload([:merchant, :user])

                    merchant = CommerceFront.Settings.get_merchant!(sale.merchant_id)
                    # collect 100
                    create_wallet_transaction(%{
                      user_id: merchant.user_id,
                      amount: sale.grand_total + sale.shipping_fee,
                      remarks:
                        "#{title}: #{sale.id} - Received RP (#{sale.total_point_value} + shipping (#{sale.shipping_fee}))",
                      wallet_type: "merchant_bonus"
                    })

                    # pay 10
                    create_wallet_transaction(%{
                      user_id: merchant.user_id,
                      amount: (sale.grand_total * 0.10 * -1) |> Float.round(2),
                      remarks: "#{title}: #{sale.id} - Platform Fee (10%)",
                      wallet_type: "merchant_bonus"
                    })

                    if "sponsor" in Map.keys(params["user"]) do
                      post_registration(
                        params["user"],
                        sale,
                        title,
                        0
                      )
                    end

                    if "upgrade" in Map.keys(params["user"]) do
                      post_registration(
                        params["user"],
                        sale,
                        title,
                        0
                      )
                    end

                    CommerceFront.Calculation.mp_sales_level_bonus(
                      sale.id,
                      0,
                      sale,
                      Date.utc_today(),
                      merchant
                    )

                    # pay 20
                    create_wallet_transaction(%{
                      user_id: merchant.user_id,
                      amount:
                        (sale.grand_total * merchant.commission_perc * -1) |> Float.round(2),
                      remarks:
                        "#{title}: #{sale.id} - Paid as commission (#{merchant.commission_perc})",
                      wallet_type: "merchant_bonus"
                    })

                    {:ok, %CommerceFront.Settings.Payment{payment_url: "/sales/#{sale.id}"}}
                  end

                _ ->
                  {:error, "not sufficient"}
              end

            "register_point" ->
              # check sales person... register point sufficient
              wallets = CommerceFront.Settings.list_ewallets_by_user_id(sale.sales_person_id)

              drp =
                wallets |> Enum.filter(&(&1.wallet_type == :direct_recruitment)) |> List.first()

              rp = wallets |> Enum.filter(&(&1.wallet_type == :register)) |> List.first()

              check_sufficient = fn subtotal ->
                # here proceed to normal registration and deduct the ewallet
                form_drp =
                  if params["user"]["payment"]["drp"] != nil do
                    # String.to_integer(params["user"]["payment"]["drp"])
                    {amt, _p} = Float.parse(params["user"]["payment"]["drp"])
                    amt
                  else
                    0
                  end

                with true <- :erlang.trunc(drp.total) >= form_drp,
                     true <- (rp.total >= sale.grand_total - form_drp) |> IO.inspect(),
                     fin_amt <- sale.total_point_value - form_drp do
                  fin_amt =
                    if fin_amt < 0 do
                      0
                    else
                      fin_amt
                    end

                  {:ok, sale} =
                    update_sale(sale, %{
                      total_point_value: fin_amt
                    })

                  create_wallet_transaction(%{
                    user_id: sale.sales_person_id,
                    amount: form_drp * -1,
                    remarks: "#{title}: #{sale.id}",
                    wallet_type: "direct_recruitment"
                  })

                  create_wallet_transaction(%{
                    user_id: sale.sales_person_id,
                    amount: (subtotal - form_drp) * -1,
                    remarks: "#{title}: #{sale.id}",
                    wallet_type: "register"
                  })

                  if params["scope"] == "register" do
                    sponsor_username =
                      Jason.decode!(sale.registration_details)
                      |> Kernel.get_in(["user", "sponsor"])

                    sponsor = CommerceFront.Settings.get_user_by_username(sponsor_username)

                    create_wallet_transaction(%{
                      user_id: sponsor.id,
                      amount: (subtotal * 0.5) |> Float.round(2),
                      remarks: "#{title}: #{sale.id}",
                      wallet_type: "merchant"
                    })
                  end

                  if params["scope"] == "upgrade" do
                    target_user =
                      if params["user"]["upgrade"] == "" do
                        CommerceFront.Settings.get_user!(params["user"]["sales_person_id"])
                      else
                        CommerceFront.Settings.get_user_by_username(params["user"]["upgrade"])
                      end

                    referral =
                      Repo.all(
                        from(r in CommerceFront.Settings.Referral,
                          where: r.user_id == ^target_user.id
                        )
                      )
                      |> List.first()

                    # sponsor_username =
                    #   Jason.decode!(sale.registration_details) |> Kernel.get_in(["user", "sponsor"])

                    sponsor = CommerceFront.Settings.get_user!(referral.parent_user_id)

                    create_wallet_transaction(%{
                      user_id: sponsor.id,
                      amount: ((subtotal - form_drp) * 0.5) |> Float.round(2),
                      remarks: "#{title}: #{sale.id}",
                      wallet_type: "merchant"
                    })
                  end

                  create_payment(%{
                    payment_method: "register_point",
                    amount: sale.grand_total,
                    sales_id: sale.id,
                    webhook_details: "rp paid: #{subtotal - form_drp}|drp paid: #{form_drp}"
                  })

                  {:ok, sale}
                else
                  _ ->
                    {:error, nil}
                end
              end

              case check_sufficient.(sale.grand_total) do
                # direct register liao...

                {:ok, sale} ->
                  form_drp =
                    if params["user"]["payment"]["drp"] != nil do
                      # String.to_integer(params["user"]["payment"]["drp"])
                      {amt, _p} = Float.parse(params["user"]["payment"]["drp"])
                      amt
                    else
                      0
                    end

                  Elixir.Task.start_link(__MODULE__, :post_registration, [
                    params["user"],
                    sale,
                    title,
                    form_drp
                  ])

                  # CommerceFront.send_sqs(%{
                  #   "scope" => "register",
                  #   "user" => params["user"],
                  #   "sale_id" => sale.id,
                  #   "title" => title,
                  #   "form_drp" => form_drp
                  # })

                  {:ok,
                   %CommerceFront.Settings.Payment{
                     payment_url: "/home",
                     user: %CommerceFront.Settings.User{}
                   }}

                _ ->
                  {:error, "not sufficient"}
              end

            "merchant_point" ->
              # when deduct the sponsor merchant point ,
              # 23/12/2024  = need to register preferred shopper
              # ensure these merchant checkout registered member dont passs up point in the the placment tree

              # check sales person... register point sufficient
              sponsor_wallets =
                if "sponsor" in Map.keys(params["user"]) do
                  # deduct sponsor MP
                  sponsor_username =
                    Jason.decode!(sale.registration_details)
                    |> Kernel.get_in(["user", "sponsor"])

                  sponsor = CommerceFront.Settings.get_user_by_username(sponsor_username)
                  CommerceFront.Settings.list_ewallets_by_user_id(sponsor.id)
                else
                  CommerceFront.Settings.list_ewallets_by_user_id(sale.sales_person_id)
                end

              wallets = CommerceFront.Settings.list_ewallets_by_user_id(sale.sales_person_id)

              merchant_p =
                sponsor_wallets |> Enum.filter(&(&1.wallet_type == :merchant)) |> List.first()

              rp = wallets |> Enum.filter(&(&1.wallet_type == :register)) |> List.first()

              check_sufficient = fn subtotal ->
                # here proceed to normal registration and deduct the ewallet
                form_drp =
                  if params["user"]["payment"]["drp"] != nil do
                    # String.to_integer(params["user"]["payment"]["drp"])
                    {amt, _p} = Float.parse(params["user"]["payment"]["drp"])
                    amt
                  else
                    0
                  end

                with true <- merchant_p.total >= form_drp,
                     true <- (rp.total >= sale.grand_total - form_drp) |> IO.inspect() do
                  # 2025-04-14: merchant sales ... total point value is from grand total..

                  {:ok, sale} =
                    update_sale(sale, %{
                      status: :processing,
                      total_point_value: sale.grand_total - form_drp
                    })

                  if "sponsor" in Map.keys(params["user"]) do
                    # deduct sponsor MP
                    sponsor_username =
                      Jason.decode!(sale.registration_details)
                      |> Kernel.get_in(["user", "sponsor"])

                    sponsor = CommerceFront.Settings.get_user_by_username(sponsor_username)

                    create_wallet_transaction(%{
                      user_id: sponsor.id,
                      amount: form_drp * -1,
                      remarks: "#{title}: #{sale.id}",
                      wallet_type: "merchant"
                    })
                  else
                    # when merchant upgrade need to deduct the shopper's sponsor MP...

                    create_wallet_transaction(%{
                      user_id: sale.sales_person_id,
                      amount: form_drp * -1,
                      remarks: "#{title}: #{sale.id}",
                      wallet_type: "merchant"
                    })
                  end

                  create_wallet_transaction(%{
                    user_id: sale.sales_person_id,
                    amount: (subtotal - form_drp) * -1,
                    remarks: "#{title}: #{sale.id}",
                    wallet_type: "register"
                  })

                  create_payment(%{
                    payment_method: "merchant_point",
                    amount: sale.grand_total,
                    sales_id: sale.id,
                    webhook_details: "rp paid: #{subtotal - form_drp}|mp paid: #{form_drp}"
                  })

                  {:ok, sale}
                else
                  _ ->
                    {:error, nil}
                end
              end

              case check_sufficient.(sale.grand_total) do
                {:ok, sale} ->
                  form_drp =
                    if params["user"]["payment"]["drp"] != nil do
                      # String.to_integer(params["user"]["payment"]["drp"])
                      {amt, _p} = Float.parse(params["user"]["payment"]["drp"])
                      amt
                    else
                      0
                    end

                  sale = sale |> Repo.preload([:merchant, :user])
                  merchant = CommerceFront.Settings.get_merchant!(sale.merchant_id)
                  # collect 100 + 10 - 20

                  ers =
                    create_wallet_transaction(%{
                      user_id: merchant.user_id,
                      amount: sale.total_point_value + sale.shipping_fee,
                      remarks:
                        "#{title}: #{sale.id} - Received: #{sale.total_point_value} RP + shipping fee  #{sale.shipping_fee}",
                      wallet_type: "merchant_bonus"
                    })

                  # pay 10

                  create_wallet_transaction(%{
                    user_id: merchant.user_id,
                    # amount: sale.total_point_value * 0.10 * -1,
                    amount: (sale.total_point_value * 0.10 * -1) |> Float.round(2),
                    remarks: "#{title}: #{sale.id} - Platform Fee (10%)",
                    wallet_type: "merchant_bonus"
                  })

                  # pay as commission 20

                  form_drp =
                    if params["user"]["payment"]["drp"] != nil do
                      # String.to_integer(params["user"]["payment"]["drp"])
                      {amt, _p} = Float.parse(params["user"]["payment"]["drp"])
                      amt
                    else
                      0
                    end

                  if "sponsor" in Map.keys(params["user"]) do
                    post_registration(
                      params["user"],
                      sale,
                      title,
                      form_drp
                    )
                  end

                  if "upgrade" in Map.keys(params["user"]) do
                    post_registration(
                      params["user"],
                      sale,
                      title,
                      form_drp
                    )
                  end

                  CommerceFront.Calculation.mp_sales_level_bonus(
                    sale.id,
                    0,
                    sale,
                    Date.utc_today(),
                    sale |> Map.get(:merchant)
                  )

                  create_wallet_transaction(%{
                    user_id: merchant.user_id,
                    amount:
                      (sale.total_point_value * merchant.commission_perc * -1)
                      |> Float.round(2),
                    remarks:
                      "#{title}: #{sale.id} - Paid as commission (#{(merchant.commission_perc * 100) |> :erlang.trunc()} %)",
                    wallet_type: "merchant_bonus"
                  })

                  {:ok, %CommerceFront.Settings.Payment{payment_url: "/sales/#{sale.id}"}}

                _ ->
                  {:error, "not sufficient"}
              end

            _ ->
              {:error, nil}
          end
        end)
        |> Repo.transaction()
    end
  end

  @doc """
  the registration is paid with RP
  which can be bought from company,
  admin just need to approve the RP purchase...

  during registration, the checkout contains the products


  %{
  "email" => "a@1.com",
  "fullname" => "1",
  "password" => "abc123",
  "payment" => %{"method" => "FPX"},
  "phone" => "1",
  "rank_id" => "3",
  "shipping" => %{
    "city" => "city",
    "fullname" => "1",
    "line1" => "line1",
    "line2" => "line2",
    "phone" => "1",
    "postcode" => "postcode",
    "state" => "state"
  },
  "sponsor" => "damien",
  "username" => "damien"
  }


  %{"_csrf_token" => "Aj5nclFzBBw3LSNZGDwRbgBQRjU8BBcWhNT7dDCvadnjrsb9yhpthNOZ", "scope" =>
  "register",
  "user" => %{"email" => "a@1.com", "fullname" => "1", "password" => "[FILTERED]", "payment" => %{"drp" => "", "method" => "only_register_point"}, "phone" => "1", "placement" => %{"direction" => "left"}, "products" => %{"0" => %{"img_url" => "/images/uploads/5.jpg", "item_name" => "Product D", "item_price" => "50", "item_pv" => "25", "qty" => "1"}}, "rank_id" => "4", "sales_person_id" => "585", "shipping" => %{"city" => "city", "fullname" => "1", "line1" => "line1", "line2" => "line2", "phone" => "1", "postcode" => "postcode", "state" => "Selangor"}, "sponsor" => "elis", "username" => "wer2"}}


    sample = %{
      "_csrf_token" => "FiMEETowA3AhJ10NHjc8Mj8SZjcMADxPCr5XyctIMWlJDhhKGYUdbTx5",
      "scope" => "merchant_checkout",
      "user" => %{
        "country_id" => "1",
        "merchant" => "",
        "payment" => %{"drp" => "6", "method" => "merchant_point"},
        "pick_up_point_id" => "",
        "products" => %{
          "0" => %{
            "img_url" => "/images/uploads/pic2.webp",
            "item_name" => "Rejuvenate",
            "item_price" => "30",
            "item_pv" => "null",
            "qty" => "1"
          }
        },
        "sales_person_id" => "544",
        "shipping" => %{
          "city" => "CITY",
          "fullname" => "ou01",
          "line1" => "sg 1",
          "line2" => "sg 2",
          "phone" => "019",
          "postcode" => "",
          "state" => "Kuala Lumpur"
        },
        "upgrade" => "ou01"
      }
    }




  post_registration(    "Sales", 690)
  """

  def post_registration(user_params, sale, title, form_drp) do
    {:ok, user} = register(user_params, sale)

    # if its a merchant mall
    if sale.merchant_id != nil do
      if "upgrade" in Map.keys(user_params) do
        sponsor = CommerceFront.Settings.get_user!(user_params["sales_person_id"])
        u = CommerceFront.Settings.get_user_by_username(user_params["upgrade"])

        create_wallet_transaction(%{
          user_id: u.id,
          amount: sale.subtotal * 0.2,
          remarks: "#{title}: #{sale.id}",
          wallet_type: "merchant"
        })

        create_wallet_transaction(%{
          user_id: sponsor.id,
          amount: sale.subtotal * 0.2,
          remarks: "#{title}: #{sale.id}",
          wallet_type: "merchant"
        })
      end

      if "sponsor" in Map.keys(user_params) do
        sponsor = CommerceFront.Settings.get_user_by_username(user_params["sponsor"])

        create_wallet_transaction(%{
          user_id: user.id,
          amount: sale.subtotal * 0.2,
          remarks: "#{title}: #{sale.id}",
          wallet_type: "merchant"
        })

        create_wallet_transaction(%{
          user_id: sponsor.id,
          amount: sale.subtotal * 0.2,
          remarks: "#{title}: #{sale.id}",
          wallet_type: "merchant"
        })
      end
    else
      create_wallet_transaction(%{
        user_id: user.id,
        amount: sale.subtotal,
        remarks: "#{title}: #{sale.id}",
        wallet_type: "merchant"
      })

      sale = sale |> Repo.preload(:sales_items)

      total_pv = sale.sales_items |> Enum.map(& &1.item_price) |> Enum.sum()

      final_form_drp = total_pv + sale.shipping_fee - form_drp

      if final_form_drp > 0 do
        if form_drp != 0 do
          unless "merchant" in Map.keys(user_params) do
            CommerceFront.Calculation.drp_sales_level_bonus(
              sale.id,
              final_form_drp,
              user,
              Date.utc_today()
            )
          else
          end
        end
      end
    end

    {:ok, user}
  end

  def register(params, sales) do
    usp = %{
      "country_id" => "1",
      "merchant" => "",
      "payment" => %{"drp" => "6", "method" => "merchant_point"},
      "pick_up_point_id" => "",
      "products" => %{
        "0" => %{
          "img_url" => "/images/uploads/pic2.webp",
          "item_name" => "Rejuvenate",
          "item_price" => "30",
          "item_pv" => "null",
          "qty" => "1"
        }
      },
      "sales_person_id" => "516",
      "shipping" => %{
        "city" => "CITY",
        "fullname" => "danny02",
        "line1" => "sg 1",
        "line2" => "sg 2",
        "phone" => "0189123",
        "postcode" => "POSTCODE",
        "state" => "Kuala Lumpur"
      },
      "upgrade" => "m1"
    }

    sample = %{
      "_csrf_token" => "JzsWXQkxHFoGGRxmPwFbfAV7BRQnY0QGutfpAzz5PkDWNBbKVM1sNV-5",
      "scope" => "merchant_checkout",
      "user" => usp
    }

    multi =
      Multi.new()
      |> Multi.run(:stockist_user, fn _repo, %{} ->
        stockist =
          with true <- params["stockist_user_id"] != nil,
               true <- params["stockist_user_id"] != "" do
            CommerceFront.Settings.get_user!(params["stockist_user_id"])
          else
            _ ->
              nil
          end

        {:ok, stockist}
      end)
      |> Multi.run(:sales_person, fn _repo, %{} ->
        user = CommerceFront.Settings.get_user!(params["sales_person_id"]) |> Repo.preload(:rank)
        {:ok, user}
      end)
      |> Multi.run(:user, fn _repo, %{sales_person: sales_person} ->
        if params["upgrade"] != nil do
          upgrade_target_user = get_user_by_username(params["upgrade"]) |> Repo.preload(:rank)

          upgrade_target_user =
            if params["upgrade"] == "" do
              CommerceFront.Settings.get_user!(params["sales_person_id"])
            else
              CommerceFront.Settings.get_user_by_username(params["upgrade"])
            end
            |> Repo.preload(:rank)

          c1 =
            if "merchant" in Map.keys(params) do
              CommerceFront.Settings.accumulated_sales_merchant(upgrade_target_user.username)
            else
              CommerceFront.Settings.accumulated_sales(upgrade_target_user.username)
            end

          c1 =
            if c1 == nil do
              0
            else
              c1
            end

          # upgrade_target_user.rank.retail_price
          total_pv =
            c1 +
              sales.subtotal

          # determine wat rank he reached based on new pv...
          ranks =
            CommerceFront.Settings.list_ranks()
            |> Enum.sort_by(& &1.retail_price)

          rank_from_pv =
            ranks
            |> Enum.filter(&(&1.retail_price <= total_pv))
            |> List.last()

          # never downgrade on upgrade: keep current rank if PV-based rank is lower
          current_rank = upgrade_target_user.rank

          new_rank =
            cond do
              is_nil(rank_from_pv) ->
                current_rank || List.first(ranks)

              is_nil(current_rank) ->
                rank_from_pv

              current_rank.retail_price >= rank_from_pv.retail_price ->
                current_rank

              true ->
                rank_from_pv
            end

          prm = %{
            rank_id: new_rank.id,
            rank_name: new_rank.name
          }

          if upgrade_target_user.rank.name in ["铜级套餐", "银级套餐", "金级套餐"] &&
               "merchant" in Map.keys(params) do
            {:ok, upgrade_target_user}
          else
            {:ok, upgrade_target_user} =
              CommerceFront.Settings.update_user(upgrade_target_user, prm)

            {:ok, upgrade_target_user |> Map.put(:rank, new_rank)}
          end
        else
          rank = get_rank!(params["rank_id"])

          create_user(params |> Map.put("rank_name", rank.name))
        end
      end)
      |> Multi.run(:ewallets, fn _repo, %{user: user} ->
        if params["upgrade"] != nil do
        else
          wallets = ["bonus", "product", "register", "direct_recruitment", "travel"]

          for wallet_type <- wallets do
            CommerceFront.Settings.create_wallet_transaction(%{
              user_id: user.id,
              amount: 0.00,
              remarks: "initial",
              wallet_type: wallet_type
            })
          end
        end

        {:ok, nil}
      end)
      |> Multi.run(:sale, fn _repo, %{user: user} ->
        # rank = get_rank!(params["rank_id"])
        # pv = rank.point_value

        # # need to check if DRP was used
        if params["stockist"] != nil do
          {:ok, nil}
        else
          update_sale(sales, %{
            month: Date.utc_today().month,
            year: Date.utc_today().year,
            sale_date: Date.utc_today(),
            status: :processing,
            user_id: user.id
          })
        end
        |> IO.inspect()
      end)
      |> Multi.run(:member_instalment, fn _repo, %{sale: sale, user: user} ->
        sale = sale |> Repo.preload(:sales_items)

        with false <- "merchant" in Map.keys(params),
             true <- sale != nil,
             sales_items <- sale.sales_items do
          IO.inspect(sales_items, label: "sales_items")

          for item <- sales_items do
            product = get_product_by_name(item |> Map.get(:item_name))

            cond do
              product.is_instalment ->
                mi =
                  Repo.all(
                    from(mi in CommerceFront.Settings.MemberInstalment,
                      where:
                        mi.user_id == ^user.id and mi.product_id == ^product.id and
                          mi.is_paid == ^false
                    )
                  )
                  |> List.first()

                freebie = mi |> Repo.preload(:freebie) |> Map.get(:freebie)

                if freebie != nil do
                  CommerceFront.Settings.update_sale(sale, %{has_freebies: true})
                end

                CommerceFront.Settings.update_member_instalment(mi, %{is_paid: true})

              item.remarks != nil ->
                check = item.remarks |> String.contains?("instalment_product_id:")

                if check do
                  instalment_product_id =
                    item.remarks |> String.replace("instalment_product_id:", "")

                  instalment_product =
                    Repo.all(
                      from(p in CommerceFront.Settings.Product,
                        where: p.id == ^instalment_product_id
                      ),
                      preload: [:instalment, :instalment_packages, :instalment_products]
                    )
                    |> List.first()
                    |> Repo.preload(:instalment)

                  instalment = instalment_product |> Map.get(:instalment)

                  for item <- 1..instalment.no_of_months do
                    # todo need to check the main package for delay
                    due_date = Date.utc_today() |> Timex.shift(months: item + instalment.delay)

                    mi_check =
                      Repo.all(
                        from(mi in CommerceFront.Settings.MemberInstalment,
                          where:
                            mi.instalment_id == ^instalment.id and
                              mi.month_no == ^item and
                              mi.user_id == ^user.id and
                              mi.product_id == ^instalment_product.id
                        )
                      )

                    {:ok, member_instalment} =
                      if mi_check == [] do
                        CommerceFront.Settings.create_member_instalment(%{
                          due_date: due_date,
                          instalment_id: instalment.id,
                          is_paid: false,
                          month_no: item,
                          product_id: instalment_product.id,
                          user_id: user.id
                        })
                      else
                        {:ok, List.first(mi_check)}
                      end

                    instalment_products =
                      instalment_product
                      |> Repo.preload([:instalment_products])
                      |> Map.get(:instalment_products)

                    freebie =
                      instalment_products
                      |> Enum.filter(&(&1.month_no == item))
                      |> List.first()

                    if freebie != nil do
                      CommerceFront.Settings.create_member_instalment_product(%{
                        member_instalment_id: member_instalment.id,
                        instalment_product_id: freebie.id
                      })
                    end
                  end
                end

              true ->
                nil
            end
          end
        else
          _ ->
            nil
        end

        {:ok, nil}
      end)
      |> Multi.run(:referral, fn _repo, %{user: user} ->
        if params["upgrade"] != nil do
          {:ok, get_referral_by_username(user.username)}
        else
          parent_r = get_referral_by_username(params["sponsor"])

          create_referral(%{
            parent_user_id: parent_r.user_id,
            parent_referral_id: parent_r.id,
            user_id: user.id
          })
        end
      end)
      |> Multi.run(:placement, fn _repo, %{user: user} ->
        if params["upgrade"] != nil do
          parent_p = get_placement_by_username(params["upgrade"])

          {:ok, %CommerceFront.Settings.Placement{id: parent_p.id}}
        else
          {position, parent_p} =
            determine_position(params["sponsor"], true, params["placement"]["position"])

          create_placement(%{
            parent_user_id: parent_p.user_id,
            parent_placement_id: parent_p.id,
            position: position,
            user_id: user.id
          })
        end
      end)
      |> Multi.run(:pgsd, fn _repo, %{user: user, sale: sale, placement: placement} ->
        cond do
          params["stockist_user_id"] != nil ->
            {:ok, nil}

          params["stockist"] != nil ->
            {:ok, nil}

          true ->
            unless "merchant" in Map.keys(params) do
              contribute_group_sales(user.username, sale.total_point_value, sale, placement)
            else
              {:ok, nil}
            end
        end
      end)
      |> Multi.run(:rgsd, fn _repo,
                             %{
                               sales_person: sales_person,
                               user: user,
                               sale: sale,
                               placement: placement
                             } ->
        cond do
          params["stockist_user_id"] != nil ->
            {:ok, nil}

          params["stockist"] != nil ->
            {:ok, nil}

          true ->
            unless "merchant" in Map.keys(params) do
              contribute_referral_group_sales(
                sales_person.username,
                sale.total_point_value,
                sale
              )
            else
              {:ok, nil}
            end
        end
      end)
      |> Multi.run(:sharing_bonus, fn _repo,
                                      %{pgsd: pgsd, user: user, sale: sale, referral: referral} ->
        if params["stockist"] != nil do
          {:ok, nil}
        else
          if sale.total_point_value > 0 do
            unless "merchant" in Map.keys(params) do
              sharing_bonus(user.username, sale.total_point_value, sale, referral)
            else
              {:ok, nil}
            end
          else
            {:ok, nil}
          end
        end
      end)
      |> Multi.run(:stockist_register_bonus, fn _repo,
                                                %{
                                                  sales_person: sales_person,
                                                  pgsd: pgsd,
                                                  user: user,
                                                  sale: sale,
                                                  referral: referral,
                                                  stockist_user: stockist_user
                                                } ->
        unless "merchant" in Map.keys(params) do
          if sales_person.is_stockist && sale != nil do
            # stockist_register_bonus(sales_person, user.username, sale.total_point_value, sale)

            if sale.total_point_value > 0 do
              stockist_register_bonus(sales_person, user.username, sale.total_point_value, sale)
            else
              if stockist_user != nil do
                # todo

                ra =
                  stockist_register_bonus(
                    stockist_user,
                    user.username,
                    sale.subtotal |> :erlang.trunc(),
                    sale
                  )

                rb =
                  biz_incentive_bonus(
                    sales_person,
                    user.username,
                    sale.subtotal |> :erlang.trunc(),
                    sale
                  )

                rc =
                  CommerceFront.Calculation.matching_biz_incentive_bonus(
                    Date.utc_today().month,
                    Date.utc_today().year
                  )

                IO.inspect([ra, rb, rc])
              else
              end

              {:ok, nil}
            end
          else
            unpaid_user = CommerceFront.Settings.unpaid_user()

            if sale != nil do
              if sale.total_point_value > 0 do
                stockist_register_bonus(unpaid_user, user.username, sale.total_point_value, sale)
              else
                if stockist_user != nil do
                  # todo

                  ra =
                    stockist_register_bonus(
                      stockist_user,
                      user.username,
                      sale.subtotal |> :erlang.trunc(),
                      sale
                    )

                  rb =
                    biz_incentive_bonus(
                      sales_person,
                      user.username,
                      sale.subtotal |> :erlang.trunc(),
                      sale
                    )

                  rc = matching_biz_incentive_bonus(Date.utc_today().month, Date.utc_today().year)

                  IO.inspect([ra, rb, rc])
                else
                end

                {:ok, nil}
              end
            end

            {:ok, nil}
          end
        else
          {:ok, nil}
        end
      end)
      |> Multi.run(:special_share_reward, fn _repo,
                                             %{
                                               pgsd: pgsd,
                                               user: user,
                                               sale: sale,
                                               sales_person: sales_person,
                                               placement: placement,
                                               referral: referral,
                                               stockist_user: stockist_user
                                             } ->
        if params["upgrade"] != nil do
          unless "merchant" in Map.keys(params) do
            special_share_reward(
              referral.parent_user_id,
              sale.total_point_value,
              sale,
              params["scope"]
            )
          end

          {:ok, nil}
        else
          if params["stockist"] != nil || stockist_user != nil do
            {:ok, nil}
          else
            # 22/3 pay to sponsor...
            # 23/5 pay to sales person

            unless "merchant" in Map.keys(params) do
              special_share_reward(
                referral.parent_user_id,
                sale.total_point_value,
                sale,
                params["scope"]
              )
            end

            {:ok, nil}
          end
        end
      end)
      |> Multi.run(:stockist, fn _repo,
                                 %{
                                   user: user,
                                   sale: sale,
                                   placement: placement,
                                   sales_person: sales_person
                                 } ->
        with true <- sale != nil,
             true <- sale.subtotal >= 2000,
             true <- user.is_stockist == false do
          unless "merchant" in Map.keys(params) do
            special_share_reward(
              user.id,
              sale.grand_total - sale.shipping_fee,
              sale,
              params["scope"]
            )

            # jun 17: robert say no more u1, u2 , now give more DT2
            # create_wallet_transaction(%{
            #   user_id: user.id,
            #   amount: 1152.00,
            #   remarks: "Stockist Upgrade - Additional DRP",
            #   wallet_type: "direct_recruitment"
            # })

            # CommerceFront.Settings.convert_to_stockist(user |> Map.put(:placement, placement))
          else
            {:ok, nil}
          end
        else
          _ ->
            nil
        end

        {:ok, nil}
      end)
      |> Multi.run(:share_link, fn _repo,
                                   %{
                                     user: user,
                                     sale: sale,
                                     placement: placement,
                                     sales_person: sales_person
                                   } ->
        if sale != nil do
          {:ok, register_params} = sale.registration_details |> Jason.decode()

          scope = register_params |> Map.get("scope")

          if scope == "link_register" do
            # when the payment got through only then pay the additional20% BP to the share link owner...
            # aka sponsor...

            create_wallet_transaction(%{
              user_id: sale.sales_person_id,
              amount: sale.grand_total * 0.2,
              remarks: "Sales: #{sale.id}| Share link pay back as cash commission",
              wallet_type: "bonus"
            })
          end
        else
          nil
        end

        {:ok, nil}
      end)
      |> Repo.transaction()
      |> IO.inspect()
      |> case do
        {:ok, multi_res} ->
          if params["upgrade"] != nil do
            {:ok, nil}
          else
            unless "merchant" in Map.keys(params) do
              placement_counter_reset(multi_res.placement.id)
            else
              {:ok, nil}
            end
          end

          {:ok, multi_res |> Map.get(:user) |> Map.put(:placement, multi_res.placement)}

        _ ->
          {:error, []}
      end
  end

  def get_user_by_username(username) do
    Repo.get_by(User, username: username)
  end

  def check_uplines(child_username, tree \\ :placement) do
    child_user = get_user_by_username(child_username) |> IO.inspect(label: "get user by username")
    child_user_id = child_user.id

    module =
      if tree == :placement do
        Placement
      else
        Referral
      end

    select_statement = fn query ->
      if tree == :placement do
        query
        |> select([m, pt, m2], %{
          child_id: m.id,
          child: m.username,
          pt_child_id: pt.id,
          pt_parent_id: pt.parent_placement_id,
          parent: m2.username,
          parent_id: m2.id,
          pt_position: pt.position
        })
      else
        query
        |> select([m, pt, m2, r], %{
          child_id: m.id,
          child: m.username,
          pt_child_id: pt.id,
          pt_parent_id: pt.parent_referral_id,
          parent: m2.username,
          parent_id: m2.id,
          rank: r.name
        })
      end
    end

    category_tree_initial_query =
      module
      |> where([sp], sp.user_id == ^child_user_id)

    category_tree_recursion_query =
      module
      |> join(:inner, [sp], pt in "placement_tree", on: sp.user_id == pt.parent_user_id)

    category_tree_query =
      category_tree_initial_query
      |> union_all(^category_tree_recursion_query)

    User
    |> recursive_ctes(true)
    |> with_cte("placement_tree", as: ^category_tree_query)
    |> join(:left, [m], pt in "placement_tree", on: m.id == pt.user_id)
    |> join(:left, [m, pt], m2 in User, on: m2.id == pt.parent_user_id)
    |> join(:left, [m, pt, m2], r in Rank, on: m2.rank_id == r.id)
    |> where([m, pt, m2], m.id <= ^child_user_id)
    |> where([m, pt, m2], not is_nil(m2.id))
    |> select_statement.()
    |> order_by([m, pt, m2], desc: m.id)
    |> Repo.all()
  end

  @doc """


  WITH RECURSIVE "placement_tree" AS
  (SELECT
    p0."id" AS "id",
    p0."parent_user_id" AS "parent_user_id",
    p0."parent_placement_id" AS "parent_placement_id",
    p0."position" AS "position",
    p0."left" AS "left",
    p0."right" AS "right",
    p0."user_id" AS "user_id",
    p0."inserted_at" AS "inserted_at",
    p0."updated_at" AS "updated_at"

    FROM "placements" AS p0 WHERE (p0."parent_user_id" = $1) UNION ALL (


    SELECT p0."id", p0."parent_user_id",
    p0."parent_placement_id", p0."position",
    p0."left", p0."right", p0."user_id",
    p0."inserted_at", p0."updated_at" FROM "placements" AS p0 INNER JOIN "placement_tree" AS p1 ON p0."parent_user_id" = p1."user_id"))


    SELECT ARRAY_AGG( CONCAT(u0."username", '|', u0."id", '|', u0."rank_name", '|', p1."position", '|', p1."left", '|', p1."right", '|', s3."total_left", '|', s3."total_right", '|', s3."balance_left", '|', s3."balance_right", '|', s3."new_left", '|', s3."new_right", '|', s4."sum_left", '|', s4."sum_right") ), u2."fullname", u2."username", u2."id" FROM "users" AS u0

    LEFT OUTER JOIN "placement_tree" AS p1 ON u0."id" = p1."user_id"
    LEFT OUTER JOIN "users" AS u2 ON u2."id" = p1."parent_user_id"
    FULL OUTER JOIN (
      SELECT sg0."id" AS "id", sg0."balance_left" AS "balance_left",
        sg0."balance_right" AS "balance_right", sg0."day" AS "day",
        sg0."month" AS "month", sg0."paired" AS "paired",
        sg0."total_left" AS "total_left", sg0."total_right" AS "total_right",
        sg0."new_left" AS "new_left", sg0."new_right" AS "new_right",
        sg0."user_id" AS "user_id", sg0."year" AS "year",
        sg0."inserted_at" AS "inserted_at", sg0."updated_at" AS "updated_at" FROM "group_sales_summaries" AS sg0 WHERE (((sg0."day" = $2) AND (sg0."month" = $3)) AND (sg0."year" = $4))) AS s3 ON s3."user_id" = p1."user_id"
        FULL OUTER JOIN (SELECT sum(sg0."new_left") AS "sum_left", sum(sg0."new_right") AS "sum_right", sg0."user_id" AS "user_id" FROM "group_sales_summaries" AS sg0 WHERE ((sg0."month" = $5) AND (sg0."year" = $6)) GROUP BY sg0."user_id", sg0."month", sg0."year") AS s4 ON s4."user_id" = p1."user_id" WHERE (u0."id" > $7) AND (NOT (u2."id" IS NULL)) GROUP BY u2."id" [16, 2, 12, 2023, 12, 2023, 16]



      "kathy|587|银级套餐|right|0|20|0|  0|0|0|0|  0|0|350",
      "kathy|587|银级套餐|right|0|20|0|100|0|0|0|100|0|350"

  """
  def check_downlines(parent_username, tree \\ :placement, direction \\ nil) do
    parent_user = get_user_by_username(parent_username)
    parent_user_id = parent_user.id

    seek_direction = fn query, direction ->
      if direction == nil do
        query
        # |> limit([m, pt, m2, gss], 10)
      else
        query
        # |> join(:full, [m, pt, m2, gss], pt2 in Placement, on: pt2.user_id == m2.id)
        |> where([m, pt, m2, gss], pt.position == ^direction)
      end
    end

    module =
      if tree == :placement do
        Placement
      else
        Referral
      end

    select_statement = fn query ->
      if tree == :placement do
        query
        |> select([m, pt, m2, gss, gss2], %{
          children:
            fragment(
              "ARRAY_AGG( CONCAT(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) )",
              m.username,
              "|",
              m.id,
              "|",
              m.rank_name,
              "|",
              pt.position,
              "|",
              pt.left,
              "|",
              pt.right,
              "|",
              gss.total_left,
              "|",
              gss.total_right,
              "|",
              gss.balance_left,
              "|",
              gss.balance_right,
              "|",
              gss.new_left,
              "|",
              gss.new_right,
              "|",
              gss2.sum_left,
              "|",
              gss2.sum_right
            ),
          parent: m2.fullname,
          parent_username: m2.username,
          parent_id: m2.id
        })
      else
        query
        |> select([m, pt, m2, gss, gss2], %{
          children:
            fragment(
              "ARRAY_AGG( CONCAT(?, ?, ?, ?, ?, ?, ?,? , ? , ? ,?) )",
              m.username,
              "|",
              m.id,
              "|",
              m.fullname,
              "|",
              m.rank_name,
              "|",
              gss2.sum_left,
              "|",
              gss2.sum_right
            ),
          parent: m2.fullname,
          parent_username: m2.username,
          parent_id: m2.id,
          rank_name: m2.rank_name
        })
      end
    end

    category_tree_initial_query =
      module
      |> where([sp], sp.parent_user_id == ^parent_user_id)

    category_tree_recursion_query =
      module
      |> join(:inner, [sp], pt in "placement_tree", on: sp.parent_user_id == pt.user_id)

    category_tree_query =
      category_tree_initial_query
      |> union_all(^category_tree_recursion_query)

    User
    |> recursive_ctes(true)
    |> with_cte("placement_tree", as: ^category_tree_query)
    |> join(:left, [m], pt in "placement_tree", on: m.id == pt.user_id)
    |> join(:left, [m, pt], m2 in User, on: m2.id == pt.parent_user_id)
    |> join(:full, [m, pt, m2], gss in subquery(gs_subquery()), on: gss.user_id == pt.user_id)
    |> join(:full, [m, pt, m2, gss], gss2 in subquery(gs_subquery2()),
      on: gss2.user_id == pt.user_id
    )
    |> where([m, pt, m2, gss, gss2], not is_nil(m2.id))
    |> group_by([m, pt, m2, gss, gss2], [m2.id])
    |> select_statement.()
    |> Repo.all()
  end

  def gs_subquery2(tree \\ :placement) do
    if tree == :placement do
      from(gss in GroupSalesSummary,
        where:
          gss.month == ^Date.utc_today().month and
            gss.year == ^Date.utc_today().year,
        select: %{
          sum_left: sum(gss.new_left),
          sum_right: sum(gss.new_right),
          user_id: gss.user_id
        },
        group_by: [gss.user_id, gss.month, gss.year]
      )
    else
      from(gss in CommerceFront.Settings.ReferralGroupSalesSummary,
        where:
          gss.month == ^Date.utc_today().month and
            gss.year == ^Date.utc_today().year,
        select: %{
          sum: sum(gss.amount),
          user_id: gss.user_id
        },
        group_by: [gss.user_id, gss.month, gss.year]
      )
    end
  end

  def gs_subquery(tree \\ :placement) do
    if tree == :placement do
      from(gss in GroupSalesSummary,
        where:
          gss.day == ^Date.utc_today().day and gss.month == ^Date.utc_today().month and
            gss.year == ^Date.utc_today().year
      )
    else
      from(gss in CommerceFront.Settings.ReferralGroupSalesSummary,
        where:
          gss.month == ^Date.utc_today().month and
            gss.year == ^Date.utc_today().year
      )
    end
  end

  def sanitize_carry_forwards(date) do
    data =
      Repo.all(
        from(gss in GroupSalesSummary,
          where:
            gss.day == ^date.day and gss.month == ^date.month and
              gss.year == ^date.year
        )
      )
      |> Enum.group_by(& &1.user_id)

    for user_id <- Map.keys(data) do
      # IO.inspect()
      case data[user_id] do
        [hd, tl, tl2] ->
          Repo.delete(hd)
          Repo.delete(tl)

        _ ->
          nil
      end
    end
  end

  def pay_unpaid_bonus(date, bonus_list) do
    {y, m, d} = date |> Date.to_erl()

    matrix = ["team bonus", "matching bonus", "elite leader"]

    month_rewards =
      Repo.all(
        from(r in Reward,
          where:
            r.month == ^m and
              r.year == ^y,
          select: %{sum: sum(r.amount), bonus: r.name, user_id: r.user_id},
          group_by: [r.user_id, r.name]
        )
      )

    check_this_month_reward = fn user_id, month_rewards ->
      month_rewards
      |> Enum.filter(&(&1.user_id == user_id))
      |> Enum.filter(&(&1.bonus in matrix))
      |> Enum.map(& &1.sum)
      |> Enum.sum()
    end

    for bonus <- bonus_list do
      rewards =
        Repo.all(
          from(r in Reward,
            where:
              r.is_paid == false and
                r.name == ^bonus and r.day == ^d and r.month == ^m and
                r.year == ^y
          )
        )

      pay_to_bonus_wallet = fn reward, multi ->
        multi
        |> Multi.run(String.to_atom("reward_#{reward.id}"), fn _repo, %{} ->
          user = CommerceFront.Settings.get_user!(reward.user_id)
          username = user.username

          user_id =
            if user.stockist_user_id != nil do
              user.stockist_user_id
            else
              user.id
            end

          cond do
            reward.name == "travel fund" ->
              params = %{
                reward_id: reward.id,
                user_id: reward.user_id,
                amount: reward.amount |> Float.round(2),
                remarks: reward.remarks,
                wallet_type: "travel"
              }

              case create_wallet_transaction(params) do
                {:ok, wt} ->
                  update_reward(reward, %{is_paid: true})

                {:error, cg} ->
                  {:error, cg}
              end

            reward.name == "royalty bonus" ->
              params = %{
                reward_id: reward.id,
                user_id: reward.user_id,
                amount: reward.amount |> Float.round(2),
                remarks: reward.remarks,
                wallet_type: "register"
              }

              case create_wallet_transaction(params) do
                {:ok, wt} ->
                  update_reward(reward, %{is_paid: true})

                {:error, cg} ->
                  {:error, cg}
              end

            true ->
              total_this_month = check_this_month_reward.(reward.user_id, month_rewards)

              {amount, remarks} =
                if bonus not in matrix do
                  {reward.amount, "month total: #{total_this_month}|pay: 100%"}
                else
                  if username == "haho_unpaid" do
                    {reward.amount, "month total: #{total_this_month}|pay: 100%"}
                  else
                    if total_this_month > 10000 do
                      {reward.amount, "month total: #{total_this_month}|pay: 100%"}
                    else
                      {reward.amount * 0.9, "month total: #{total_this_month}|pay: 90%"}
                    end
                  end
                end

              params = %{
                reward_id: reward.id,
                user_id: user_id,
                amount: amount |> Float.round(2),
                remarks: reward.remarks <> "|" <> remarks,
                wallet_type: "bonus"
              }

              case create_wallet_transaction(params) do
                {:ok, wt} ->
                  if total_this_month <= 10000 && bonus in matrix && username != "haho_unpaid" do
                    params2 = %{
                      reward_id: reward.id,
                      user_id: user_id,
                      amount: (reward.amount * 0.1) |> Float.round(2),
                      remarks:
                        reward.remarks <> "|" <> "month total: #{total_this_month}|pay: 10%",
                      wallet_type: "product"
                    }

                    create_wallet_transaction(params2)
                  end

                  update_reward(reward, %{is_paid: true})

                {:error, cg} ->
                  {:error, cg}
              end
          end
        end)
      end

      Enum.reduce(rewards, Multi.new(), &pay_to_bonus_wallet.(&1, &2))
      |> Repo.transaction()
      |> IO.inspect()
    end
  end

  def pay_to_bonus_wallet(reward) do
    date = reward.inserted_at
    user = CommerceFront.Settings.get_user!(reward.user_id)
    username = user.username

    user_id =
      if user.stockist_user_id != nil do
        user.stockist_user_id
      else
        user.id
      end

    {y, m, d} = date |> Date.to_erl()

    matrix = ["team bonus", "matching bonus", "elite leader"]

    month_rewards =
      Repo.all(
        from(r in Reward,
          where:
            r.month == ^m and
              r.year == ^y,
          select: %{sum: sum(r.amount), bonus: r.name, user_id: r.user_id},
          group_by: [r.user_id, r.name]
        )
      )

    check_this_month_reward = fn user_id, month_rewards ->
      month_rewards
      |> Enum.filter(&(&1.user_id == user_id))
      |> Enum.filter(&(&1.bonus in matrix))
      |> Enum.map(& &1.sum)
      |> Enum.sum()
    end

    total_this_month = check_this_month_reward.(reward.user_id, month_rewards)

    {amount, remarks} =
      if reward.name not in matrix do
        {reward.amount, "month total: #{total_this_month}|pay: 100%"}
      else
        if username == "haho_unpaid" do
          {reward.amount, "month total: #{total_this_month}|pay: 100%"}
        else
          if total_this_month > 10000 do
            {reward.amount, "month total: #{total_this_month}|pay: 100%"}
          else
            {reward.amount * 0.9, "month total: #{total_this_month}|pay: 90%"}
          end
        end
      end

    params = %{
      reward_id: reward.id,
      user_id: user_id,
      amount: amount |> Float.round(2),
      remarks: reward.remarks <> "|" <> remarks,
      wallet_type: "bonus"
    }

    case create_wallet_transaction(params) do
      {:ok, wt} ->
        if total_this_month <= 10000 && reward.name in matrix && username != "haho_unpaid" do
          params2 = %{
            reward_id: reward.id,
            user_id: user_id,
            amount: (reward.amount * 0.1) |> Float.round(2),
            remarks: reward.remarks <> "|" <> "month total: #{total_this_month}|pay: 10%",
            wallet_type: "product"
          }

          create_wallet_transaction(params2)
        end

        update_reward(reward, %{is_paid: true})

      {:error, cg} ->
        {:error, cg}
    end
  end

  def reset do
    Repo.delete_all(Reward)
    Repo.delete_all(WalletTransaction)

    Repo.delete_all(Ewallet)
    Repo.delete_all(User)
    Repo.delete_all(Placement)
    Repo.delete_all(Referral)

    Repo.delete_all(Sale)
    Repo.delete_all(PlacementGroupSalesDetail)
  end

  def rollback do
    Repo.all(from(u in User, order_by: [desc: u.id])) |> List.first() |> Repo.delete()
    Repo.all(from(u in Placement, order_by: [desc: u.id])) |> List.first() |> Repo.delete()
    Repo.all(from(u in Referral, order_by: [desc: u.id])) |> List.first() |> Repo.delete()
    Repo.all(from(u in Sale, order_by: [desc: u.id])) |> List.first() |> Repo.delete()

    Repo.all(from(u in PlacementGroupSalesDetail, order_by: [desc: u.id]))
    |> List.first()
    |> Repo.delete()
  end

  def user_monthly_reward_summary_by_years2(user_id, is_prev \\ false) do
    sanitize_float = fn map ->
      sum = map |> Map.get(:sum)
      map |> Map.put(:sum, sum |> Float.round(2))
    end

    query2 =
      Reward
      |> join(:left, [r], u in User, on: u.id == r.user_id)
      |> select([r, u], %{year: r.year, fullname: u.fullname, sum: sum(r.amount)})
      |> group_by([r, u], [u.fullname, r.year])
      |> order_by([r, u], desc: r.year, desc: u.fullname)
      |> Repo.all()
      |> Enum.map(&(&1 |> sanitize_float.()))
  end

  # CommerceFront.Settings.user_monthly_reward_summary_by_years(516)
  def user_monthly_reward_summary_by_years(user_id, query_year \\ nil) do
    user = get_user!(user_id)

    years = 2021..Date.utc_today().year

    years =
      if query_year != nil do
        [String.to_integer(query_year)]
      else
        years
      end

    query =
      Reward
      |> join(:left, [r], u in User, on: u.id == r.user_id)
      |> where([r, u], u.fullname == ^user.fullname)
      |> select([r, u], %{year: r.year, month: r.month, fullname: u.fullname, sum: sum(r.amount)})
      |> group_by([r, u], [u.fullname, r.year, r.month])
      |> order_by([r, u], desc: r.year, desc: u.fullname)
      |> Repo.all()
      |> Enum.group_by(& &1.year)

    query =
      for year <- years do
        for month <- 1..12 do
          if query[year] != nil do
            res =
              query[year]
              |> Enum.filter(&(&1.month == month))
              |> List.first()

            if res != nil do
              res
              |> Map.take([:month, :sum])
            else
              %{month: month, sum: 0.0}
            end
          else
            %{month: month, sum: 0.0}
          end
        end
      end

    query2 =
      Reward
      |> join(:left, [r], u in User, on: u.id == r.user_id)
      |> where([r, u], u.fullname == ^user.fullname)
      |> select([r, u], %{year: r.year, fullname: u.fullname, sum: sum(r.amount)})
      |> group_by([r, u], [u.fullname, r.year])
      |> order_by([r, u], desc: r.year, desc: u.fullname)
      |> Repo.all()
      |> Enum.group_by(& &1.year)

    %{months: query, years: query2, user: user |> BluePotion.sanitize_struct()}
  end

  def user_monthly_reward_summary(user_id, is_prev \\ false) do
    date =
      if is_prev == "true" do
        Date.utc_today() |> Timex.shift(months: -1)
      else
        Date.utc_today()
      end

    {y, m, d} = date |> Date.to_erl()

    user = CommerceFront.Settings.get_user!(user_id) |> Repo.preload(:stockist_users)

    stockist_users =
      if user.stockist_users != nil do
        user |> Map.get(:stockist_users) |> Enum.map(& &1.id)
      else
        []
      end
      |> List.insert_at(0, user.id)

    Repo.all(
      from(r in Reward,
        where: r.user_id in ^stockist_users,
        where: r.month == ^m and r.year == ^y,
        group_by: [r.name, r.month, r.year],
        select: %{period: [r.month, r.year], name: r.name, sum: sum(r.amount)}
      )
    )
  end

  def approve_topup(params) do
    topup = get_wallet_topup!(params["id"])

    if topup.is_approved == false do
      Multi.new()
      |> Multi.run(:topup, fn _repo, %{} ->
        update_wallet_topup(topup, %{"is_approved" => true})
      end)
      |> Multi.run(:wallet_transaction, fn _repo, %{topup: topup} ->
        create_wallet_transaction(%{
          user_id: topup.user_id,
          amount: topup.amount,
          remarks: "Topup: #{topup.id}",
          wallet_type: "register"
        })
      end)
      |> Repo.transaction()
      |> IO.inspect()
      |> case do
        {:ok, multi_res} ->
          # {:ok, multi_res |> Map.get(:ewallet)}
          {:ok, multi_res}

        _ ->
          {:error, []}
      end
    else
      {:error, "already approved"}
    end
  end

  def rename_ranks() do
    users = Repo.all(from(u in User, preload: [:rank]))

    for user <- users do
      update_user(user, %{rank_name: user.rank.name})
    end
  end

  def convert_to_stockist(user) do
    CommerceFront.Settings.User.changeset(user, %{is_stockist: true}) |> Repo.update()
    # create the other 2 nodes first..
    # then append them under the current account?
    Multi.new()
    |> Multi.run(:u2u3, fn _repo, %{} ->
      unit_2 =
        register(
          %{
            "sales_person_id" => user.id,
            "stockist_user_id" => user.id,
            "rank_id" => user.rank_id,
            "sponsor" => user.username,
            "stockist" => true,
            "email" => user.email,
            "username" => user.username <> "-U2",
            "fullname" => user.fullname,
            "phone" => user.phone
          },
          %CommerceFront.Settings.Sale{}
        )

      unit_3 =
        register(
          %{
            "sales_person_id" => user.id,
            "stockist_user_id" => user.id,
            "rank_id" => user.rank_id,
            "sponsor" => user.username,
            "stockist" => true,
            "email" => user.email,
            "username" => user.username <> "-U3",
            "fullname" => user.fullname,
            "phone" => user.phone
          },
          %CommerceFront.Settings.Sale{}
        )

      updated_parent = user |> Repo.preload(stockist_users: [placement: [:parent]])

      [%{placement: u2_placement} = u2, %{placement: u3_placement} = u3] =
        updated_parent.stockist_users

      res =
        Repo.all(
          from(p in Placement, where: p.parent_placement_id == ^updated_parent.placement.id)
        )

      case res do
        [%{position: "right"} = current_right, %{position: "left"} = current_left] ->
          if u2_placement.id != current_left.id do
            update_placement(u2_placement, %{
              position: "left",
              parent_placement_id: updated_parent.placement.id,
              parent_user_id: updated_parent.id
            })

            update_placement(current_left, %{
              parent_placement_id: u2_placement.id,
              parent_user_id: u2_placement.user_id
            })
          end

          if u3_placement.id != current_right.id do
            update_placement(u3_placement, %{
              position: "right",
              parent_placement_id: updated_parent.placement.id,
              parent_user_id: updated_parent.id
            })

            update_placement(current_right, %{
              parent_placement_id: u3_placement.id,
              parent_user_id: u3_placement.user_id
            })
          end

        [%{position: "left"} = current_left, %{position: "right"} = current_right] ->
          if u2_placement.id != current_left.id do
            update_placement(u2_placement, %{
              position: "left",
              parent_placement_id: updated_parent.placement.id,
              parent_user_id: updated_parent.id
            })

            update_placement(current_left, %{
              parent_placement_id: u2_placement.id,
              parent_user_id: u2_placement.user_id
            })
          end

          if u3_placement.id != current_right.id do
            update_placement(u3_placement, %{
              position: "right",
              parent_placement_id: updated_parent.placement.id,
              parent_user_id: updated_parent.id
            })

            update_placement(current_right, %{
              parent_placement_id: u3_placement.id,
              parent_user_id: u3_placement.user_id
            })
          end

        [%{position: "left"} = current_left] ->
          update_placement(u2_placement, %{
            position: "left",
            parent_placement_id: updated_parent.placement.id,
            parent_user_id: updated_parent.id
          })

          update_placement(current_left, %{
            parent_placement_id: u2_placement.id,
            parent_user_id: u2_placement.user_id
          })

        [%{position: "right"} = current_right] ->
          update_placement(u3_placement, %{
            position: "right",
            parent_placement_id: updated_parent.placement.id,
            parent_user_id: updated_parent.id
          })

          update_placement(current_right, %{
            parent_placement_id: u3_placement.id,
            parent_user_id: u3_placement.user_id
          })

        _ ->
          nil
      end

      # placement_counter_reset()

      Elixir.Task.start_link(CommerceFront.Settings, :placement_counter_reset, [])
      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  def highest_rank() do
    Repo.all(from(r in Rank, order_by: [desc: r.retail_price])) |> List.first()
  end

  def lowest_rank() do
    Repo.all(from(r in Rank, order_by: [desc: r.retail_price])) |> List.last()
  end

  def unpaid_user() do
    res = get_user_by_username("haho_unpaid")
    # highest_rank =
    if res == nil do
      {:ok, user} =
        create_user(%{
          "email" => "unpaid@1.com",
          "username" => "haho_unpaid",
          "fullname" => "haho_unpaid",
          "phone" => "0122664254",
          "password" => "abc333",
          "rank_id" => CommerceFront.Settings.highest_rank().id
        })

      user
    else
      res
    end
  end

  def finance_user() do
    res = get_user_by_username("haho_finance")

    if res == nil do
      {:ok, user} =
        create_user(%{
          "email" => "finance@1.com",
          "username" => "haho_finance",
          "fullname" => "haho_finance",
          "phone" => "0122664254",
          "password" => "abc222"
        })

      user
    else
      res
    end
  end

  def transfer_wallet(user_id, username, amount, remarks \\ "") do
    wallet =
      list_ewallets_by_user_id(user_id)
      |> Enum.filter(&(&1.wallet_type == :register))
      |> List.first()

    user = CommerceFront.Settings.get_user!(user_id)
    receiver = CommerceFront.Settings.get_user_by_username(username)

    if receiver == nil do
      %{status: "error", reason: "User not found"}
    else
      if wallet.total >= amount do
        CommerceFront.Settings.create_wallet_transaction(%{
          user_id: user_id,
          amount: amount * -1,
          remarks: "Transfer to #{username} - #{remarks}",
          wallet_type: "register"
        })

        CommerceFront.Settings.create_wallet_transaction(%{
          user_id: receiver.id,
          amount: amount,
          remarks: "Transfer received from #{user.username} - #{remarks}",
          wallet_type: "register"
        })

        %{status: "ok", res: "ok"}
      else
        %{status: "error", reason: "insufficient wallet balance"}
      end
    end
  end

  def convert_wallet(user_id, amount) do
    wallet =
      list_ewallets_by_user_id(user_id)
      |> Enum.filter(&(&1.wallet_type == :bonus))
      |> List.first()

    if wallet.total >= amount do
      CommerceFront.Settings.create_wallet_transaction(%{
        user_id: user_id,
        amount: amount * -1,
        remarks: "Convert",
        wallet_type: "bonus"
      })

      CommerceFront.Settings.create_wallet_transaction(%{
        user_id: user_id,
        amount: amount,
        remarks: "Convert",
        wallet_type: "register"
      })

      %{status: "ok", res: "ok"}
    else
      %{status: "error", reason: "insufficient wallet balance"}
    end
  end

  def check_staff_password(params) do
    users =
      Repo.all(
        from(u in Staff, where: u.username == ^params["username"], preload: [role: :app_routes])
      )
      |> IO.inspect()

    if users != [] do
      user = List.first(users)

      crypted_password =
        :crypto.hash(:sha512, params["password"] |> IO.inspect())
        |> Base.encode16()
        |> String.downcase()
        |> IO.inspect()

      {crypted_password == user.crypted_password, user} |> IO.inspect()
    else
      {false, nil}
    end
  end

  def get_admin_staff() do
    check = Repo.all(from(r in Role, where: r.name == "Owner")) |> IO.inspect()

    if check == [] do
      {:ok, role} = create_role(%{name: "Owner", desc: "own and manage the company "})
      role
    else
      List.first(check)
    end
  end

  def menu_list() do
    %{
      "0" => %{
        "children" => %{
          "0" => %{
            "icon" => "camera-foto-solid",
            "path" => "/admin/staff",
            "title" => "Staff"
          },
          "1" => %{
            "icon" => "camera-foto-solid",
            "path" => "/admin/role",
            "title" => "Role"
          },
          "2" => %{
            "icon" => "camera-foto-solid",
            "path" => "/admin/app_route",
            "title" => "Route"
          },
          "3" => %{
            "icon" => "camera-foto-solid",
            "path" => "/merchants/categories",
            "title" => "Merchant Business Categories"
          }
        },
        "icon" => "",
        "path" => "#",
        "title" => "Admin"
      },
      "1" => %{
        "children" => %{
          "0" => %{
            "icon" => "camera-foto-solid",
            "path" => "/geo/countries",
            "title" => "Country"
          },
          "1" => %{
            "icon" => "camera-foto-solid",
            "path" => "/geo/states",
            "title" => "States"
          },
          "2" => %{
            "icon" => "camera-foto-solid",
            "path" => "/geo/pick_up_points",
            "title" => "Pick Up Points"
          }
        },
        "icon" => "",
        "path" => "#",
        "title" => "Geo"
      },
      "10" => %{
        "children" => %{
          "0" => %{"icon" => "book-solid", "path" => "/users", "title" => "Users"},
          "1" => %{
            "icon" => "book-solid",
            "path" => "/users/placements",
            "title" => "Placements"
          }
        },
        "icon" => "",
        "path" => "#",
        "title" => "Users"
      },
      "11" => %{"icon" => "book-solid", "path" => "/ranks", "title" => "Rank"},
      "12" => %{
        "children" => %{
          "0" => %{
            "icon" => "camera-foto-solid",
            "path" => "/ewallets/withdrawal_batches",
            "title" => "Withdrawal"
          },
          "1" => %{
            "icon" => "camera-foto-solid",
            "path" => "/ewallets/merchant_withdrawals",
            "title" => "Merchant Withdrawal"
          },
          "2" => %{
            "icon" => "book-solid",
            "path" => "/ewallets",
            "title" => "Ewallets"
          },
          "3" => %{
            "icon" => "camera-foto-solid",
            "path" => "/ewallets/transfers",
            "title" => "Transfers"
          },
          "4" => %{
            "icon" => "camera-foto-solid",
            "path" => "/ewallets/register_points",
            "title" => "Register Points"
          }
        },
        "icon" => "",
        "path" => "#",
        "title" => "Ewallets"
      },
      "2" => %{
        "icon" => "book-solid",
        "path" => "/announcements",
        "title" => "Announcements"
      },
      "3" => %{"icon" => "book-solid", "path" => "/slides", "title" => "Slides"},
      "4" => %{
        "children" => %{
          "0" => %{
            "icon" => "camera-foto-solid",
            "path" => "/rewards/summary",
            "title" => "Commission Summary"
          },
          "1" => %{
            "icon" => "camera-foto-solid",
            "path" => "/rewards/details",
            "title" => "Commission Details"
          },
          "2" => %{
            "icon" => "camera-foto-solid",
            "path" => "/rewards",
            "title" => "All Commission"
          },
          "3" => %{
            "icon" => "camera-foto-solid",
            "path" => "/rewards/royalty_users",
            "title" => "Royalty Users"
          }
        },
        "icon" => "",
        "path" => "#",
        "title" => "Commission"
      },
      "5" => %{
        "children" => %{
          "0" => %{
            "icon" => "book-solid",
            "path" => "/referral_gs_summary",
            "title" => "Referral GS Summary"
          },
          "1" => %{
            "icon" => "book-solid",
            "path" => "/referral_gs_details",
            "title" => "Referral GS Details"
          },
          "2" => %{
            "icon" => "book-solid",
            "path" => "/gs_summary",
            "title" => "Placement GS Summary"
          },
          "3" => %{
            "icon" => "book-solid",
            "path" => "/group_sales_details",
            "title" => "Placement GS Details"
          }
        },
        "icon" => "",
        "path" => "#",
        "title" => "GroupSales"
      },
      "6" => %{
        "icon" => "book-solid",
        "path" => "/deliveries",
        "title" => "Deliveries"
      },
      "7" => %{
        "icon" => "book-solid",
        "path" => "/merchants",
        "title" => "Merchants"
      },
      "8" => %{"icon" => "book-solid", "path" => "/sales", "title" => "Sales"},
      "9" => %{
        "children" => %{
          "0" => %{
            "icon" => "book-solid",
            "path" => "/products",
            "title" => "Product"
          },
          "1" => %{"icon" => "book-solid", "path" => "/stocks", "title" => "Stocks"},
          "2" => %{
            "icon" => "book-solid",
            "path" => "/stock_adjustments",
            "title" => "Stock Adjustments"
          },
          "3" => %{
            "icon" => "book-solid",
            "path" => "/stocks/summaries",
            "title" => "Stocks Summaries"
          }
        },
        "icon" => "",
        "path" => "#",
        "title" => "Stocks"
      }
    }
  end

  def update_admin_menus(list) do
    IO.inspect(list)
    # how to retain existing role app route?

    rars = Repo.all(from(r in Role, preload: [:app_routes]))

    Multi.new()
    |> Multi.run(:update, fn _repo, %{} ->
      Repo.delete_all(AppRoute)
      Repo.delete_all(RoleAppRoute)

      for role <- rars do
        list = list |> Map.values()

        for menu <- list do
          {:ok, route} =
            create_app_route(%{
              "name" => menu |> Map.get("title"),
              "route" => menu |> Map.get("path"),
              "icon" => menu |> Map.get("icon")
            })

          admin_role = get_admin_staff()

          cg =
            RoleAppRoute.changeset(%RoleAppRoute{}, %{
              role_id: role.id,
              app_route_id: route.id
            })

          if role.name == admin_role.name do
            cg
            |> Repo.insert()
          else
            if role.app_routes
               |> Enum.filter(&(&1.route == route.route))
               |> Enum.filter(&(&1.name == route.name)) != [] do
              cg
              |> Repo.insert()
            end
          end

          children = Map.get(menu, "children", %{}) |> Map.values()

          for child <- children do
            {:ok, croute} =
              create_app_route(%{
                "name" => child |> Map.get("title"),
                "route" => child |> Map.get("path"),
                "icon" => child |> Map.get("icon")
              })

            ccg =
              RoleAppRoute.changeset(%RoleAppRoute{}, %{
                role_id: role.id,
                app_route_id: croute.id
              })

            if role.name == admin_role.name do
              ccg
              |> Repo.insert()
            else
              if role.app_routes
                 |> Enum.filter(&(&1.route == croute.route))
                 |> Enum.filter(&(&1.name == croute.name)) != [] do
                ccg
                |> Repo.insert()
              end
            end
          end
        end
      end

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  def update_svt_menus() do
    menu_list() |> update_admin_menus()
  end

  def populate_menus(menus) do
    rars = Repo.all(from(r in Role, preload: [:app_routes]))

    Multi.new()
    |> Multi.run(:update, fn _repo, %{} ->
      Repo.delete_all(AppRoute)
      Repo.delete_all(RoleAppRoute)

      for role <- rars do
        for menu <- menus do
          {:ok, route} =
            create_app_route(%{
              "name" => menu |> Map.get("title"),
              "route" => menu |> Map.get("path"),
              "icon" => menu |> Map.get("icon")
            })

          admin_role = get_admin_staff()

          cg =
            RoleAppRoute.changeset(%RoleAppRoute{}, %{
              role_id: role.id,
              app_route_id: route.id
            })

          if role.name == admin_role.name do
            cg
            |> Repo.insert()
          else
            if role.app_routes
               |> Enum.filter(&(&1.route == route.route))
               |> Enum.filter(&(&1.name == route.name)) != [] do
              cg
              |> Repo.insert()
            end
          end

          children = Map.get(menu, "children", %{})

          for child <- children do
            {:ok, croute} =
              create_app_route(%{
                "name" => child |> Map.get("title"),
                "route" => child |> Map.get("path"),
                "icon" => child |> Map.get("icon")
              })

            ccg =
              RoleAppRoute.changeset(%RoleAppRoute{}, %{
                role_id: role.id,
                app_route_id: croute.id
              })

            if role.name == admin_role.name do
              ccg
              |> Repo.insert()
            else
              if role.app_routes
                 |> Enum.filter(&(&1.route == croute.route))
                 |> Enum.filter(&(&1.name == croute.name)) != [] do
                ccg
                |> Repo.insert()
              end
            end
          end
        end
      end

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  def group_unpay_rewards() do
    query =
      Reward
      |> where([r], r.is_paid == ^false)
      |> group_by([r], [r.name, r.day, r.month, r.year])
      |> select([r], %{
        sum: sum(r.amount),
        name: r.name,
        day: r.day,
        month: r.month,
        year: r.year
      })
      |> order_by([r], [r.year, r.month, r.day])

    sanitize_float = fn map ->
      sum = map |> Map.get(:sum)
      map |> Map.put(:sum, sum |> Float.round(2))
    end

    Repo.all(query)
    |> Enum.map(&(&1 |> sanitize_float.()))
  end

  def monthly_outlet_trx_only_rp(month \\ 7, year \\ 2024) do
    naive_date = Date.from_erl!({year, month, 1})
    end_naive_date = naive_date |> Timex.shift(months: 1)

    query3 = """
    WITH drp_data AS (
    SELECT
        l.id,
        COALESCE(
            NULLIF(
                regexp_replace(
                    convert_from(p.webhook_details, 'UTF8'),
                    '^.*drp paid:\\s*([0-9.]+)\\s*.*$',
                    '\\1'
                ),
                ''
            )::float,
            0
        ) AS drp_paid,
        p.webhook_details
    FROM
        sales l
    LEFT JOIN
        payments p
    ON
        p.sales_id = l.id
    WHERE
        convert_from(p.webhook_details, 'UTF8') ILIKE '%drp%'
    )
    select
      to_char( l.inserted_at , 'YYYY') as year,
      sum(l.subtotal) - sum(dp.drp_paid) as "only_rp",
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '01') - sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '01') AS jan,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '02') - sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '02') AS feb,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '03') - sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '03') AS mar,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '04') - sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '04') AS apr,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '05') - sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '05') AS may,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '06') - sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '06') AS jun,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '07') - sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '07') AS jul,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '08') - sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '08') AS aug,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '09') - sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '09') AS sep,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '10') - sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '10') AS oct,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '11') - sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '11') AS nov,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '12') - sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '12') AS dec
    from
      sales l
      left join payments p on p.sales_id = l.id
      full join drp_data dp on dp.id = l.id
      group by  to_char( l.inserted_at , 'YYYY') order by to_char( l.inserted_at , 'YYYY') desc ;


    """

    params = []
    type = ""

    query =
      case type do
        _ ->
          query3
      end

    {:ok, %Postgrex.Result{columns: columns, rows: rows} = res} = Repo.query(query, params)

    for row <- rows do
      Enum.zip(columns |> Enum.map(&(&1 |> String.to_atom())), row) |> Enum.into(%{})
    end
  end

  def monthly_outlet_trx(month \\ 7, year \\ 2024) do
    naive_date = Date.from_erl!({year, month, 1})
    end_naive_date = naive_date |> Timex.shift(months: 1)

    query3 = """
    WITH drp_data AS (
    SELECT
        l.id,
        COALESCE(
            NULLIF(
                regexp_replace(
                    convert_from(p.webhook_details, 'UTF8'),
                    '^.*drp paid:\\s*([0-9.]+)\\s*.*$',
                    '\\1'
                ),
                ''
            )::float,
            0
        ) AS drp_paid,
        p.webhook_details
    FROM
        sales l
    LEFT JOIN
        payments p
    ON
        p.sales_id = l.id
    WHERE
        convert_from(p.webhook_details, 'UTF8') ILIKE '%drp%'
    )
    select
      to_char( l.inserted_at , 'YYYY') as year,
      sum(l.subtotal),
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '01') AS jan,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '02') AS feb,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '03') AS mar,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '04') AS apr,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '05') AS may,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '06') AS jun,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '07') AS jul,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '08') AS aug,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '09') AS sep,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '10') AS oct,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '11') AS nov,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '12') AS dec
    from
      sales l
      left join payments p on p.sales_id = l.id
      full join drp_data dp on dp.id = l.id
      group by  to_char( l.inserted_at , 'YYYY') order by to_char( l.inserted_at , 'YYYY') desc ;


    """

    params = []
    type = ""

    query =
      case type do
        _ ->
          query3
      end

    {:ok, %Postgrex.Result{columns: columns, rows: rows} = res} = Repo.query(query, params)

    for row <- rows do
      Enum.zip(columns |> Enum.map(&(&1 |> String.to_atom())), row) |> Enum.into(%{})
    end
  end

  def monthly_outlet_trx_drp(month \\ 7, year \\ 2024) do
    naive_date = Date.from_erl!({year, month, 1})
    end_naive_date = naive_date |> Timex.shift(months: 1)

    query3 = """
    WITH drp_data AS (
    SELECT
        l.id,
        COALESCE(
            NULLIF(
                regexp_replace(
                    convert_from(p.webhook_details, 'UTF8'),
                    '^.*drp paid:\\s*([0-9.]+)\\s*.*$',
                    '\\1'
                ),
                ''
            )::float,
            0
        ) AS drp_paid,
        p.webhook_details
    FROM
        sales l
    LEFT JOIN
        payments p
    ON
        p.sales_id = l.id
    WHERE
        convert_from(p.webhook_details, 'UTF8') ILIKE '%drp%'
    )
    select
      to_char( l.inserted_at , 'YYYY') as year,
      sum(dp.drp_paid),
      sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '01') AS jan,
      sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '02') AS feb,
      sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '03') AS mar,
      sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '04') AS apr,
      sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '05') AS may,
      sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '06') AS jun,
      sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '07') AS jul,
      sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '08') AS aug,
      sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '09') AS sep,
      sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '10') AS oct,
      sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '11') AS nov,
      sum(dp.drp_paid) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '12') AS dec
    from
      sales l
      left join payments p on p.sales_id = l.id
      full join drp_data dp on dp.id = l.id
      group by  to_char( l.inserted_at , 'YYYY') order by to_char( l.inserted_at , 'YYYY') desc ;


    """

    params = []
    type = ""

    query =
      case type do
        _ ->
          query3
      end

    {:ok, %Postgrex.Result{columns: columns, rows: rows} = res} = Repo.query(query, params)

    for row <- rows do
      Enum.zip(columns |> Enum.map(&(&1 |> String.to_atom())), row) |> Enum.into(%{})
    end
  end

  def yearly_sales_performance(type \\ "MY") do
    query3 = """
    select
      to_char( l.inserted_at , 'YYYY') as year,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '01') AS jan,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '02') AS feb,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '03') AS mar,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '04') AS apr,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '05') AS may,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '06') AS jun,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '07') AS jul,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '08') AS aug,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '09') AS sep,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '10') AS oct,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '11') AS nov,
      sum(l.subtotal) FILTER(WHERE to_char( l.inserted_at , 'YYYY') = to_char( l.inserted_at , 'YYYY') and to_char( l.inserted_at , 'MM') = '12') AS dec
    from
      sales l
      group by to_char( l.inserted_at , 'YYYY') order by to_char( l.inserted_at , 'YYYY') desc ;
    """

    params = []

    query =
      case type do
        _ ->
          query3
      end

    {:ok, %Postgrex.Result{columns: columns, rows: rows} = res} = Repo.query(query, params)

    for row <- rows do
      Enum.zip(columns |> Enum.map(&(&1 |> String.to_atom())), row) |> Enum.into(%{})
    end
  end

  def verify_parent(parent_id, user) do
    parent_referral_id =
      Repo.all(from(r in Referral, where: r.user_id == ^user.id, select: r.parent_user_id))
      |> List.first()
      |> IO.inspect()

    parent_referral_id == parent_id
  end

  def accumulated_sales_by_user(%User{} = user, show_rank) do
    {y, m, d} = Date.utc_today() |> Date.to_erl()
    edate = NaiveDateTime.from_erl!({{y, m, d}, {0, 0, 0}})
    sdate = edate |> Timex.shift(months: -6)

    user = user |> Repo.preload(:rank)

    sdate = user.inserted_at |> Timex.shift(minutes: -10)
    edate = sdate |> Timex.shift(months: 6)

    if user != nil do
      res =
        if Date.compare(edate, Date.utc_today()) == :lt do
          IO.inspect(sdate, label: "sdate lt")
          IO.inspect(edate, label: "edate lt")

          Repo.all(
            from(s in Sale,
              left_join: u in User,
              on: s.sales_person_id == u.id,
              where: u.username == ^user.username or s.user_id == ^user.id,
              where: is_nil(s.merchant_id),
              where: s.status not in ^[:pending_payment, :cancelled, :refund],
              where: s.inserted_at > ^sdate,
              group_by: [s.user_id],
              select: sum(s.subtotal)
            )
          )
          |> List.first()
        else
          IO.inspect(sdate, label: "sdate")
          IO.inspect(edate, label: "edate")

          Repo.all(
            from(s in Sale,
              left_join: u in User,
              on: s.user_id == u.id,
              where: u.username == ^user.username or s.user_id == ^user.id,
              where: is_nil(s.merchant_id),
              where: s.status not in ^[:pending_payment, :cancelled, :refund],
              where: s.inserted_at > ^sdate and s.inserted_at < ^edate,
              group_by: [s.user_id],
              select: sum(s.subtotal)
            )
          )
          |> IO.inspect(label: "res")
          |> List.first()
        end

      res =
        if res == nil do
          0
        else
          res
        end

      if show_rank do
        [res, user.rank.name]
      else
        res
      end
    else
      if show_rank do
        [0, "n/a"]
      else
        0
      end
    end
  end

  def accumulated_sales_by_user_merchant(%User{} = user, show_rank) do
    {y, m, d} = Date.utc_today() |> Date.to_erl()
    edate = NaiveDateTime.from_erl!({{y, m, d}, {0, 0, 0}})
    sdate = edate |> Timex.shift(months: -6)

    user = user |> Repo.preload(:rank)

    sdate = user.inserted_at
    edate = sdate |> Timex.shift(months: 6)

    if user != nil do
      res =
        if Date.compare(edate, Date.utc_today()) == :lt do
          Repo.all(
            from(s in Sale,
              left_join: u in User,
              on: s.sales_person_id == u.id,
              where: u.username == ^user.username or s.user_id == ^user.id,
              where: not is_nil(s.merchant_id),
              where: s.status not in ^[:pending_payment, :cancelled, :refund],
              where: s.inserted_at >= ^sdate,
              group_by: [s.sales_person_id],
              select: sum(s.subtotal)
            )
          )
          |> List.first()
        else
          Repo.all(
            from(s in Sale,
              left_join: u in User,
              on: s.sales_person_id == u.id,
              where: u.username == ^user.username or s.user_id == ^user.id,
              where: not is_nil(s.merchant_id),
              where: s.status not in ^[:pending_payment, :cancelled, :refund],
              where: s.inserted_at >= ^sdate and s.inserted_at < ^edate,
              group_by: [s.sales_person_id],
              select: sum(s.subtotal)
            )
          )
          |> List.first()
        end
        |> IO.inspect()

      res =
        if res == nil do
          0
        else
          res
        end

      if show_rank do
        [res, user.rank.name]
      else
        res
      end
    else
      if show_rank do
        [0, "n/a"]
      else
        0
      end
    end
  end

  def accumulated_sales_merchant(username, show_rank \\ nil) do
    {y, m, d} = Date.utc_today() |> Date.to_erl()
    edate = NaiveDateTime.from_erl!({{y, m, d}, {0, 0, 0}})
    sdate = edate |> Timex.shift(months: -6)

    user = get_user_by_username(username) |> Repo.preload(:rank)

    sdate = user.inserted_at
    edate = sdate |> Timex.shift(months: 6)

    if user != nil do
      res =
        if Date.compare(edate, Date.utc_today()) == :lt do
          Repo.all(
            from(s in Sale,
              left_join: u in User,
              on: s.sales_person_id == u.id,
              where: u.username == ^username or s.user_id == ^user.id,
              where: not is_nil(s.merchant_id),
              where: s.status not in ^[:pending_payment, :cancelled, :refund],
              where: s.inserted_at >= ^sdate and s.inserted_at < ^edate,
              group_by: [s.sales_person_id],
              select: sum(s.subtotal)
            )
          )
          |> List.first()
        else
          Repo.all(
            from(s in Sale,
              left_join: u in User,
              on: s.sales_person_id == u.id,
              where: u.username == ^username or s.user_id == ^user.id,
              where: s.status not in ^[:pending_payment, :cancelled, :refund],
              where: s.inserted_at >= ^sdate and s.inserted_at < ^edate,
              where: not is_nil(s.merchant_id),
              group_by: [s.sales_person_id],
              select: sum(s.subtotal)
            )
          )
          |> List.first()
        end

      if show_rank do
        [res, user.rank.name]
      else
        res
      end
    else
      if show_rank do
        [0, "n/a"]
      else
        0
      end
    end
  end

  def accumulated_sales(username, show_rank \\ nil) do
    {y, m, d} = Date.utc_today() |> Date.to_erl()
    edate = NaiveDateTime.from_erl!({{y, m, d}, {0, 0, 0}})
    sdate = edate |> Timex.shift(months: -6)

    user = get_user_by_username(username) |> Repo.preload(:rank)

    sdate = user.inserted_at
    edate = sdate |> Timex.shift(months: 6)

    if user != nil do
      res =
        if Date.compare(edate, Date.utc_today()) == :lt do
          Repo.all(
            from(s in Sale,
              left_join: u in User,
              on: s.sales_person_id == u.id,
              where: u.username == ^username or s.user_id == ^user.id,
              where: is_nil(s.merchant_id),
              where: s.status not in ^[:pending_payment, :cancelled, :refund],
              where: s.inserted_at > ^sdate and s.inserted_at < ^edate,
              group_by: [s.sales_person_id],
              select: sum(s.subtotal)
            )
          )
          |> List.first()
        else
          Repo.all(
            from(s in Sale,
              left_join: u in User,
              on: s.sales_person_id == u.id,
              where: u.username == ^username or s.user_id == ^user.id,
              where: s.status not in ^[:pending_payment, :cancelled, :refund],
              where: s.inserted_at > ^sdate and s.inserted_at < ^edate,
              where: is_nil(s.merchant_id),
              group_by: [s.sales_person_id],
              select: sum(s.subtotal)
            )
          )
          |> List.first()
        end

      if show_rank do
        [res, user.rank.name]
      else
        res
      end
    else
      if show_rank do
        [0, "n/a"]
      else
        0
      end
    end
  end

  @doc """

  CommerceFront.Settings.last_month_sales("yuetmee070")
  """
  def last_month_sales(username, show_rank \\ nil) do
    # Get the first and last day of the previous month using Timex
    {:ok, sdate} =
      Timex.beginning_of_month(Timex.shift(Date.utc_today(), months: -1))
      |> NaiveDateTime.new(~T[00:00:00])

    {:ok, edate} =
      Timex.end_of_month(Timex.shift(Date.utc_today(), months: -1))
      |> NaiveDateTime.new(~T[23:59:59])

    # Fetch user and preload rank
    user = get_user_by_username(username) |> Repo.preload(:rank)

    if username == "haho_unpaid" do
      if show_rank do
        [36, "n/a"]
      else
        36
      end
    else
      # 03/03/25 =  if less than 1st july, will straight have 36
      special_date = Date.from_erl!({2025, 7, 1})

      if Date.compare(special_date, Date.utc_today()) == :gt do
        if show_rank do
          [36, user.rank.name]
        else
          36
        end
      else
        if user.inserted_at.year == Date.utc_today().year &&
             user.inserted_at.month == Date.utc_today().month do
          if show_rank do
            [36, user.rank.name]
          else
            36
          end
        else
          if user != nil do
            res =
              Repo.all(
                from(s in Sale,
                  left_join: u in User,
                  on: s.sales_person_id == u.id,
                  where: u.username == ^username or s.user_id == ^user.id,
                  where: s.status not in ^[:pending_payment, :cancelled, :refund],
                  where: s.inserted_at >= ^sdate and s.inserted_at <= ^edate,
                  where: not is_nil(s.merchant_id),
                  group_by: [s.sales_person_id],
                  select: sum(s.subtotal)
                )
              )
              |> List.first()

            if show_rank do
              [res || 0, user.rank.name]
            else
              res || 0
            end
          else
            if show_rank do
              [0, "n/a"]
            else
              0
            end
          end
        end
      end
    end
  end

  alias CommerceFront.Settings.ReferralGroupSalesSummary

  def list_referral_group_sales_summaries() do
    Repo.all(ReferralGroupSalesSummary)
  end

  def get_referral_group_sales_summary!(id) do
    Repo.get!(ReferralGroupSalesSummary, id)
  end

  def create_referral_group_sales_summary(params \\ %{}) do
    ReferralGroupSalesSummary.changeset(%ReferralGroupSalesSummary{}, params)
    |> Repo.insert()
    |> IO.inspect()
  end

  def update_referral_group_sales_summary(model, params) do
    ReferralGroupSalesSummary.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_referral_group_sales_summary(%ReferralGroupSalesSummary{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.ReferralGroupSalesDetail

  def list_referral_group_sales_details() do
    Repo.all(ReferralGroupSalesDetail)
  end

  def get_referral_group_sales_detail!(id) do
    Repo.get!(ReferralGroupSalesDetail, id)
  end

  def get_latest_referral_gs_summary_by_user_id(user_id, back_date \\ nil) do
    {y, m, d} =
      if back_date != nil do
        back_date
      else
        Date.utc_today()
      end
      |> Date.to_erl()

    subquery2 =
      from(gss in ReferralGroupSalesSummary,
        where:
          gss.month == ^m and
            gss.year == ^y and gss.user_id == ^user_id
      )

    Repo.all(subquery2)
    |> IO.inspect()
    |> List.first()
  end

  def latest_referral_group_sales_details(username, back_date \\ nil) do
    Repo.all(
      from(pgsd in ReferralGroupSalesDetail,
        left_join: u in User,
        on: pgsd.user_id == u.id,
        where: u.username == ^username,
        order_by: [desc: pgsd.id]
      )
    )
    |> List.first()
  end

  def create_referral_group_sales_detail(params \\ %{}, back_date \\ nil) do
    Multi.new()
    |> Multi.run(:gsd, fn _repo, %{} ->
      ReferralGroupSalesDetail.changeset(%ReferralGroupSalesDetail{}, params)
      |> Repo.insert()
    end)
    |> Multi.run(:gs_summary, fn _repo, %{gsd: gsd} ->
      check = get_latest_referral_gs_summary_by_user_id(gsd.user_id, back_date)

      case check do
        nil ->
          {y, m, d} =
            if back_date != nil do
              back_date |> Date.to_erl()
            else
              Date.utc_today() |> Date.to_erl()
            end

          create_referral_group_sales_summary(%{
            amount: gsd.amount,
            user_id: gsd.user_id,
            month: m,
            year: y
          })

        _ ->
          map = %{
            amount: gsd.amount + check.amount
          }

          {y, m, d} =
            if back_date != nil do
              back_date |> Date.to_erl()
            else
              Date.utc_today() |> Date.to_erl()
            end

          update_referral_group_sales_summary(
            check,
            %{
              user_id: gsd.user_id,
              day: d,
              month: m,
              year: y
            }
            |> Map.merge(map)
          )
      end
    end)
    |> Multi.run(:gsd2, fn _repo, %{gsd: gsd, gs_summary: gs_summary} ->
      ReferralGroupSalesDetail.changeset(gsd, %{referral_group_sales_summary_id: gs_summary.id})
      |> Repo.update()
    end)
    |> Repo.transaction()
    |> IO.inspect()
    |> case do
      {:ok, multi_res} ->
        gs_summary = multi_res |> Map.get(:gs_summary)
        {:ok, multi_res |> Map.get(:gsd) |> Map.put(:gs_summary, gs_summary)}

      _ ->
        {:error, []}
    end
  end

  def update_referral_group_sales_detail(model, params) do
    ReferralGroupSalesDetail.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_referral_group_sales_detail(%ReferralGroupSalesDetail{} = model) do
    Repo.delete(model)
  end

  def royalty_bonus(date_string) do
    [m, y] = String.split(date_string, "-")

    CommerceFront.Settings.reconstruct_monthly_referral_group_sales_summary(
      Date.from_erl!({y |> String.to_integer(), m |> String.to_integer(), 1})
    )

    Repo.all(
      from(rgs in ReferralGroupSalesSummary,
        where: rgs.month == ^m and rgs.year == ^y,
        preload: [:user]
      )
    )
    |> Enum.map(&(&1 |> BluePotion.sanitize_struct()))
  end

  def change_referral(username, to_new_placement_username) do
    u1 = get_user_by_username(username)
    u2 = get_user_by_username(to_new_placement_username)

    up1 = Repo.get_by(Referral, user_id: u1.id)

    up2 = Repo.get_by(Referral, user_id: u2.id)

    update_referral(up1, %{
      parent_user_id: u2.id,
      parent_referral_id: up2.id
    })
  end

  def change_placement(username, to_new_placement_username, position) do
    u1 = get_user_by_username(username)
    u2 = get_user_by_username(to_new_placement_username)

    up1 = Repo.get_by(Placement, user_id: u1.id)

    up2 = Repo.get_by(Placement, user_id: u2.id)

    update_placement(up1, %{
      position: position,
      parent_user_id: u2.id,
      parent_placement_id: up2.id
    })
  end

  def recalculate_wallet_before_after(wt_after_amount, wt_id, user_id, wallet_type) do
    wts =
      Repo.all(
        from(wt in WalletTransaction,
          where: wt.user_id == ^user_id and wt.id > ^wt_id,
          order_by: [asc: wt.id]
        )
      )

    calc = fn wt, after_amount ->
      update_wallet_transaction(wt, %{before: after_amount, after: wt.amount + after_amount})
      wt.amount + after_amount
    end

    Enum.reduce(wts, wt_after_amount, &calc.(&1, &2))
  end

  def cancel_sales(sales_id) do
    Multi.new()
    |> Multi.run(:delete, fn _repo, %{} ->
      s = get_sale!(sales_id)
      update_sale(s, %{status: :cancelled})
      rewards = Repo.all(from(r in Reward, where: r.sales_id == ^sales_id))

      for reward <- rewards do
        if reward.is_paid == true do
          # todo: reverse the amount
          # let the insert function finish update
          # remove the wt lines

          wt =
            Repo.all(from(wt in WalletTransaction, where: wt.reward_id == ^reward.id))
            |> List.first()
            |> IO.inspect()

          if wt != nil do
            CommerceFront.Settings.create_wallet_transaction(%{
              reward_id: reward.id,
              user_id: wt.user_id,
              amount: wt.amount * -1,
              remarks: "reverse",
              wallet_type: "bonus"
            })

            Repo.delete_all(from(wt in WalletTransaction, where: wt.reward_id == ^reward.id))

            recalculate_wallet_before_after(wt.before, wt.id, wt.user_id, "bonus")
          end
        end
      end

      rewards = Repo.delete_all(from(r in Reward, where: r.sales_id == ^sales_id))

      pgsds =
        Repo.all(
          from(pgsd in PlacementGroupSalesDetail,
            where: pgsd.sales_id == ^sales_id,
            preload: [:gs_summary]
          )
        )

      date =
        pgsds
        |> Enum.map(&Date.from_erl!({&1.gs_summary.year, &1.gs_summary.month, &1.gs_summary.day}))
        |> Enum.uniq()
        |> List.first()

      if date != nil do
        Repo.delete_all(
          from(pgsd in PlacementGroupSalesDetail,
            where: pgsd.sales_id == ^sales_id
          )
        )

        CommerceFront.carry_forward_task(date |> Date.add(-1))
        CommerceFront.Settings.reconstruct_daily_group_sales_summary(Date.utc_today())
      end

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  alias CommerceFront.Settings.ProductStock

  def list_product_stocks() do
    Repo.all(ProductStock)
  end

  def get_product_stock!(id) do
    Repo.get!(ProductStock, id)
  end

  def create_product_stock(params \\ %{}) do
    ProductStock.changeset(%ProductStock{}, params) |> Repo.insert() |> IO.inspect()

    product_id = Map.keys(params["Stock"]) |> List.first()

    items = params["Stock"][product_id] |> Map.keys()
    Repo.delete_all(from(rap in ProductStock, where: rap.product_id == ^product_id))

    for item <- items do
      params = %{"product_id" => product_id, "stock_id" => item}
      ProductStock.changeset(%ProductStock{}, params) |> Repo.insert() |> IO.inspect()
    end

    {:ok, %ProductStock{id: 0}}
  end

  def update_product_stock(model, params) do
    ProductStock.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_product_stock(%ProductStock{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Location

  def list_locations() do
    Repo.all(Location)
  end

  def get_location!(id) do
    Repo.get!(Location, id)
  end

  def create_location(params \\ %{}) do
    Location.changeset(%Location{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_location(model, params) do
    Location.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_location(%Location{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.StockMovementSummary

  def list_stock_movement_summaries() do
    Repo.all(StockMovementSummary)
  end

  def get_stock_movement_summary!(id) do
    Repo.get!(StockMovementSummary, id)
  end

  def create_stock_movement_summary(params \\ %{}) do
    StockMovementSummary.changeset(%StockMovementSummary{}, params)
    |> Repo.insert()
    |> IO.inspect()
  end

  def update_stock_movement_summary(model, params) do
    StockMovementSummary.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_stock_movement_summary(%StockMovementSummary{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.Stock

  def list_stocks() do
    Repo.all(Stock)
  end

  def get_stock!(id) do
    Repo.get!(Stock, id)
  end

  def create_stock(params \\ %{}) do
    Stock.changeset(%Stock{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_stock(model, params) do
    Stock.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_stock(%Stock{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.StockMovement

  def list_stock_movements() do
    Repo.all(StockMovement)
  end

  def get_latest_stock_movement(id, location_id) do
    Repo.all(
      from(sm in StockMovement,
        where: sm.stock_id == ^id and sm.location_id == ^location_id,
        order_by: [desc: sm.id]
      )
    )
    |> List.first()
  end

  def get_stock_movement!(id) do
    Repo.get!(StockMovement, id)
  end

  @doc """
  cg =

  CommerceFront.Settings.create_stock_movement(%{"stock_id" => 1, "location_id" => 1,  "amount" => 1, "remarks" => "receiving from supplier DO"})
  """

  def create_stock_movement(params \\ %{}) do
    Multi.new()
    |> Multi.run(:movement, fn _repo, %{} ->
      prev_sm = get_latest_stock_movement(params["stock_id"], params["location_id"])

      params =
        if prev_sm == nil do
          params |> Map.merge(%{"before" => 0, "after" => params["amount"]})
        else
          params
          |> Map.merge(%{"before" => prev_sm.after, "after" => params["amount"] + prev_sm.after})
        end

      StockMovement.changeset(%StockMovement{}, params) |> Repo.insert() |> IO.inspect()
    end)
    |> Multi.run(:summary, fn _repo, %{movement: movement} ->
      {{y, m, d}, _time} = movement.inserted_at |> NaiveDateTime.to_erl()

      check =
        Repo.all(
          from(sms in StockMovementSummary,
            where:
              sms.location_id == ^params["location_id"] and sms.stock_id == ^movement.stock_id and
                sms.year == ^y and sms.month == ^m and
                sms.day == ^d
          )
        )
        |> List.first()

      if check == nil do
        create_stock_movement_summary(%{
          stock_id: movement.stock_id,
          year: y,
          month: m,
          day: d,
          location_id: params["location_id"],
          amount: movement.after
        })
      else
        update_stock_movement_summary(check, %{amount: movement.after})
      end

      # StockMovement.changeset(%StockMovement{}, params) |> Repo.insert() |> IO.inspect()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, multi_res} ->
        {:ok, multi_res |> Map.get(:movement)}

      _ ->
        {:error, []}
    end
  end

  def update_stock_movement(model, params) do
    StockMovement.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_stock_movement(%StockMovement{} = model) do
    Repo.delete(model)
  end

  def mark_sent(params, sale) do
    sample = %{
      "id" => 749,
      "location_id" => 3,
      "scope" => "mark_do",
      "shipping_ref" => "111",
      "status" => "sent"
    }

    Multi.new()
    |> Multi.run(:sale, fn _repo, %{} ->
      {:ok, sale} =
        update_sale(sale, %{
          status: params["status"],
          shipping_ref: params["shipping_ref"]
        })

      sales_items = sale |> Repo.preload(:sales_items) |> Map.get(:sales_items)

      for item <- sales_items do
        product = get_product_by_name(item.item_name) |> Repo.preload(:stocks) |> IO.inspect()

        product_stocks = product.product_stock

        for product_stock <- product_stocks do
          stock = product_stock.stock
          # todo; self pickup, directl append the location from pick up point
          # todo; delivery , check from params for the location id...

          CommerceFront.Settings.create_stock_movement(%{
            "location_id" => params["location_id"],
            "stock_id" => stock.id,
            "amount" => product_stock.qty * item.qty * -1,
            "remarks" => "delivery outbound|sales_item_id:#{item.id}|#{params["shipping_ref"]}"
          })
          |> IO.inspect()
        end
      end

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  alias CommerceFront.Settings.StockAdjustment

  def list_stock_adjustments() do
    Repo.all(StockAdjustment)
  end

  def get_stock_adjustment!(id) do
    Repo.get!(StockAdjustment, id)
  end

  def create_stock_adjustment(params \\ %{}) do
    StockAdjustment.changeset(%StockAdjustment{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_stock_adjustment(model, params) do
    StockAdjustment.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_stock_adjustment(%StockAdjustment{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.StockAdjustmentLine

  def list_stock_adjustment_lines() do
    Repo.all(StockAdjustmentLine)
  end

  def get_stock_adjustment_line!(id) do
    Repo.get!(StockAdjustmentLine, id)
  end

  def create_stock_adjustment_line(params \\ %{}) do
    StockAdjustmentLine.changeset(%StockAdjustmentLine{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_stock_adjustment_line(model, params) do
    StockAdjustmentLine.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_stock_adjustment_line(%StockAdjustmentLine{} = model) do
    Repo.delete(model)
  end

  def approve_adjustment(params) do
    sa = get_stock_adjustment!(params["id"]) |> Repo.preload(:stock_adjustment_lines)

    Multi.new()
    |> Multi.run(:adjustments, fn _repo, %{} ->
      for item <- sa.stock_adjustment_lines do
        CommerceFront.Settings.create_stock_movement(%{
          "stock_adjustment_id" => sa.id,
          "location_id" => sa.location_id,
          "stock_id" => item.stock_id,
          "amount" => item.qty,
          "remarks" => sa.title <> " " <> sa.ref_no
        })
      end

      {:ok, nil}
    end)
    |> Multi.run(:adjustment, fn _repo, %{} ->
      update_stock_adjustment(sa, %{status: "complete"})
    end)
    |> Repo.transaction()
  end

  alias CommerceFront.Settings.ShareLink

  def list_share_links() do
    Repo.all(ShareLink)
  end

  def get_share_link_by_code(code) do
    Repo.get_by(ShareLink, share_code: code)
  end

  def get_share_link!(id) do
    Repo.get!(ShareLink, id)
  end

  def create_share_link(params \\ %{}) do
    ShareLink.changeset(%ShareLink{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_share_link(model, params) do
    ShareLink.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_share_link(%ShareLink{} = model) do
    Repo.delete(model)
  end

  def generate_merchant_link(params) do
    user = get_user_by_username(params["username"])

    {:ok, l} =
      create_share_link(%{
        user_id: user.id,
        share_code: Ecto.UUID.generate(),
        position: params["position"]
      })

    server_url = "http://localhost:4000/"
    server_url = Application.get_env(:commerce_front, :url)

    BluePotion.sanitize_struct(l)
    |> Map.put(:link, "#{server_url}merchant_code_register/#{l.share_code}")
  end

  def generate_link(params) do
    user = get_user_by_username(params["username"])

    {:ok, l} =
      create_share_link(%{
        user_id: user.id,
        share_code: Ecto.UUID.generate(),
        position: params["position"]
      })

    server_url = "http://localhost:4000/"
    server_url = Application.get_env(:commerce_front, :url)

    BluePotion.sanitize_struct(l) |> Map.put(:link, "#{server_url}code_register/#{l.share_code}")
  end

  alias CommerceFront.Settings.Merchant

  def list_merchants() do
    Repo.all(Merchant)
  end

  def get_merchant!(id) do
    Repo.get!(Merchant, id)
  end

  def create_merchant(params \\ %{}) do
    Merchant.changeset(%Merchant{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_merchant(model, params) do
    bool_key = "is_open"
    params = append_bool_key(params, bool_key)

    Merchant.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_merchant(%Merchant{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.MerchantProduct

  def list_merchant_products() do
    Repo.all(MerchantProduct)
  end

  def get_merchant_product_by_name(name) do
    Repo.all(from(mp in MerchantProduct, where: ilike(mp.name, ^"%#{name}%"))) |> List.first()
  end

  def get_merchant_product!(id) do
    Repo.get!(MerchantProduct, id)
  end

  def create_merchant_product(params \\ %{}) do
    MerchantProduct.changeset(%MerchantProduct{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_merchant_product(model, params) do
    MerchantProduct.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_merchant_product(%MerchantProduct{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.MerchantSale

  def list_merchant_sales() do
    Repo.all(MerchantSale)
  end

  def get_merchant_sale!(id) do
    Repo.get!(MerchantSale, id)
  end

  def create_merchant_sale(params \\ %{}) do
    MerchantSale.changeset(%MerchantSale{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_merchant_sale(model, params) do
    MerchantSale.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_merchant_sale(%MerchantSale{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.MerchantSaleItem

  def list_merchant_sales_items() do
    Repo.all(MerchantSaleItem)
  end

  def get_merchant_sale_item!(id) do
    Repo.get!(MerchantSaleItem, id)
  end

  def create_merchant_sale_item(params \\ %{}) do
    MerchantSaleItem.changeset(%MerchantSaleItem{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_merchant_sale_item(model, params) do
    MerchantSaleItem.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_merchant_sale_item(%MerchantSaleItem{} = model) do
    Repo.delete(model)
  end

  def disable_merchant(params) do
    m = get_merchant!(params["id"])

    update_merchant(m, %{"is_approved" => false})
  end

  def approve_merchant(params) do
    m = get_merchant!(params["id"])

    update_merchant(m, %{"is_approved" => true})
  end

  alias CommerceFront.Settings.MerchantCategory

  def list_merchant_categories() do
    Repo.all(MerchantCategory)
  end

  def get_merchant_category!(id) do
    Repo.get!(MerchantCategory, id)
  end

  def create_merchant_category(params \\ %{}) do
    MerchantCategory.changeset(%MerchantCategory{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_merchant_category(model, params) do
    MerchantCategory.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_merchant_category(%MerchantCategory{} = model) do
    Repo.delete(model)
  end

  def clear_zero_rewards() do
    Repo.delete_all(
      from(r in CommerceFront.Settings.Reward, where: r.amount == ^0 and r.is_paid == ^false)
    )
  end

  alias CommerceFront.Settings.Instalment

  def list_instalments() do
    Repo.all(Instalment)
  end

  def get_instalment!(id) do
    Repo.get!(Instalment, id)
  end

  def create_instalment(params \\ %{}) do
    Instalment.changeset(%Instalment{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_instalment(model, params) do
    Instalment.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_instalment(%Instalment{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.MemberInstalment

  def list_member_instalments() do
    Repo.all(MemberInstalment)
  end

  def list_outstanding_member_instalments(user_id) do
    # Repo.all(from mi in MemberInstalment, where: mi.user_id == ^user_id)
    mi =
      Repo.all(
        from(mi in CommerceFront.Settings.MemberInstalment,
          where:
            mi.user_id == ^user_id and
              mi.is_paid == ^false,
          preload: [:product, :user, :instalment, member_instalment_product: :product],
          order_by: [asc: mi.id]
        )
      )
      |> List.first()
  end

  def get_member_instalment!(id) do
    Repo.get!(MemberInstalment, id)
  end

  def create_member_instalment(params \\ %{}) do
    MemberInstalment.changeset(%MemberInstalment{}, params) |> Repo.insert() |> IO.inspect()
  end

  def update_member_instalment(model, params) do
    MemberInstalment.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_member_instalment(%MemberInstalment{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.InstalmentProduct

  def list_instalment_products() do
    Repo.all(InstalmentProduct)
  end

  def get_instalment_product!(id) do
    Repo.get!(InstalmentProduct, id)
  end

  def _create_product_country(params \\ %{}) do
    ProductCountry.changeset(%ProductCountry{}, params) |> Repo.insert() |> IO.inspect()

    product_id = Map.keys(params["Country"]) |> List.first()

    items = params["Country"][product_id] |> Map.keys()
    Repo.delete_all(from(rap in ProductCountry, where: rap.product_id == ^product_id))

    for item <- items do
      params = %{"product_id" => product_id, "country_id" => item}
      ProductCountry.changeset(%ProductCountry{}, params) |> Repo.insert() |> IO.inspect()
    end

    {:ok, %ProductCountry{id: 0}}
  end

  def create_instalment_product(params \\ %{}) do
    sample = %{
      "Product" => %{"34" => %{"4" => "on"}},
      "id" => "0",
      "month_no" => "3",
      "qty" => "1"
    }

    instalment_product_id = params["Product"] |> Map.keys() |> List.first()

    Repo.delete_all(
      from(rap in InstalmentProduct,
        where:
          rap.instalment_product_id == ^instalment_product_id and
            rap.month_no == ^params["month_no"]
      )
    )

    product_id = params["Product"][instalment_product_id] |> Map.keys() |> List.first()

    InstalmentProduct.changeset(%InstalmentProduct{}, %{
      qty: params["qty"],
      month_no: params["month_no"],
      instalment_product_id: instalment_product_id,
      product_id: product_id
    })
    |> Repo.insert()
    |> IO.inspect()
  end

  def update_instalment_product(model, params) do
    InstalmentProduct.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_instalment_product(%InstalmentProduct{} = model) do
    Repo.delete(model)
  end

  alias CommerceFront.Settings.MemberInstalmentProduct

  def list_member_instalment_products() do
    Repo.all(MemberInstalmentProduct)
  end

  def get_member_instalment_product!(id) do
    Repo.get!(MemberInstalmentProduct, id)
  end

  def create_member_instalment_product(params \\ %{}) do
    MemberInstalmentProduct.changeset(%MemberInstalmentProduct{}, params)
    |> Repo.insert()
    |> IO.inspect()
  end

  def update_member_instalment_product(model, params) do
    MemberInstalmentProduct.changeset(model, params) |> Repo.update() |> IO.inspect()
  end

  def delete_member_instalment_product(%MemberInstalmentProduct{} = model) do
    Repo.delete(model)
  end

  def remove_duplicated_reward_payouts() do
    q =
      WalletTransaction
      |> join(:left, [wt], w in Ewallet, on: wt.ewallet_id == w.id)
      |> where([wt, w], not is_nil(wt.reward_id))
      |> group_by([wt, w], [wt.remarks, wt.user_id])
      |> select([wt, w], %{
        count: count(wt.remarks),
        user_id: wt.user_id,
        remarks: wt.remarks
      })

    # |> where([r], r.name == ^"royalty bonus")

    checks =
      Repo.all(q)
      |> Enum.filter(&(&1.remarks |> String.contains?("royalty")))

    for %{count: count, user_id: user_id, remarks: remarks} = check <- checks do
      wts =
        Repo.all(
          from(wt in WalletTransaction,
            where: wt.remarks == ^remarks and wt.user_id == ^user_id
          )
        )

      if Enum.count(wts) > 1 do
        [hd | tl] = wts

        adjustments =
          for tail_wt <- tl do
            {:ok, multi_res} =
              create_wallet_transaction(%{
                user_id: tail_wt.user_id,
                amount: tail_wt.amount * -1,
                remarks: "System adjustment|duplicate payout|from trx: #{tail_wt.id}",
                wallet_type: "register"
              })

            multi_res |> Map.get(:wallet_transaction)
          end

        # tl |> Enum.map(&(&1 |> Repo.delete()))
        # adjustments |> Enum.map(&(&1 |> Repo.delete()))
      end
    end
  end

  update_wallet_balance2 = fn user_ids ->
    for user_id <- user_ids do
      wt_res =
        CommerceFront.Repo.all(
          from(wt in CommerceFront.Settings.WalletTransaction,
            left_join: w in CommerceFront.Settings.Ewallet,
            on: w.id == wt.ewallet_id,
            where: w.wallet_type == ^"register",
            where: w.user_id == ^user_id,
            order_by: [desc: wt.id]
          )
        )
        |> List.first()

      if wt_res != nil do
        after_amt = wt_res |> Map.get(:after)

        ewallet = wt_res |> Repo.preload(:ewallet) |> Map.get(:ewallet)

        CommerceFront.Settings.update_ewallet(ewallet, %{total: after_amt})
      else
        IO.inspect("#{user_id} don hav register wallet?")
      end
    end
  end

  def update_wallet_balance(user_ids \\ [51, 60, 196, 375, 175, 49, 515, 448]) do
    sample = [51, 60, 196, 375, 175, 49, 515, 448]

    for user_id <- user_ids do
      wt_res =
        CommerceFront.Repo.all(
          from(wt in CommerceFront.Settings.WalletTransaction,
            left_join: w in CommerceFront.Settings.Ewallet,
            on: w.id == wt.ewallet_id,
            where: w.wallet_type == ^"register",
            where: w.user_id == ^user_id,
            order_by: [desc: wt.id]
          )
        )
        |> List.first()

      if wt_res != nil do
        after_amt = wt_res |> Map.get(:after)

        ewallet = wt_res |> Repo.preload(:ewallet) |> Map.get(:ewallet)

        CommerceFront.Settings.update_ewallet(ewallet, %{total: after_amt})
      else
        IO.inspect("#{user_id} don hav register wallet?")
      end
    end
  end

  def clone_products(ids \\ [56, 57, 58], first_payment_product_id \\ 83) do
    products =
      Repo.all(
        from(p in Product,
          where: p.id in ^ids,
          preload: [:countries, :stocks, instalment_products: [:product]]
        )
      )

    Multi.new()
    |> Multi.run(:clone, fn _repo, %{} ->
      for product <- products do
        cg =
          product
          |> BluePotion.sanitize_struct()
          |> Map.put(:first_payment_product_id, first_payment_product_id)
          |> IO.inspect()

        {:ok, nproduct} = create_product(cg)

        for ip <- cg.instalment_products do
          InstalmentProduct.changeset(
            %InstalmentProduct{},
            ip
            |> Map.put(:product_id, nproduct.id)
          )
          |> Repo.insert()
        end

        for stock <- cg.countries do
          ProductCountry.changeset(
            %ProductCountry{},
            %{country_id: stock.id}
            |> Map.put(:product_id, nproduct.id)
          )
          |> Repo.insert()
        end

        for stock <- cg.stocks do
          ProductStock.changeset(
            %ProductStock{},
            %{stock_id: stock.id}
            |> Map.put(:product_id, nproduct.id)
          )
          |> Repo.insert()
        end
      end
      |> IO.inspect()

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  def travel_fund_qualifier(year, month) do
    date = Date.from_erl!({year, month, 1})
    end_date = date |> Timex.end_of_month()

    subquery2 = """
    select
    sum(gss.new_left) as left,
    sum(gss.new_right) as right,
    u.username,
    gss.user_id ,
    gss.month,
    gss.year
    from
    group_sales_summaries gss
    left join users u on u.id = gss.user_id
    where
    gss.month = $1
    and gss.year = $2
    group by
    u.username,
    gss.user_id,
    gss.month,
    gss.year ;
    """

    {:ok, %Postgrex.Result{columns: columns, rows: rows} = res} =
      Ecto.Adapters.SQL.query(Repo, subquery2, [month, year])

    users_weak_leg =
      for row <- rows do
        Enum.zip(columns |> Enum.map(&(&1 |> String.to_atom())), row) |> Enum.into(%{})
      end
  end

  @doc """

  CommerceFront.Settings.test_freebie(56, 590)

  """

  def test_freebie(instalment_product_id, user_id) do
    user = get_user!(user_id)
    product = get_product!(instalment_product_id)

    mi =
      Repo.all(
        from(mi in CommerceFront.Settings.MemberInstalment,
          where:
            mi.user_id == ^user.id and mi.product_id == ^product.id and
              mi.is_paid == ^true and mi.id == ^51
        )
      )
      |> List.first()

    freebie = mi |> Repo.preload(:freebie) |> Map.get(:freebie)
  end

  def reseed_travel_wallet() do
    users = Repo.all(User)

    checks = Repo.all(from(w in Ewallet, where: w.wallet_type == "travel"))

    for user <- users do
      check = Enum.filter(checks, &(&1.user_id == user.id))

      if check == [] do
        CommerceFront.Settings.create_wallet_transaction(%{
          user_id: user.id,
          amount: 0.00,
          remarks: "initial",
          wallet_type: "travel"
        })
      end
    end
  end

  @doc """
  CommerceFront.Settings.regenerate_instalment(80, 595)
  595 80
  CommerceFront.Settings.regenerate_instalment(80, 595)
  528 78
  CommerceFront.Settings.regenerate_instalment(78, 528)
  552 77
  CommerceFront.Settings.regenerate_instalment(77, 552)
  """

  def regenerate_instalment(instalment_product_id, user_id) do
    user = get_user!(user_id)

    instalment_product =
      Repo.all(
        from(p in CommerceFront.Settings.Product,
          where: p.id == ^instalment_product_id
        ),
        preload: [:instalment, :instalment_packages, :instalment_products]
      )
      |> List.first()
      |> Repo.preload(:instalment)

    instalment = instalment_product |> Map.get(:instalment)

    for item <- 1..instalment.no_of_months do
      # todo need to check the main package for delay
      due_date = Date.utc_today() |> Timex.shift(months: item + instalment.delay)

      mi_check =
        Repo.all(
          from(mi in CommerceFront.Settings.MemberInstalment,
            where:
              mi.instalment_id == ^instalment.id and
                mi.month_no == ^item and
                mi.user_id == ^user.id and
                mi.product_id == ^instalment_product.id
          )
        )

      {:ok, member_instalment} =
        if mi_check == [] do
          CommerceFront.Settings.create_member_instalment(%{
            due_date: due_date,
            instalment_id: instalment.id,
            is_paid: false,
            month_no: item,
            product_id: instalment_product.id,
            user_id: user.id
          })
        else
          {:ok, List.first(mi_check)}
        end

      instalment_products =
        instalment_product
        |> Repo.preload([:instalment_products])
        |> Map.get(:instalment_products)

      freebie =
        instalment_products
        |> Enum.filter(&(&1.month_no == item))
        |> List.first()

      if freebie != nil do
        CommerceFront.Settings.create_member_instalment_product(%{
          member_instalment_id: member_instalment.id,
          instalment_product_id: freebie.id
        })
      end
    end
  end

  def get_all_members_sales() do
    Sale
    |> join(:inner, [s], u in User, on: s.user_id == u.id)
    |> group_by([s, u], [s.user_id, u.username])
    |> select([s, u], %{user_id: s.user_id, username: u.username, total_sales: sum(s.grand_total)})
    |> Repo.all()
  end

  def get_parent_member_sales() do
    Referral
    |> join(:inner, [r], parent in User, on: parent.id == r.parent_user_id)
    |> join(:inner, [r, parent], child in User, on: child.id == r.user_id)
    |> join(:left, [r, parent, child], s in Sale, on: s.user_id == child.id)
    |> group_by([_r, parent, child, _s], [parent.id, parent.username, child.id, child.username])
    |> select([_r, parent, child, s], %{
      user_id: parent.id,
      username: parent.username,
      child_user_id: child.id,
      child_username: child.username,
      total_sales: coalesce(sum(s.grand_total), 0.0)
    })
    |> Repo.all()
  end

  require IEx

  def get_parent_tickets() do
    all_members_sales = get_all_members_sales()
    res = get_parent_member_sales()

    parent_data = res |> Enum.group_by(&{&1.user_id, &1.username})

    parents = Map.keys(parent_data) |> Enum.sort_by(&elem(&1, 0))

    for parent <- parents do
      parent_id = elem(parent, 0)
      parent_username = elem(parent, 1)
      child_data = parent_data[parent]
      r = child_data

      child_sum = r |> Enum.map(& &1.total_sales) |> Enum.sum()

      check = all_members_sales |> Enum.filter(&(&1.user_id == parent_id)) |> List.first()

      parent_sum =
        if check != nil do
          check
          |> Map.get(:total_sales)
        else
          0.0
        end

      fin = %{
        parent_sum: parent_sum,
        child_sum: child_sum,
        parent_id: parent_id,
        parent_username: parent_username,
        parent_sum_tickets: Float.round(parent_sum / 72, 0),
        child_sum_tickets: Float.round(child_sum / 144, 0),
        total_ticket: Float.round(parent_sum / 72 + child_sum / 144, 0)
      }

      fin
    end
  end
end
