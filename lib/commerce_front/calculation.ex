defmodule CommerceFront.Calculation do
  require Logger

  import Ecto.Query, warn: false
  alias CommerceFront.Repo
  require IEx
  alias Ecto.Multi
  alias CommerceFront.Settings
  alias CommerceFront.Settings.{User, Reward}

  @doc """
  CommerceFront.Calculation.mp_sales_level_bonus(sales_id, form_mp, sale, date, merchant)

  import Ecto.Query
  alias CommerceFront.{Settings, Repo}
  id = 300
  sale =  Repo.all(from s in Settings.Sale, where: s.id == ^id, preload: :merchant)  |> List.first
       CommerceFront.Calculation.mp_sales_level_bonus(
                      sale.id,
                      0,
                      sale,
                      Date.utc_today(),
                      sale |> Map.get(:merchant)
                    )

  """

  def mp_sales_level_bonus(sales_id, form_mp, sale, date, merchant) do
    params = [sales_id, form_mp, sale, date]

    {y, m, d} =
      date
      |> Date.to_erl()

    # need to check if the sales item comission settings...
    # need to pay based on their ranking
    # compress upline

    # need to check if the preferred shopper had done their maintainance last month

    keys = sale.registration_details |> Jason.decode!() |> Map.get("user") |> Map.keys()

    target =
      with true <- "merchant" in keys,
           true <- "sponsor" in keys || "upgrade" in keys do
        if "upgrade" in keys do
          sale.registration_details |> Jason.decode!() |> Map.get("user") |> Map.get("upgrade")
        else
          sale.registration_details |> Jason.decode!() |> Map.get("user") |> Map.get("username")
        end
      else
        _ ->
          sale.user.username
      end
      |> IO.inspect(label: "target mp sales level bonus")

    uplines =
      CommerceFront.Settings.check_uplines(
        target,
        :referal
      )
      |> Enum.reverse()
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> Enum.reverse()

    matrix = [
      %{rank: "PreferredShopper", max: 5},
      %{rank: "铜级套餐", max: 6},
      %{rank: "银级套餐", max: 7},
      %{rank: "金级套餐", max: 8}
    ]

    calc = fn upline, index ->
      upline_rank = matrix |> Enum.filter(&(&1.rank == upline.rank)) |> List.first()

      if upline_rank != nil do
        # last_month_sum = Settings.last_month_sales(upline.parent)

        # if upline_rank.rank in ["PreferredShopper", "铜级套餐", "银级套餐", "金级套餐"] &&
        #      last_month_sum < 36 do
        #   index
        # else
        # # prev code here 
        # end
        if index < 8 do
          IO.inspect("current index at #{index}")

          max =
            matrix |> Enum.filter(&(&1.rank == upline.rank)) |> List.first() |> Map.get(:max)

          perc = (merchant.commission_perc / 8) |> Float.round(4)

          if index < max do
            amount = (perc * sale.total_point_value) |> Float.round(2)

            CommerceFront.Settings.create_reward(%{
              sales_id: sale.id,
              is_paid: false,
              remarks:
                "sales-#{sale.id} on #{y}-#{m}-#{d}|commission perc: #{perc}|level: #{index + 1}|upline rank: #{upline.rank} | #{perc} * #{sale.total_point_value} ",
              name: "merchant sales level bonus",
              amount: amount,
              user_id: upline.parent_id,
              day: d,
              month: m,
              year: y
            })
          else
            IO.inspect("not qualify, will pay to unpaid")

            amount = (perc * sale.total_point_value) |> Float.round(2)

            CommerceFront.Settings.create_reward(%{
              sales_id: sale.id,
              is_paid: false,
              remarks:
                "sales-#{sale.id} on #{y}-#{m}-#{d}|commission perc: #{perc}|level: #{index + 1}| #{perc} * #{sale.total_point_value} ",
              name: "merchant sales level bonus",
              amount: amount,
              user_id: unpaid_node.parent_id,
              day: d,
              month: m,
              year: y
            })
          end
        end

        index + 1
      else
        index
      end
    end

    Enum.reduce(uplines, 0, &calc.(&1, &2))
  end

  def royalty_bonus(sale, user, date) do
    {y, m, d} =
      date
      |> Date.to_erl()

    uplines = CommerceFront.Settings.check_uplines(user.username, :referal)

    calc = fn upline, {prev_perc, accumulated_perc} ->
      upline_user = Settings.get_user_by_username(upline.parent) |> Repo.preload(:royalty_user)

      if upline_user |> Map.get(:royalty_user) != nil do
        royalty_user = upline_user |> Map.get(:royalty_user)
        perc = royalty_user.perc

        res = (perc - prev_perc) |> Float.round(3)

        if accumulated_perc <= 0.05 do
          check =
            Repo.all(
              from(r in CommerceFront.Settings.Reward,
                where:
                  r.sales_id == ^sale.id and r.name == ^"royalty bonus" and
                    r.day == ^d and
                    r.month == ^m and
                    r.year == ^y and
                    r.user_id == ^upline_user.id and r.is_paid == ^true
              )
            )

          if check == [] do
            CommerceFront.Settings.create_reward(%{
              sales_id: sale.id,
              is_paid: false,
              remarks:
                "sales-#{sale.id} on #{y}-#{m}-#{d}|royalty perc: #{perc}|calc perc: #{res}| #{res} * #{sale.total_point_value} ",
              name: "royalty bonus",
              amount: (res * sale.total_point_value) |> Float.round(2),
              user_id: upline_user.id,
              day: d,
              month: m,
              year: y
            })
          else
            IO.inspect("there is paid royalty bonus ")
          end

          {perc, accumulated_perc + perc}
        else
          remm = (accumulated_perc - prev_perc) * sale.total_point_value

          amt =
            if remm > 0 do
              remm |> Float.round(2)
            else
              remm
            end

          check =
            Repo.all(
              from(r in CommerceFront.Settings.Reward,
                where:
                  r.sales_id == ^sale.id and r.name == ^"royalty bonus" and
                    r.day == ^d and
                    r.month == ^m and
                    r.year == ^y and
                    r.user_id == ^upline_user.id and r.is_paid == ^true
              )
            )

          if check == [] do
            res2 = (accumulated_perc - prev_perc) |> Float.round(3)

            CommerceFront.Settings.create_reward(%{
              sales_id: sale.id,
              is_paid: false,
              remarks:
                "sales-#{sale.id} on #{y}-#{m}-#{d}|royalty perc: #{perc}|calc perc: #{res}| #{res} * #{sale.total_point_value} ",
              name: "royalty bonus",
              # amount: amt,
              amount: (res * sale.total_point_value) |> Float.round(2),
              user_id: upline_user.id,
              day: d,
              month: m,
              year: y
            })
          else
            IO.inspect("there is paid royalty bonus ")
          end

          nil
        end
      else
        {prev_perc, accumulated_perc}
      end
    end

    Enum.reduce(uplines, {0.00, 0.00}, &calc.(&1, &2))
  end

  def stockist_register_bonus(sales_person, username, pv, sale) do
    bonus = (pv * 0.03) |> Float.round(2)

    CommerceFront.Settings.create_reward(%{
      sales_id: sale.id,
      is_paid: false,
      remarks: "sales-#{sale.id}|#{pv} * 0.03 = #{bonus}|register: #{username}",
      name: "stockist register bonus",
      amount: bonus,
      user_id: sales_person.id,
      day: Date.utc_today().day,
      month: Date.utc_today().month,
      year: Date.utc_today().year
    })
  end

  def biz_incentive_bonus(sales_person, username, pv, sale) do
    bonus = (pv * 0.20) |> Float.round(2)

    {:ok, r} =
      CommerceFront.Settings.create_reward(%{
        sales_id: sale.id,
        is_paid: false,
        remarks: "sales-#{sale.id}|#{pv} * 0.20 = #{bonus}|register: #{username}",
        name: "biz incentive bonus",
        amount: bonus,
        user_id: sales_person.id,
        day: Date.utc_today().day,
        month: Date.utc_today().month,
        year: Date.utc_today().year
      })

    CommerceFront.Settings.pay_to_bonus_wallet(r)
  end

  def matching_biz_incentive_bonus(month, year) do
    date = Date.from_erl!({year, month, 1})

    subquery = """
    select
      u.username,
      r.user_id,
      sum(r.amount),
      r.month,
      r.year
    from
      rewards r
    left join users u on
      u.id = r.user_id
    where
      r.name = 'biz incentive bonus'
      and r.month = $1
      and r.year = $2
    group by
      u.username,
      r.user_id,
      r.month,
      r.year;
    """

    {:ok, %Postgrex.Result{columns: columns, rows: rows} = res} =
      Ecto.Adapters.SQL.query(Repo, subquery, [month, year])

    biz_incentive_bonuses =
      for row <- rows do
        Enum.zip(columns |> Enum.map(&(&1 |> String.to_atom())), row) |> Enum.into(%{})
      end

    unpaid_node = unpaid_node()

    Repo.delete_all(
      from(r in Reward,
        where: r.name == ^"matching biz incentive bonus" and r.month == ^month and r.year == ^year
      )
    )

    users = Repo.all(from(u in User, order_by: [desc: u.id]))

    Multi.new()
    |> Multi.run(:calculation, fn _repo, %{} ->
      for user <- users do
        uplines =
          Settings.check_uplines(user.username, :referal)
          |> Enum.reverse()
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> Enum.reverse()

        # check user has team bonus

        check =
          biz_incentive_bonuses
          |> Enum.filter(&(&1.user_id == user.id))
          |> List.first()
          |> IO.inspect()

        calc = fn upline, index ->
          if index < 3 do
            constant = 0.5
            bonus = check.sum * constant

            CommerceFront.Settings.create_reward(%{
              sales_id: 0,
              is_paid: false,
              remarks:
                "#{check.sum |> :erlang.float_to_binary(decimals: 2)} * #{constant} = #{bonus}||lvl:#{index}||#{user.username} biz incentive bonus at #{month}-#{year}: #{check.sum |> :erlang.float_to_binary(decimals: 2)}|",
              name: "matching biz incentive bonus",
              amount: bonus |> Float.round(2),
              user_id: upline.parent_id,
              day: Timex.end_of_month(date).day,
              month: month,
              year: year
            })
          end

          index + 1

          # check upline's weak leg
        end

        if check != nil do
          Enum.reduce(uplines, 1, &calc.(&1, &2))
        end
      end

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  @doc """
  A.2）Special Sharing Reward
  For every 100PV shared, receive an additional #DRP 50
  #DRP only for registering new shared entries, PV not included.
  When choosing DRP at registration, you only need to pay the balance of RP 50%.

  --
  28 jan 24'
  every 100 RP shared, received 50 DRP


  22 mar 24'
  base on override perc to calc

  sale = CommerceFront.Settings.get_sale!(624)
  referral = CommerceFront.Settings.get_referral_by_username("chingyee")
  CommerceFront.Calculation.special_share_reward(  referral.parent_user_id, sale.total_point_value, sale, "upgrade")

  """

  def special_share_reward(user_id, pv, sale, scope \\ "register") do
    override_perc = 0.5

    if pv != 0 do
      sales_items = sale |> Repo.preload(:sales_items) |> Map.get(:sales_items)
      # total = Enum.count(sales_items)

      for {sales_item, index} <- sales_items |> Enum.with_index() do
        product =
          if scope == "merchant_checkout" do
            CommerceFront.Settings.get_merchant_product_by_name(sales_item.item_name)
          else
            CommerceFront.Settings.get_product_by_name(sales_item.item_name)
          end

        if product.override_special_share_payout do
          CommerceFront.Settings.create_wallet_transaction(%{
            user_id: user_id,
            amount: (pv * product.override_special_share_payout_perc) |> Float.round(2),
            remarks: "sale-#{sale.id}|#{product.name}",
            wallet_type: "direct_recruitment"
          })
        else
          CommerceFront.Settings.create_wallet_transaction(%{
            user_id: user_id,
            amount: (pv * override_perc) |> Float.round(2),
            remarks: "sale-#{sale.id}|#{product.name}",
            wallet_type: "direct_recruitment"
          })
        end
      end
    else
      {:ok, nil}
    end
  end

  def unpaid_node() do
    unpaid_user = CommerceFront.Settings.unpaid_user()

    unpaid_node = %{
      child: "",
      child_id: 0,
      parent: unpaid_user.username,
      parent_id: unpaid_user.id,
      pt_child_id: 0,
      pt_parent_id: 0,
      rank: "金级套餐"
    }
  end

  @doc """


  find uplines,
  check upline rank,
  compress until the total_point_value is paid completely...

  need to pay the rest to unpaid account

  """
  def sharing_bonus(username, total_point_value, sale, referral) do
    unpaid_node = unpaid_node()

    uplines =
      CommerceFront.Settings.check_uplines(username, :referal)
      |> Enum.reverse()
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> Enum.reverse()
      |> Enum.with_index(1)

    matrix = [
      # %{rank: "Shopper", l1: 0.0, calculated: false},
      %{rank: "铜级套餐", l1: 0.2, calculated: false},
      %{rank: "银级套餐", l1: 0.2, l2: 0.1, calculated: false},
      %{rank: "金级套餐", l1: 0.2, l2: 0.1, l3: 0.1, calculated: false}
    ]

    run_calc = fn {upline, index}, {calc_index, eval_matrix, remainder_point_value} ->
      user = CommerceFront.Settings.get_user_by_username(upline.parent)
      rank = user.rank_id |> CommerceFront.Settings.get_rank!() |> IO.inspect()

      calc_table =
        matrix
        |> Enum.filter(&(&1.rank == rank.name))
        |> List.first()

      perc =
        if calc_table != nil do
          case calc_index do
            1 ->
              calc_table |> Map.get(:l1, 0)

            2 ->
              calc_table |> Map.get(:l2, 0)

            3 ->
              calc_table |> Map.get(:l3, 0)

            _ ->
              0
          end
          |> IO.inspect()
        else
          0
        end

      with true <- calc_table != nil,
           true <- calc_index < 4,
           list <-
             eval_matrix
             |> Enum.reject(&(&1.calculated == true))
             |> Enum.filter(&(&1.rank == rank.name)),
           true <- list != [],
           matrix_item <-
             list
             |> List.first(),
           calculated <-
             matrix_item
             |> Map.get(:calculated),
           true <- calculated == false do
        {bonus, remainder_point_value, addon_gold_bonus} =
          case calc_index do
            1 ->
              if rank.name == "金级套餐" do
                {remainder_point_value * perc, remainder_point_value, 0}
              else
                {min(remainder_point_value, 200) * perc, min(remainder_point_value, 200), 0}
              end 
       

            2 ->
              bonus = remainder_point_value * perc
              {bonus, remainder_point_value, 0}

            3 ->
              bonus = remainder_point_value * perc

              {bonus, addon_gold_bonus} =
                if total_point_value > 200 do
                  # if  at calc_index 1 is a rank gold, then no need  * 0.2 ...
                 lv1 = uplines |> Enum.at(0) |> elem(0) |> Map.get(:rank)
                  
                  if lv1 == "金级套餐" do
                    {bonus, 0}
                  else
                    {bonus, (total_point_value - 200) * 0.2}
                  end
                
                else
                  {bonus, 0}
                end
              
              {bonus , remainder_point_value, addon_gold_bonus}
          end

        {:ok, r} =
          CommerceFront.Settings.create_reward(%{
            sales_id: sale.id,
            is_paid: false,
            remarks:
              "sales-#{sale.id}|#{remainder_point_value} * #{perc} = #{bonus} + #{addon_gold_bonus}|lvl:#{calc_index}/#{rank.name}|skipped to: lv#{index}",
            name: "sharing bonus",
            amount: bonus + addon_gold_bonus,
            user_id: user.id,
            day: Date.utc_today().day,
            month: Date.utc_today().month,
            year: Date.utc_today().year
          })

        # CommerceFront.Settings.pay_to_bonus_wallet(r)

        new_matrix_item =
          matrix |> Enum.find(&(&1.rank == rank.name)) |> Map.put(:calculated, true)

        remove_index = matrix |> Enum.find_index(&(&1.rank == rank.name))

        pre_matrix = List.delete_at(matrix, 0)

        next_matrix = List.insert_at(pre_matrix, 0, new_matrix_item)

        # remainder_point_value - bonus
        {calc_index + 1, next_matrix, total_point_value}
      else
        _ ->
          {calc_index, eval_matrix, total_point_value}
      end
    end

    Enum.reduce(uplines, {1, matrix, total_point_value}, &run_calc.(&1, &2))

    {:ok, nil}
  end

  @doc """

  todo:  need 1 hour window to clarify, 8am calculate finish, 9am release to member ewallets

   todo: convert to daily calculation
  """

  def team_bonus(username, total_point_value, sale, placement, pgsd) do
    multi = Multi.new()

    summaries = pgsd |> Map.values() |> Enum.map(& &1)

    calc_for_parent = fn map, multi_query ->
      summary = map.gs_summary |> Repo.preload(:user)

      with true <- summary.total_left != nil,
           true <- summary.total_left != 0,
           true <- summary.total_right != nil,
           true <- summary.total_right != 0 do
        IO.inspect([summary.total_left, summary.total_right])

        latest_gs =
          CommerceFront.Settings.get_latest_gs_summary_by_user_id(
            summary.user.id,
            Date.from_erl!({summary.year, summary.month, summary.day})
          )

        constant = summary.total_left / summary.total_right

        {paired, changeset} =
          if constant > 1 do
            # this means, the left is more than right

            {total_point_value,
             %{
               balance_left: summary.total_left - summary.total_right,
               balance_right: summary.total_right - summary.total_right
             }}
          else
            {total_point_value,
             %{
               balance_left: summary.total_left - summary.total_left,
               balance_right: summary.total_right - summary.total_left
             }}
          end
          |> IO.inspect()

        multi_query
        |> Multi.run(String.to_atom("pgsd_left_#{summary.user_id}"), fn _repo, %{} ->
          if map.position == "left" do
            Logger.info("[team bonus] - after: #{map.after} - paired: #{paired}")

            CommerceFront.Settings.PlacementGroupSalesDetail.changeset(
              %CommerceFront.Settings.PlacementGroupSalesDetail{},
              %{
                before: map.after,
                after: map.after - paired,
                amount: -paired,
                from_user_id: 0,
                to_user_id: map.to_user_id,
                remarks: "pairing bonus calculation|from sale-#{sale.id}",
                sales_id: 0,
                position: "left"
              }
            )
          else
            Logger.info("[team bonus] - after: #{map.after} - paired: #{paired}")

            CommerceFront.Settings.PlacementGroupSalesDetail.changeset(
              %CommerceFront.Settings.PlacementGroupSalesDetail{},
              %{
                before: map.after,
                after: map.after - paired,
                amount: -paired,
                from_user_id: 0,
                to_user_id: map.to_user_id,
                remarks: "pairing bonus calculation|from sale-#{sale.id}",
                sales_id: 0,
                position: "right"
              }
            )
          end
          |> Repo.insert()
        end)
        |> Multi.run(String.to_atom("pgsd_right_#{summary.user_id}"), fn _repo, %{} ->
          if map.position == "left" do
            Logger.info("[team bonus] - after: #{map.after} - paired: #{paired}")

            CommerceFront.Settings.PlacementGroupSalesDetail.changeset(
              %CommerceFront.Settings.PlacementGroupSalesDetail{},
              %{
                before: map.after,
                after: map.after - paired,
                amount: -paired,
                from_user_id: 0,
                to_user_id: map.to_user_id,
                remarks: "pairing bonus calculation|from sale-#{sale.id}",
                sales_id: 0,
                position: "right"
              }
            )
          else
            Logger.info("[team bonus] - after: #{map.after} - paired: #{paired}")

            CommerceFront.Settings.PlacementGroupSalesDetail.changeset(
              %CommerceFront.Settings.PlacementGroupSalesDetail{},
              %{
                before: map.after,
                after: map.after - paired,
                amount: -paired,
                from_user_id: 0,
                to_user_id: map.to_user_id,
                remarks: "pairing bonus calculation|from sale-#{sale.id}",
                sales_id: 0,
                position: "left"
              }
            )
          end
          |> Repo.insert()
        end)
        |> Multi.run(String.to_atom("gs_summary_#{summary.user_id}"), fn _repo, %{} ->
          CommerceFront.Settings.update_group_sales_summary(summary, changeset)
        end)
        |> Multi.run(String.to_atom("bonus_#{summary.user_id}"), fn _repo, %{} ->
          bonus = paired * 0.1

          user = summary.user |> Repo.preload(:rank)
          rank = user |> Map.get(:rank)

          matrix = [
            %{rank: "铜级套餐", cap: 100},
            %{rank: "银级套餐", cap: 500},
            %{rank: "金级套餐", cap: 1500}
          ]

          {{y, m, d}, _time} = NaiveDateTime.to_erl(sale.inserted_at)

          check =
            Repo.all(
              from(r in CommerceFront.Settings.Reward,
                where:
                  r.user_id == ^user.id and r.name == "team bonus" and
                    r.day == ^d and r.month == ^m and
                    r.year == ^y,
                select: r.amount
              )
            )
            |> Enum.sum()

          user_cap =
            matrix |> Enum.filter(&(&1.rank == rank.name)) |> List.first() |> Map.get(:cap)

          final_pay =
            if check <= user_cap do
              bonus
            else
              0
            end

          # todo: apply the reserve wallet

          # todo: when do reserve wallet, check the total sales, watever balance after payout, goes to reserve
          CommerceFront.Settings.create_reward(%{
            sales_id: sale.id,
            is_paid: false,
            remarks:
              "sales-#{sale.id}|#{paired} * #{0.1} = #{bonus}|paid: #{check}|user_cap:#{user_cap}",
            name: "team bonus",
            amount: final_pay,
            user_id: map.to_user_id,
            day: d,
            month: m,
            year: y
          })
        end)
      else
        _ ->
          multi_query
      end
    end

    Enum.reduce(summaries, multi, &calc_for_parent.(&1, &2))
    |> Repo.transaction()
  end

  def daily_team_bonus(date) do
    multi = Multi.new()
    {y, m, d} = date |> Date.to_erl()

    summaries =
      Repo.all(
        from(gs in CommerceFront.Settings.GroupSalesSummary,
          where: gs.day == ^d and gs.month == ^m and gs.year == ^y,
          preload: :user
        )
      )

    calc_for_parent = fn map, multi_query ->
      summary = map

      {y2, m2, d2} = date |> Date.add(-1) |> Date.to_erl()

      prev_summary =
        Repo.all(
          from(gs in CommerceFront.Settings.GroupSalesSummary,
            where: gs.day == ^d2 and gs.month == ^m2 and gs.year == ^y2,
            where: gs.user_id == ^map.user_id,
            preload: :user
          )
        )
        |> List.first()

      last_pgsd =
        Repo.all(
          from(pgsd in CommerceFront.Settings.PlacementGroupSalesDetail,
            where: pgsd.gs_summary_id == ^map.id,
            order_by: [desc: pgsd.id]
          )
        )
        |> List.first()

      with true <- summary.total_left != nil,
           true <- summary.total_left != 0,
           true <- summary.total_right != nil,
           true <- summary.total_right != 0 do
        latest_gs =
          CommerceFront.Settings.get_latest_gs_summary_by_user_id(
            summary.user.id,
            Date.from_erl!({summary.year, summary.month, summary.day})
          )

        constant = summary.total_left / summary.total_right

        {paired, changeset} =
          cond do
            constant > 1 ->
              # this means, the left is more than right

              {summary.total_right,
               %{
                 balance_left: summary.total_left - summary.total_right,
                 balance_right: summary.total_right - summary.total_right
               }}

            constant == 1 ->
              # this means, the left is more than right

              {summary.total_right,
               %{
                 balance_left: 0,
                 balance_right: 0
               }}

            constant < 1 ->
              {summary.total_left,
               %{
                 balance_left: summary.total_left - summary.total_left,
                 balance_right: summary.total_right - summary.total_left
               }}
          end
          |> IO.inspect()

        # if date == ~D[2023-11-26] && summary.user.username == "damien" do

        # end

        multi_query
        |> Multi.run(String.to_atom("pgsd_left_#{summary.user_id}"), fn _repo, %{} ->
          if last_pgsd.position == "left" do
            Logger.info("[team bonus] - after: #{last_pgsd.after} - paired: #{paired}")

            CommerceFront.Settings.PlacementGroupSalesDetail.changeset(
              %CommerceFront.Settings.PlacementGroupSalesDetail{},
              %{
                before: last_pgsd.after,
                after: last_pgsd.after - paired,
                amount: -paired,
                from_user_id: 0,
                to_user_id: last_pgsd.to_user_id,
                remarks: "pairing bonus calculation|#{date}",
                sales_id: 0,
                position: "left"
              }
            )
          else
            Logger.info("[team bonus] - after: #{last_pgsd.after} - paired: #{paired}")

            CommerceFront.Settings.PlacementGroupSalesDetail.changeset(
              %CommerceFront.Settings.PlacementGroupSalesDetail{},
              %{
                before: last_pgsd.after,
                after: last_pgsd.after - paired,
                amount: -paired,
                from_user_id: 0,
                to_user_id: last_pgsd.to_user_id,
                remarks: "pairing bonus calculation|#{date}",
                sales_id: 0,
                position: "right"
              }
            )
          end
          |> Repo.insert()
        end)
        |> Multi.run(String.to_atom("pgsd_right_#{summary.user_id}"), fn _repo, %{} ->
          if last_pgsd.position == "left" do
            Logger.info("[team bonus] - after: #{last_pgsd.after} - paired: #{paired}")

            CommerceFront.Settings.PlacementGroupSalesDetail.changeset(
              %CommerceFront.Settings.PlacementGroupSalesDetail{},
              %{
                before: last_pgsd.after,
                after: last_pgsd.after - paired,
                amount: -paired,
                from_user_id: 0,
                to_user_id: last_pgsd.to_user_id,
                remarks: "pairing bonus calculation|#{date}",
                sales_id: 0,
                position: "right"
              }
            )
          else
            Logger.info("[team bonus] - after: #{last_pgsd.after} - paired: #{paired}")

            CommerceFront.Settings.PlacementGroupSalesDetail.changeset(
              %CommerceFront.Settings.PlacementGroupSalesDetail{},
              %{
                before: last_pgsd.after,
                after: last_pgsd.after - paired,
                amount: -paired,
                from_user_id: 0,
                to_user_id: last_pgsd.to_user_id,
                remarks: "pairing bonus calculation|#{date}",
                sales_id: 0,
                position: "left"
              }
            )
          end
          |> Repo.insert()
        end)
        |> Multi.run(String.to_atom("gs_summary_#{summary.user_id}"), fn _repo, %{} ->
          CommerceFront.Settings.update_group_sales_summary(summary, changeset)
        end)
        |> Multi.run(String.to_atom("bonus_#{summary.user_id}"), fn _repo, %{} ->
          bonus = paired * 0.1

          user = summary.user |> Repo.preload(:rank)
          rank = user |> Map.get(:rank)

          matrix = [
            %{rank: "铜级套餐", cap: 100},
            %{rank: "银级套餐", cap: 500},
            %{rank: "金级套餐", cap: 1500}
          ]

          {y, m, d} = date |> Date.to_erl()

          user_cap =
            matrix |> Enum.filter(&(&1.rank == rank.name)) |> List.first() |> Map.get(:cap)

          final_pay =
            if bonus <= user_cap do
              bonus |> Float.round(2)
            else
              user_cap
            end

          # todo: apply the reserve wallet
          # the downline total left right, will be the parent's total left\right
          # todo: when do reserve wallet, check the total sales, watever balance after payout, goes to reserve
          downlines =
            Repo.all(
              from(p in CommerceFront.Settings.Placement,
                where: p.parent_user_id == ^last_pgsd.to_user_id,
                preload: :user
              )
            )

          left_d =
            downlines
            |> Enum.filter(&(&1.position == "left"))
            |> List.first()
            |> Map.get(:user)

          right_d =
            downlines
            |> Enum.filter(&(&1.position == "right"))
            |> List.first()
            |> Map.get(:user)

          left_d_latest_gs =
            CommerceFront.Settings.get_latest_gs_summary_by_user_id(
              left_d.id,
              Date.from_erl!({y, m, d})
            )

          left_d_latest_gs =
            if left_d_latest_gs == nil do
              %{
                new_left: 0,
                new_right: 0,
                balance_left: 0,
                balance_right: 0,
                total_left: 0,
                total_right: 0
              }
            else
              left_d_latest_gs
            end

          right_d_latest_gs =
            CommerceFront.Settings.get_latest_gs_summary_by_user_id(
              right_d.id,
              Date.from_erl!({y, m, d})
            )

          right_d_latest_gs =
            if right_d_latest_gs == nil do
              %{
                new_left: 0,
                new_right: 0,
                balance_left: 0,
                balance_right: 0,
                total_left: 0,
                total_right: 0
              }
            else
              right_d_latest_gs
            end

          prev_summary =
            if prev_summary == nil do
              %{balance_left: 0, balance_right: 0, total_left: 0, total_right: 0}
            else
              prev_summary
            end

          CommerceFront.Settings.create_reward(%{
            sales_id: 0,
            is_paid: false,
            remarks:
              "#{date}|user_cap:#{user_cap}||left(#{left_d |> Map.get(:username)}):
            before: #{left_d_latest_gs.new_left + left_d_latest_gs.new_right} |+ c/f(#{map.user.username}) #{prev_summary.balance_left} = #{summary.total_left}, |matched: #{paired}, after: #{changeset.balance_left} ||right(#{right_d |> Map.get(:username)}):
            before: #{right_d_latest_gs.new_left + right_d_latest_gs.new_right} |+ c/f(#{map.user.username}) #{prev_summary.balance_right} = #{summary.total_right}, |matched: #{paired}, after: #{changeset.balance_right}||#{paired} * #{0.1} = #{bonus}|",
            name: "team bonus",
            amount: final_pay,
            user_id: last_pgsd.to_user_id,
            day: d,
            month: m,
            year: y
          })
        end)
      else
        _ ->
          multi_query
      end
    end

    Enum.reduce(summaries, multi, &calc_for_parent.(&1, &2))
    |> Multi.run(:reserve_wallet, fn _repo, %{} ->
      [%{date: _date, sum: today_sales_amount, total_pv: total_pv}] =
        case CommerceFront.Settings.today_sales(date) do
          [%{date: _date, sum: today_sales_amount, total_pv: total_pv}] ->
            [%{date: _date, sum: today_sales_amount, total_pv: total_pv}]

          _ ->
            [%{date: nil, sum: 0, total_pv: 0}]
        end

      [%{name: _name, sum: team_bonus_amount}] =
        case CommerceFront.Settings.today_bonus("team bonus", date) do
          [%{name: _name, sum: team_bonus_amount}] ->
            [%{name: _name, sum: team_bonus_amount}]

          _ ->
            [%{name: nil, sum: 0}]
        end

      allocated = total_pv * 0.4

      remainder = allocated - team_bonus_amount

      allocated =
        if allocated == 0 do
          "0.00"
        else
          allocated |> :erlang.float_to_binary(decimals: 2)
        end

      team_bonus_amount =
        if team_bonus_amount == 0 do
          "0.00"
        else
          team_bonus_amount |> :erlang.float_to_binary(decimals: 2)
        end

      res =
        CommerceFront.Settings.create_wallet_transaction(%{
          user_id: CommerceFront.Settings.finance_user().id,
          amount: remainder,
          remarks:
            "reserve for future team bonus payments #{date}|allocated_pv: #{allocated}|to_pay: #{team_bonus_amount}",
          wallet_type: "reserve"
        })

      # total sales 40% of pv is reserved to pay, anything remain after calculating the team bonus is added to reserve wallet
      {:ok, res}
    end)
    |> Repo.transaction()
  end

  @doc """
  this is a monthly calculated,
  but we can always rerun it everyday after running contribute group sales, pairing bonus
  this require to check every user's group sales summary on the total left right accumulated in that month
  """
  def matching_bonus(month, year) do
    date = Date.from_erl!({year, month, 1})

    subquery = """
    select
      u.username,
      r.user_id,
      sum(r.amount),
      r.month,
      r.year
    from
      rewards r
    left join users u on
      u.id = r.user_id
    where
      r.name = 'team bonus'
      and r.month = $1
      and r.year = $2
    group by
      u.username,
      r.user_id,
      r.month,
      r.year;
    """

    {:ok, %Postgrex.Result{columns: columns, rows: rows} = res} =
      Ecto.Adapters.SQL.query(Repo, subquery, [month, year])

    team_bonuses =
      for row <- rows do
        Enum.zip(columns |> Enum.map(&(&1 |> String.to_atom())), row) |> Enum.into(%{})
      end

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

    unpaid_node = unpaid_node()

    users_weak_leg =
      for row <- rows do
        Enum.zip(columns |> Enum.map(&(&1 |> String.to_atom())), row) |> Enum.into(%{})
      end
      |> List.insert_at(0, %{
        left: 1501,
        right: 1500,
        user_id: unpaid_node.parent_id,
        username: unpaid_node.parent
      })

    Repo.delete_all(
      from(r in Reward,
        where: r.name == ^"matching bonus" and r.month == ^month and r.year == ^year
      )
    )

    users = Repo.all(from(u in User, order_by: [desc: u.id]))

    Multi.new()
    |> Multi.run(:calculation, fn _repo, %{} ->
      for user <- users do
        uplines =
          Settings.check_uplines(user.username, :referal)
          |> Enum.reverse()
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> Enum.reverse()

        # check user has team bonus

        check = team_bonuses |> Enum.filter(&(&1.user_id == user.id)) |> List.first()

        calc = fn upline, index ->
          weak_leg =
            users_weak_leg |> Enum.filter(&(&1.user_id == upline.parent_id)) |> List.first()

          if weak_leg != nil do
            weak_amount =
              if weak_leg.left > weak_leg.right do
                weak_leg.right
              else
                weak_leg.left
              end

            matrix = [
              %{amount: 500, l1: 0.1},
              %{amount: 1000, l1: 0.1, l2: 0.1},
              %{amount: 1500, l1: 0.1, l2: 0.1, l3: 0.1}
            ]

            map = Enum.filter(matrix, &(&1.amount <= weak_amount)) |> List.last()

            if map != nil do
              if index < 4 do
                constant =
                  case index do
                    1 ->
                      map |> Map.get(:l1, 0)

                    2 ->
                      map |> Map.get(:l2, 0)

                    3 ->
                      map |> Map.get(:l3, 0)

                    _ ->
                      0
                  end

                bonus = check.sum * constant

                CommerceFront.Settings.create_reward(%{
                  sales_id: 0,
                  is_paid: false,
                  remarks:
                    "#{check.sum |> :erlang.float_to_binary(decimals: 2)} * #{constant} = #{bonus}||lvl:#{index}||#{user.username} team bonus at #{month}-#{year}: #{check.sum |> :erlang.float_to_binary(decimals: 2)}||#{weak_leg.username} leg: #{weak_leg.left} vs #{weak_leg.right}",
                  name: "matching bonus",
                  amount: bonus |> Float.round(2),
                  user_id: upline.parent_id,
                  day: Timex.end_of_month(date).day,
                  month: month,
                  year: year
                })
              end

              index + 1
            else
              index
            end
          else
            index
          end

          # check upline's weak leg
        end

        if check != nil do
          Enum.reduce(uplines, 1, &calc.(&1, &2))
        end
      end

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  @doc """
  D）Elite Leader CTO sharing 5%
  Ever month weak team pv achieved
  1,500PV-1star-1%
  3,000PV-2stars-1%+1%
  10,000PV-3stars-1%+1%+1%
  30,000PV-4stars-1%+1%+1%+1%
  50,000PV-5stars-1%+1%+1%+1%+1%


  each weak leg will be given 1% from current month sales PV

  """

  def elite_leader(month, year) do
    date = Date.from_erl!({year, month, 1})

    subquery = """

    select sum(s.total_point_value) from sales s where s.status not in ('cancelled', 'refund', 'pending_payment')  and s.month = $1 and s.year = $2 group by s.month , s.year;
    """

    {:ok, %Postgrex.Result{columns: columns, rows: rows} = res} =
      Ecto.Adapters.SQL.query(Repo, subquery, [month, year])

    monthly_sales =
      for row <- rows do
        Enum.zip(columns |> Enum.map(&(&1 |> String.to_atom())), row) |> Enum.into(%{})
      end
      |> List.first()
      |> IO.inspect()

    Repo.delete_all(
      from(r in Reward,
        where: r.name == ^"elite leader" and r.month == ^month and r.year == ^year
      )
    )

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

    unpaid_node = unpaid_node()

    users_weak_leg =
      for row <- rows do
        Enum.zip(columns |> Enum.map(&(&1 |> String.to_atom())), row) |> Enum.into(%{})
      end
      |> List.insert_at(0, %{
        left: 50001,
        right: 50000,
        user_id: unpaid_node.parent_id,
        username: unpaid_node.parent
      })

    Repo.delete_all(
      from(r in Reward,
        where: r.name == ^"elite leader" and r.month == ^month and r.year == ^year
      )
    )

    Multi.new()
    |> Multi.run(:calculation, fn _repo, %{} ->
      total_sales_pv = monthly_sales.sum
      # 8k

      # 1star pool = 8k * 0.01  ?

      matrix = [
        %{name: "1star", qualify: 1500},
        %{name: "2star", qualify: 3000},
        %{name: "3star", qualify: 10000},
        %{name: "4star", qualify: 30000},
        %{name: "5star", qualify: 50000}
      ]

      for %{name: star_name, qualify: amount} = star <- matrix do
        one_star_qualifier =
          for weak_leg <- users_weak_leg do
            weak_amount =
              if weak_leg.left > weak_leg.right do
                weak_leg.right
              else
                weak_leg.left
              end

            if weak_amount >= amount do
              weak_leg
            else
              nil
            end
          end
          |> Enum.reject(&(&1 == nil))

        count = Enum.count(one_star_qualifier)

        if count > 0 do
          one_star_amount = total_sales_pv * 0.01 / count

          for weak_leg <- one_star_qualifier do
            weak_amount =
              if weak_leg.left > weak_leg.right do
                weak_leg.right
              else
                weak_leg.left
              end

            CommerceFront.Settings.create_reward(%{
              sales_id: 0,
              is_paid: false,
              remarks:
                "#{total_sales_pv} * 0.01/ #{count} = #{one_star_amount |> :erlang.float_to_binary(decimals: 2)}|weak_leg: #{weak_amount}|pool qualifiers: #{count}|#{star_name}",
              name: "elite leader",
              amount: one_star_amount |> Float.round(2),
              user_id: weak_leg.user_id,
              day: Timex.end_of_month(date).day,
              month: month,
              year: year
            })
          end
        end
      end

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  @doc """

  the weak leg points needs to be compressed,
  like damien weak leg has 7600, after minus the 5000 for 6 points,
  the remaining 2600 also need to calculate how many points, like minus another 1500 to get 1 point


  12000

  5000 - 6

  5000 - 6

  2000 - 1

  the remaning 500 is burn off

  """

  def travel_fund(month, year) do
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

    matrix = [
      %{point: 1, amount: 1500},
      %{point: 3, amount: 3000},
      %{point: 6, amount: 5000}
    ]

    Repo.delete_all(
      from(r in Reward,
        where: r.name == ^"travel fund" and r.month == ^month and r.year == ^year
      )
    )

    Multi.new()
    |> Multi.run(:calculation, fn _repo, %{} ->
      travel_qualifier =
        for weak_leg <- users_weak_leg do
          # assuming this weak amount is 7600,
          # after
          weak_amount =
            if weak_leg.left > weak_leg.right do
              weak_leg.right
            else
              weak_leg.left
            end

          calc_fn = fn {n, rewardList} ->
            map = Enum.filter(matrix, &(&1.amount <= n)) |> List.last()

            if n != nil && map != nil do
              balance = n - map.amount

              {:ok, reward} =
                CommerceFront.Settings.create_reward(%{
                  sales_id: 0,
                  is_paid: false,
                  remarks:
                    "#{weak_leg.username} leg: #{weak_leg.left}|#{weak_leg.right}|deduct from: #{n} - #{map.amount}",
                  name: "travel fund",
                  amount: map.point,
                  user_id: weak_leg.user_id,
                  day: Timex.end_of_month(date).day,
                  month: month,
                  year: year
                })

              {balance, List.insert_at(rewardList, 0, reward)}
            else
              0
            end
          end

          Stream.unfold({weak_amount, []}, fn
            0 -> nil
            n -> {n, calc_fn.(n)}
          end)
          |> Enum.to_list()
          |> List.last()
        end

      {:ok, travel_qualifier}
    end)
    |> Multi.run(:update_shares, fn _repo, %{calculation: calculation} ->
      month_pv =
        CommerceFront.Settings.this_month_sales(end_date)
        |> Enum.map(& &1.total_pv)
        |> Enum.sum()

      allocated = month_pv * 0.05

      check =
        CommerceFront.Settings.today_bonus("travel fund", end_date)
        |> List.first()

      if check != nil do
        all_member_travel_fund =
          check
          |> Map.get(:sum)

        per_share_value = (allocated / all_member_travel_fund) |> Float.round(2)

        rewards =
          calculation
          |> Enum.filter(&(&1 |> elem(0) > 0))
          |> Enum.map(&(&1 |> elem(1)))
          |> List.flatten()

        for reward <- rewards do
          amount = per_share_value * reward.amount

          params = %{
            amount: amount,
            remarks:
              reward.remarks <>
                "|no shares: #{reward.amount}|month allocated: #{allocated}|per share: #{per_share_value}"
          }

          CommerceFront.Settings.update_reward(reward, params)
        end
      else
        0
      end

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  @doc """

  month end calculate, because, after daily payout,
  there's 10% deducted until BP1000,
  will put a note for
  month nov 23' - product wallet points 1000
  month dec 23' - product wallet points 1000
  month jan 24' - product wallet points 1000

  will compress upline to 20 levels for those qualify 500PV weak leg monthly
  the user's product wallet point * 0.025


  """
  def repurchase_bonus(month, year) do
    date = Date.from_erl!({year, month, 1})

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

    unpaid_node = unpaid_node()

    users_weak_leg =
      for row <- rows do
        Enum.zip(columns |> Enum.map(&(&1 |> String.to_atom())), row) |> Enum.into(%{})
      end
      |> List.insert_at(0, %{
        left: 501,
        right: 500,
        user_id: unpaid_node.parent_id,
        username: unpaid_node.parent
      })

    Repo.delete_all(
      from(r in Reward,
        where: r.name == ^"repurchase bonus" and r.month == ^month and r.year == ^year
      )
    )

    # if upline have 500 pv only pay, else compress..
    {y, m, d} =
      date
      |> Date.to_erl()

    datetime = NaiveDateTime.from_erl!({{y, m, d}, {0, 0, 0}})
    end_datetime = datetime |> Timex.shift(months: 1)

    users_monthly_product_wallet_entries =
      from(wt in CommerceFront.Settings.WalletTransaction,
        left_join: ew in CommerceFront.Settings.Ewallet,
        on: ew.id == wt.ewallet_id,
        left_join: u in CommerceFront.Settings.User,
        on: u.id == ew.user_id,
        where: ew.wallet_type == ^:product,
        where: u.username != "haho_unpaid",
        where: wt.amount > 0.0,
        where: wt.inserted_at > ^datetime and wt.inserted_at < ^end_datetime,
        group_by: [ew.user_id, u.username],
        select: %{
          username: u.username,
          user_id: ew.user_id,
          sum: sum(wt.amount)
        },
        having: sum(wt.amount) > 0,
        order_by: [ew.user_id]
      )
      |> Repo.all()

    Multi.new()
    |> Multi.run(:calculation, fn _repo, %{} ->
      for %{sum: sum, user_id: user_id, username: username} = user_product_wallet <-
            users_monthly_product_wallet_entries do
        uplines =
          CommerceFront.Settings.check_uplines(username, :referal)
          |> Enum.reverse()
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> List.insert_at(0, unpaid_node)
          |> Enum.reverse()
          |> Enum.with_index(1)

        IO.inspect("checking upline for #{username}")

        calc_fn = fn {upline, index}, initial_index ->
          weak_leg =
            Enum.filter(
              users_weak_leg,
              &(&1.user_id ==
                  upline.parent_id)
            )
            |> List.first()

          if weak_leg != nil do
            # assuming this weak amount is 7600,
            # after
            weak_amount =
              if weak_leg.left > weak_leg.right do
                weak_leg.right
              else
                weak_leg.left
              end

            IO.inspect(
              "index: #{initial_index} , parent #{upline.parent} weak amount = #{weak_amount}"
            )

            if initial_index < 22 && weak_amount >= 500 do
              p = %{
                sales_id: 0,
                is_paid: false,
                remarks:
                  "#{weak_leg.username} leg: #{weak_leg.left}|#{weak_leg.right}|#{username}'s auto deduct sum: #{sum} * 0.025| level: #{initial_index + 1}",
                name: "repurchase bonus",
                amount: (sum * 0.025) |> Float.round(2),
                user_id: weak_leg.user_id,
                day: Timex.end_of_month(date).day,
                month: month,
                year: year
              }

              CommerceFront.Settings.create_reward(p)

              initial_index + 1
            else
              initial_index
            end
          else
            initial_index
          end
        end

        Enum.reduce(uplines, 0, &calc_fn.(&1, &2))
      end

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  @doc """

  if drp_amount  = 250
  250 * 0.01 = 2.5
  to 10 uplines, compress upline

  6/12/23
  ---
  bromze g1 2%


  CommerceFront.Calculation.drp_sales_level_bonus(132, 81, CommerceFront.Settings.get_user_by_username("freddy3"), ~D[2024-05-31])

  16/07

  should use remaining RP aka deducted DRP, the remaining RP used for calculation.

  """
  def drp_sales_level_bonus(sales_id, drp_amount, child_user, date) do
    {y, m, d} = date |> Date.to_erl()

    uplines =
      CommerceFront.Settings.check_uplines(child_user.username, :referal)
      |> Enum.reverse()
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> List.insert_at(0, unpaid_node)
      |> Enum.reverse()

    calc_fn = fn upline, index ->
      if index <= 5 && index > 0 do
        matrix = [
          %{rank: "铜级套餐", l1: 0.02, calculated: false},
          %{rank: "银级套餐", l1: 0.02, l2: 0.02, l3: 0.02, calculated: false},
          %{rank: "金级套餐", l1: 0.02, l2: 0.02, l3: 0.02, l4: 0.02, l5: 0.02, calculated: false}
        ]

        cur_level =
          matrix |> Enum.filter(&(&1.rank == upline.rank)) |> List.first() |> IO.inspect()

        perc =
          if cur_level != nil do
            case index do
              1 ->
                cur_level |> Map.get(:l1, 0.0)

              2 ->
                cur_level |> Map.get(:l2, 0.0)

              3 ->
                cur_level |> Map.get(:l3, 0.0)

              4 ->
                cur_level |> Map.get(:l4, 0.0)

              5 ->
                cur_level |> Map.get(:l5, 0.0)

              _ ->
                0.0
            end
          else
            0
          end

        amount = drp_amount * perc

        amount =
          if amount > 0 do
            amount |> Float.round(2)
          else
            amount
          end

        if amount > 0 do
          p = %{
            sales_id: sales_id,
            is_paid: false,
            remarks:
              "#{drp_amount} * #{perc} = #{amount}|level: #{index}| #{upline.parent} rank: #{upline.rank}",
            name: "drp sales level bonus",
            amount: amount,
            user_id: upline.parent_id,
            day: d,
            month: m,
            year: y
          }

          CommerceFront.Settings.create_reward(p)
          index + 1
        else
          index
        end
      else
        if index == 0 do
          index + 1
        else
          index
        end
      end
    end

    Enum.reduce(uplines, 0, &calc_fn.(&1, &2))
  end
end
