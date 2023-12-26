defmodule CommerceFrontWeb.ApiController do
  use CommerceFrontWeb, :controller

  alias CommerceFront.{Repo, Settings}

  def stream_get(conn, params) do
    final =
      case params["scope"] do
        _ ->
          rest_id = Map.get(params, "rest_id", 1)
          pid = Process.whereis(String.to_atom("rest_#{rest_id}"))

          if pid == nil do
            {:ok, pid} = Agent.start_link(fn -> [] end)
            Process.register(pid, String.to_atom("rest_#{rest_id}"))
          else
            IO.inspect("pid rest_#{rest_id} already exist")
          end

          %{status: "received"}
      end

    conn =
      conn
      |> put_resp_content_type("application/json")
      |> send_chunked(200)

    Enum.reduce_while(
      Stream.iterate(
        "",
        fn x ->
          Process.sleep(2000)
          CommerceFront.get_order() |> Jason.encode!()
        end
      ),
      conn,
      fn chunk, conn ->
        IO.inspect(chunk)

        case Plug.Conn.chunk(conn, chunk) do
          {:ok, conn} ->
            {:cont, conn}

          {:error, :closed} ->
            {:halt, conn}
        end
      end
    )
  end

  def decode_token(token) do
    Settings.decode_token(token)
  end

  def csrf(conn, params) do
    json(conn, Phoenix.Controller.get_csrf_token())
  end

  require IEx

  def get(conn, params) do
    # can get data from conn.private.plug_session
    token = params |> Map.get("token")

    %{id: id} =
      with true <- token != nil,
           decoded <- token |> decode_token,
           true <- decoded != nil do
        decoded
      else
        _ ->
          %{id: 0}
      end

    res =
      case params["scope"] do
        "translation" ->
          translation = CommerceFront.translation()

          ori = translation |> Enum.map(&(&1 |> Map.get("Ori")))
          eng = translation |> Enum.map(&(&1 |> Map.get("English")))
          thai = translation |> Enum.map(&(&1 |> Map.get("Thailand")))
          chinese = translation |> Enum.map(&(&1 |> Map.get("China")))
          viet = translation |> Enum.map(&(&1 |> Map.get("Vietnam")))

          translation_map =
            case params["lang"] do
              "th" ->
                Enum.zip(ori, thai) |> Enum.into(%{})

              "vn" ->
                Enum.zip(ori, viet) |> Enum.into(%{})

              "cn" ->
                Enum.zip(ori, chinese) |> Enum.into(%{})

              _ ->
                Enum.zip(ori, eng) |> Enum.into(%{})
            end

        "get_product_countries" ->
          Settings.get_product!(params["id"]) |> BluePotion.sanitize_struct()

        "get_role_app_routes" ->
          Settings.get_role!(params["id"]) |> BluePotion.sanitize_struct()

        "list_pick_up_point_by_country" ->
          Settings.list_pick_up_point_by_country(params["country_id"])
          |> Enum.map(&(&1 |> BluePotion.sanitize_struct()))

        "list_user_sales_addresses_by_username" ->
          Settings.list_user_sales_addresses_by_username(params["username"])
          |> Enum.map(&(&1 |> BluePotion.sanitize_struct()))

        "countries" ->
          Settings.list_countries()
          |> Enum.map(&(&1 |> BluePotion.sanitize_struct()))

        "yearly_sales_performance" ->
          Settings.yearly_sales_performance()

        "royalty_bonus" ->
          Settings.royalty_bonus(params["date"])

        "get_accumulated_sales" ->
          user = Settings.get_user_by_username(params["username"])

          if params["parent_id"] != nil do
            # check = Settings.verify_parent(String.to_integer(params["parent_id"]), user)

            # if check do
            # else
            #   %{status: "error", reason: "not your downline"}
            # end
            Settings.accumulated_sales_by_user(user, params["show_rank"])
          else
            Settings.accumulated_sales(params["username"])
          end

        "unpaid_reward_summary" ->
          Settings.group_unpay_rewards()

        "get_cookie_user" ->
          Settings.get_cookie_user_by_cookie(params["cookie"]) |> BluePotion.sanitize_struct()

        "delete_topup_request" ->
          wt = Settings.get_wallet_topup!(params["id"]) |> CommerceFront.Repo.preload(:payment)

          if wt.is_approved == false do
            wt.payment |> CommerceFront.Repo.delete()
            {:ok, ww} = wt |> CommerceFront.Repo.delete()

            ww |> BluePotion.sanitize_struct()
          else
            %{status: :error, reason: "Already approved"}
          end

        "delete_request" ->
          {:ok, ww} = Settings.delete_wallet_withdrawal_by_id(params["id"])
          ww |> BluePotion.sanitize_struct()

        "get_reward_summary" ->
          Settings.user_monthly_reward_summary(params["user_id"], params["is_prev"])

        "get_sale" ->
          Settings.get_sale!(params["id"])
          |> BluePotion.sanitize_struct()

        "get_sales_items" ->
          Settings.get_sale!(params["id"])
          |> Map.get(:sales_items)
          |> BluePotion.sanitize_struct()

        "user_wallet" ->
          res =
            Settings.list_ewallets_by_user_id(id)
            |> Enum.map(&(&1 |> BluePotion.sanitize_struct()))

        "get_product" ->
          Settings.get_product!(params["id"]) |> BluePotion.sanitize_struct()

        "announcements" ->
          Settings.list_announcements() |> Enum.map(&(&1 |> BluePotion.sanitize_struct()))

        "check_bill" ->
          res =
            Billplz.get_bill(params["id"])
            |> IO.inspect()

          payment =
            Settings.get_payment_by_billplz_code(params["id"])
            |> IO.inspect()

          with true <- Map.get(res, "paid", false) == true,
               true <- payment != nil,
               true <- payment.sales != nil,
               sales <- payment.sales |> IO.inspect(),
               {:ok, register_params} <-
                 sales.registration_details |> Jason.decode() |> IO.inspect() do
            case Settings.register(register_params["user"], sales) do
              {:ok, multi_res} ->
                %{status: "ok", res: multi_res |> BluePotion.sanitize_struct()}

              _ ->
                %{status: "error"}
            end
          else
            _ ->
              with true <- payment != nil,
                   true <- payment.wallet_topup != nil do
                case Settings.approve_topup(%{"id" => payment.wallet_topup.id}) do
                  {:ok, tp} ->
                    %{status: "ok", res: tp |> BluePotion.sanitize_struct()}

                  _ ->
                    %{status: "error"}
                end
              else
                _ ->
                  %{status: "error"}
              end
          end

          res

        "node" ->
          if params["token"] != nil do
            if params["username"] == "damien" do
              %{
                icon: "fa fa-user text-success",
                id: "root",
                text: "root",
                children: [
                  %{id: "root1", text: "root1", children: true, icon: "fa fa-user"}
                ],
                type: "root"
              }
            else
              []
            end

            Settings.display_refer_tree(params["username"])
          else
            []
          end

        "get_ranks" ->
          Settings.list_ranks() |> Enum.map(&(&1 |> BluePotion.sanitize_struct()))

        "placement" ->
          Settings.display_place_tree(params["username"], params["full"])

        "referral" ->
          Settings.display_refer_tree(params["username"])

        "get_share_link" ->
          Settings.generate_link(params)

        "gen_inputs" ->
          BluePotion.test_module(params["module"])

        _ ->
          %{status: "ok"}
      end

    append_cache_request = fn conn ->
      if Map.get(conn.params, "scope") in [
           "countries",
           "get_ranks",
           "list_pick_up_point_by_country",
           "list_user_sales_addresses_by_username"
           # "translation"
         ] do
        conn
        |> put_resp_header("cache-control", "max-age=900, must-revalidate")
      else
        conn
      end
    end

    with true <- is_map(res),
         true <- Map.get(res, :status) == "error" do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(500, Jason.encode!(res))
    else
      _ ->
        conn
        |> append_cache_request.()
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(res))
    end
  end

  def payment(conn, params) do
    payment = Settings.get_payment_by_billplz_code(params["id"])

    res =
      with true <- params["paid"] == "true",
           true <- payment != nil,
           true <- payment.sales != nil,
           sales <- payment.sales,
           {:ok, register_params} <- sales.registration_details |> Jason.decode() do
        case Settings.register(register_params["user"], sales) do
          {:ok, multi_res} ->
            %{status: "ok", res: multi_res |> BluePotion.sanitize_struct()}

          _ ->
            %{status: "error"}
        end
      else
        _ ->
          with true <- payment.wallet_topup != nil do
            case Settings.approve_topup(%{"id" => payment.wallet_topup.id}) do
              {:ok, tp} ->
                %{status: "ok", res: tp |> BluePotion.sanitize_struct()}

              _ ->
                %{status: "error"}
            end
          else
            _ ->
              %{status: "ok"}
          end
      end

    sample = %{
      "amount" => "500000",
      "collection_id" => "greljvdq",
      "due_at" => "2023-11-18",
      "email" => "a@1.com",
      "id" => "ywkq6y7x",
      "mobile" => "",
      "name" => "1",
      "paid" => "true",
      "paid_amount" => "500000",
      "paid_at" => "2023-11-18 16:16:29 +0800",
      "state" => "paid",
      "url" => "https://www.billplz-sandbox.com/bills/ywkq6y7x",
      "x_signature" => "20fe8afe691277badffd74ad3bbeaafe6f54b5c502ed91bd557b88678338b627"
    }

    json(conn, res)
  end

  def post(conn, params) do
    res =
      case params["scope"] do
        "do_adjustment" ->
          Settings.approve_adjustment(params)
          %{status: "ok"}

        "admin_menus" ->
          params["list"] |> Settings.update_admin_menus()

          %{status: "ok"}

        "admin_modify_referral" ->
          CommerceFront.Settings.change_referral(
            params["username"],
            params["to_new_placement_username"]
          )

          %{status: "ok"}

        "admin_modify_placement" ->
          CommerceFront.Settings.change_placement(
            params["username"],
            params["to_new_placement_username"],
            params["position"]
          )

          %{status: "ok"}

        "admin_insert_wallet_trx" ->
          sample = %{user_id: 609, amount: 1100.00, remarks: "something", wallet_type: "register"}
          ewallet = CommerceFront.Settings.get_ewallet!(params["ewallet_id"]) |> IO.inspect()

          nparams =
            params
            |> Map.put("amount", params["amount"] |> Float.parse() |> elem(0))
            |> Map.merge(%{"user_id" => ewallet.user_id, "wallet_type" => ewallet.wallet_type})
            |> Enum.reduce(%{}, fn {key, value}, acc ->
              acc |> Map.put(String.to_atom(key), value)
            end)

          CommerceFront.Settings.create_wallet_transaction(nparams)

          %{status: "ok"}

        "admin_register_member" ->
          sample = %{
            "scope" => "admin_register_member",
            "user" => %{
              "email" => "888@1.com",
              "fullname" => "w2",
              "password" => "[FILTERED]",
              "phone" => "888",
              "placement" => %{"position" => "left"},
              "sponsor" => "wer1",
              "username" => "wer2"
            }
          }

          case Settings.register_without_products(params["user"]) do
            {:ok, multi_res} ->
              %{status: "ok"}

            {:error, _model, changeset, succeeded} ->
              errors = changeset.errors |> Keyword.keys()

              {reason, message} = changeset.errors |> hd()
              {proper_message, message_list} = message
              final_reason = Atom.to_string(reason) <> " " <> proper_message
              %{status: "error", reason: final_reason}
          end

        "mark_do" ->
          sale = Settings.get_sale!(params["id"]) |> IO.inspect()

          cond do
            sale.status == :processing && params["status"] == "pending_delivery" ->
              Settings.update_sale(sale, %{status: params["status"]})
              %{status: "ok"}

            sale.status == :pending_delivery && params["status"] == "sent" ->
              Settings.mark_sent(params, sale)

              %{status: "ok"}

            true ->
              nil
              %{status: "error", reason: "already updated to #{params["status"]}"}
          end

        # params["status"]

        "pay_reward" ->
          Settings.pay_unpaid_bonus(
            Date.from_erl!({params["year"], params["month"], params["day"]}),
            [params["name"]]
          )

          %{status: "ok"}

        "transfer_wallet" ->
          sample = %{
            "_csrf_token" => "Cw1XLQAKA3NeCHYCARBvKGo3WTkmGBN5ic4u_mF9mcEvRO8YSG0kkK_7",
            "convert" => %{"user_id" => "583"},
            "scope" => "transfer_wallet",
            "transfer" => %{"amount" => "100.00", "username" => "summer"}
          }

          Settings.transfer_wallet(
            params["transfer"]["user_id"],
            params["transfer"]["username"],
            Float.parse(params["transfer"]["amount"]) |> elem(0)
          )

        "convert_wallet" ->
          Settings.convert_wallet(
            params["convert"]["user_id"],
            Float.parse(params["convert"]["amount"]) |> elem(0)
          )

        "approve_withdrawal_batch" ->
          params["id"]
          |> Settings.approve_withdrawal_batch()
          |> case do
            {:ok, _res} ->
              %{status: "ok"}

            {:error, "already paid"} ->
              %{status: "error", reason: "already paid"}

            _ ->
              %{status: "error"}
          end

        "approve_topup" ->
          case Settings.approve_topup(params) do
            {:ok, multi_res} ->
              %{status: "ok"}

            {:error, "already approved"} ->
              %{status: "error", reason: "already approved"}

            _ ->
              %{status: "error", reason: "unknown"}
          end

        "manual_approve_fpx" ->
          with payment <-
                 Settings.get_payment_by_billplz_code(params["id"]),
               true <- payment != nil,
               true <- payment.sales != nil,
               sales <- payment.sales,
               {:ok, register_params} <- sales.registration_details |> Jason.decode() do
            case Settings.register(register_params["user"], sales) do
              {:ok, multi_res} ->
                %{status: "ok", res: multi_res |> BluePotion.sanitize_struct()}

              _ ->
                %{status: "error"}
            end
          else
            _ ->
              %{status: "ok"}
          end

        "sign_in" ->
          # admin login
          res = Settings.check_staff_password(params)

          case res do
            {true, user} ->
              token =
                Phoenix.Token.sign(
                  CommerceFrontWeb.Endpoint,
                  "admin_signature",
                  params["username"]
                )

              Settings.create_session_user(%{"cookie" => token, "user_id" => user.id})

              %{
                id: user.id,
                status: "ok",
                res: token,
                role_app_routes:
                  user.role.app_routes |> Enum.map(&(&1 |> BluePotion.sanitize_struct()))
              }

            {false, _res} ->
              %{status: "error", reason: "Invalid credentials"}
          end

        "topup" ->
          case Settings.create_topup_transaction(params) do
            {:ok, multi_res} ->
              %{status: "ok", res: multi_res.payment |> BluePotion.sanitize_struct()}

            _ ->
              %{status: "error"}
          end

        "redeem" ->
          # get the billplz link first, then make payment
          # create the sales first
          # Settings.register(params["user"])

          case Settings.create_sales_transaction(params) |> IO.inspect() do
            {:ok, multi_res} ->
              %{status: "ok", res: multi_res.payment |> BluePotion.sanitize_struct()}

            {:error, "Please check cart items."} ->
              %{status: "error", reason: "Please check cart items."}

            {:error, :payment, "not sufficient", passed_cg} ->
              %{status: "error", reason: "wallet balance not sufficient"}

            _ ->
              %{status: "error"}
          end

        "upgrade" ->
          # get the billplz link first, then make payment
          # create the sales first
          # Settings.register(params["user"])

          sales_person = Settings.get_user!(params["user"]["sales_person_id"])

          with true <-
                 params["user"]["upgrade"] == "" ||
                   params["user"]["upgrade"] == sales_person.username,
               true <- params["user"]["payment"]["method"] == "register_point" do
            %{status: "error", reason: "Cannot use DRP on self."}
          else
            _ ->
              case Settings.create_sales_transaction(params) |> IO.inspect() do
                {:ok, multi_res} ->
                  %{
                    status: "ok",
                    res: multi_res.payment |> Map.delete(:user) |> BluePotion.sanitize_struct()
                  }

                {:error, "Please check cart items."} ->
                  %{status: "error", reason: "Please check cart items."}

                {:error, :payment, "not sufficient", passed_cg} ->
                  %{status: "error", reason: "wallet balance not sufficient"}

                _ ->
                  %{status: "error"}
              end
          end

        "link_register" ->
          # get the billplz link first, then make payment
          # create the sales first
          # Settings.register(params["user"])
          case Settings.create_sales_transaction(params) |> IO.inspect() do
            {:ok, multi_res} ->
              %{status: "ok", res: multi_res.payment |> BluePotion.sanitize_struct()}

            {:error, :payment, "not sufficient", passed_cg} ->
              %{status: "error", reason: "wallet balance not sufficient"}

            {:error, "Please enter a password."} ->
              %{status: "error", reason: "Please enter a password."}

            {:error, "Please check cart items."} ->
              %{status: "error", reason: "Please check cart items."}

            {:error, "Sponsor cannot be Shopper to register new member."} ->
              %{status: "error", reason: "sponsor cannot be Shopper to register new member."}

            _ ->
              %{status: "error", reason: "Please contact admin."}
          end

        "register" ->
          # get the billplz link first, then make payment
          # create the sales first
          # Settings.register(params["user"])
          case Settings.create_sales_transaction(params) |> IO.inspect() do
            {:ok, multi_res} ->
              %{status: "ok", res: multi_res.payment |> BluePotion.sanitize_struct()}

            {:error, :payment, "not sufficient", passed_cg} ->
              %{status: "error", reason: "wallet balance not sufficient"}

            {:error, "Please enter a password."} ->
              %{status: "error", reason: "Please enter a password."}

            {:error, "Please check cart items."} ->
              %{status: "error", reason: "Please check cart items."}

            {:error, "Sponsor cannot be Shopper to register new member."} ->
              %{status: "error", reason: "sponsor cannot be Shopper to register new member."}

            _ ->
              %{status: "error", reason: "Please contact admin."}
          end

        "login" ->
          auth = Settings.auth_user(params["user"]) |> IO.inspect()

          case auth do
            {:ok, user} ->
              %{
                status: "ok",
                res:
                  user
                  |> BluePotion.sanitize_struct()
                  |> Map.put(:token, Settings.member_token(user.id))
              }

            _ ->
              %{status: "error"}
          end

        _ ->
          %{status: "ok"}
      end

    append_session = fn conn ->
      # conn |> put_session(:test_session, %{id: 1, role: "tester"})
      conn
    end

    conn
    |> append_session.()
    |> json(res)
  end

  def print_pdf(conn, params) do
    check = File.exists?(File.cwd!() <> "/media")
    filename = params["filename"]

    path =
      if check do
        File.cwd!() <> "/media"
      else
        File.mkdir(File.cwd!() <> "/media")
        File.cwd!() <> "/media"
      end

    server_url = Application.get_env(:commerce_front, :endpoint)[:url]
    IO.inspect(server_url)

    {:ok, html} = File.read("#{path}/#{filename}.html")

    html =
      html
      |> String.replace("\"/images", "\"#{server_url}/images")
      |> String.replace("\'/images", "\'#{server_url}/images")

    host = conn.req_headers |> Enum.into(%{}) |> Map.get("host")

    css = """

    <link rel="stylesheet" type="text/css" href="#{server_url}/sticky/styles/bootstrap.css">
    <link rel="stylesheet" type="text/css" href="#{server_url}/sticky/styles/style.css">
    """

    pdf_params = %{
      "html" => "<!DOCTYPE html><html><head>#{css}</head><body>#{html}</body></html>"
    }

    # pdf_params = %{"html" => html}
    IO.inspect(pdf_params)
    IO.puts(pdf_params["html"])

    pdf_binary =
      PdfGenerator.generate_binary!(
        pdf_params["html"],
        size: "A4",
        shell_params: [
          "--page-width",
          "100cm",
          "--margin-left",
          "5",
          "--margin-right",
          "5",
          "--margin-top",
          "5",
          "--margin-bottom",
          "5",
          "--encoding",
          "utf-8",
          "--orientation",
          "Portrait"
        ],
        delete_temporary: true
      )

    conn
    |> put_resp_content_type("application/pdf")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"#{params["title"]}.pdf\""
    )
    |> send_resp(200, pdf_binary)
  end

  def append_params(params) do
    parent_id = Map.get(params, "parent_id")

    params =
      if parent_id != nil do
        params
        |> Map.put(
          "parent_id",
          CommerceFront.Settings.decode_corporate_account_token(parent_id).id
        )
      else
        params
      end

    password = Map.get(params, "password")

    params =
      if password != nil do
        crypted_password = :crypto.hash(:sha512, password) |> Base.encode16() |> String.downcase()

        params
        |> Map.put(
          "crypted_password",
          crypted_password
        )
      else
        params
      end

    IO.inspect("appended")
    IO.inspect(params)

    params
  end

  def form_submission(conn, params) do
    model = Map.get(params, "model")
    params = Map.delete(params, "model")

    upcase? = fn x -> x == String.upcase(x) end

    sanitized_model =
      model
      |> String.split("")
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(
        &if upcase?.(&1), do: String.replace(&1, &1, "_#{String.downcase(&1)}"), else: &1
      )
      |> Enum.join("")
      |> String.split("")
      |> Enum.reject(&(&1 == ""))
      |> List.pop_at(0)
      |> elem(1)
      |> Enum.join()

    IO.inspect(params)
    json = %{}
    config = Application.get_env(:blue_potion, :contexts)

    mods =
      if config == nil do
        ["Settings", "Secretary"]
      else
        config
      end

    struct =
      for mod <- mods do
        Module.concat([Application.get_env(:blue_potion, :otp_app), mod, model])
      end
      |> Enum.filter(&Code.ensure_compiled?(&1))
      |> List.first()

    IO.inspect(struct)

    mod =
      struct
      |> Module.split()
      |> Enum.take(2)
      |> Module.concat()

    IO.inspect(mod)

    dynamic_code =
      if Map.get(params, model) |> Map.get("id") != "0" do
        """
        struct = #{mod}.get_#{sanitized_model}!(params["id"])
        #{mod}.update_#{sanitized_model}(struct, params)
        """
      else
        """
        #{mod}.create_#{sanitized_model}(params)
        """
      end

    p = Map.get(params, model)

    p =
      case model do
        c when c in ["CorporateAccount"] ->
          case p["id"] |> Integer.parse() do
            :error ->
              {:ok, map} =
                Phoenix.Token.verify(
                  CommerceFrontWeb.Endpoint,
                  "corporate_account_signature",
                  p["id"]
                )

              p = Map.put(p, "id", map.id)

              append_params(p)

            _ ->
              append_params(p)
          end

        # c when c in ["Blog", "Shop", "Announcement"] ->
        #   case p["corporate_account_id"] |> Integer.parse() do
        #     :error ->
        #       {:ok, map} =
        #         Phoenix.Token.verify(
        #           CommerceFrontWeb.Endpoint,
        #           "corporate_account_signature",
        #           p["corporate_account_id"]
        #         )

        #       p = Map.put(p, "corporate_account_id", map.id)

        #       append_params(p)

        #     _ ->
        #       append_params(p)
        #   end

        "CorporateTopup" ->
          cond do
            p["corporate_account_id"] != nil ->
              if p["corporate_account_id"] |> Integer.parse() == :error do
                {:ok, map} =
                  Phoenix.Token.verify(
                    CommerceFrontWeb.Endpoint,
                    "corporate_account_signature",
                    p["corporate_account_id"]
                  )

                p = Map.put(p, "corporate_account_id", map.id)

                append_params(p)
              else
                p
              end

            p["id"] != "" ->
              p
          end

        "User" ->
          case p["id"] |> Integer.parse() do
            :error ->
              {:ok, map} = Phoenix.Token.verify(CommerceFrontWeb.Endpoint, "signature", p["id"])
              Map.put(p, "id", map.id)

            _ ->
              p
          end

        _ ->
          p
      end

    {result, _values} = Code.eval_string(dynamic_code, params: p |> CommerceFront.upload_file())

    IO.inspect(result)

    case result do
      {:ok, item} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(BluePotion.sanitize_struct(item)))

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = changeset.errors |> Keyword.keys()

        {reason, message} = changeset.errors |> hd()
        {proper_message, message_list} = message
        final_reason = Atom.to_string(reason) <> " " <> proper_message

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(500, Jason.encode!(%{status: final_reason}))
    end
  end

  require IEx

  def datatable(conn, params) do
    decode_token = fn params ->
      customer_id = Map.get(params, "user_id")

      params =
        if customer_id != nil do
          params
          |> Map.put(
            "user_id",
            CommerceFront.Settings.decode_token(customer_id)
          )
        else
          params
        end
    end

    model = Map.get(params, "model")
    preloads = Map.get(params, "preloads")
    additional_search_queries = Map.get(params, "additional_search_queries")
    additional_join_statements = Map.get(params, "additional_join_statements") |> IO.inspect()
    params = Map.delete(params, "model") |> Map.delete("preloads") |> Map.delete("host")

    search_queries =
      for key <- params["columns"] |> Map.keys() do
        val = params["columns"][key]["search"]["value"]

        if val != "" do
          {String.to_atom(params["columns"][key]["data"]), val}
        end
      end
      |> Enum.reject(fn x -> x == nil end)
      |> Enum.reject(fn x -> elem(x, 1) == nil end)

    additional_search_params =
      params
      |> Map.drop([
        "_",
        "rowFn",
        "pageLength",
        "additional_join_statements",
        "additional_search_queries",
        "columns",
        "draw",
        "foo",
        "length",
        "order",
        "search",
        "start"
      ])

    asp = additional_search_params |> Map.keys()

    search_queries2 =
      for asp_child <- asp do
        {String.to_atom(asp_child), additional_search_params |> Map.get(asp_child)}
      end

    addon_search =
      if search_queries2 != [] do
        for {key, val} = sq2 <- search_queries2 do
          cond do
            Integer.parse(val) != :error ->
              {int, _suffix} = Integer.parse(val)

              """
                a.#{Atom.to_string(key)}==#{int} 
              """

            Atom.to_string(key) |> String.contains?("_id") ->
              """
                a.#{Atom.to_string(key)}==#{val} 
              """

            val == "true" || val == "false" ->
              """
                a.#{Atom.to_string(key)}==#{val} 
              """

            true ->
              """
                a.#{Atom.to_string(key)}=="#{val}"
              """
          end
        end
        |> Enum.join(" and ")
      else
        ""
      end
      |> IO.inspect()

    params =
      decode_token.(params)
      |> IO.inspect()

    additional_join_statements =
      if additional_join_statements == nil do
        ""
      else
        joins = additional_join_statements |> Poison.decode!() |> IO.inspect()

        for join <- joins do
          key = Map.keys(join) |> List.first()
          value = join |> Map.get(key)

          config = Application.get_env(:blue_potion, :contexts)

          mods =
            if config == nil do
              ["Settings", "Secretary"]
            else
              config
            end

          struct =
            for mod <- mods do
              Module.concat([Application.get_env(:blue_potion, :otp_app), mod, key])
            end
            |> Enum.filter(&(elem(Code.ensure_compiled(&1), 0) == :module))
            |> List.first()

          "|> join(:left, [a], b in assoc(a, :#{key}))"
        end
        |> Enum.join("")
        |> IO.inspect()
      end

    additional_search_queries =
      if additional_search_queries == nil do
        if addon_search != "" do
          """
          |> where([a,b,c,d], #{addon_search})
          """
        else
          ""
        end
      else
        columns = additional_search_queries |> String.split(",")

        for {item, index} <- columns |> Enum.with_index() do
          cond do
            item |> String.contains?("!=") ->
              [i, val] = item |> String.split("!=")

              """
              |> where([a,b,c,d], a.#{i} != "#{val}") 
              """

            item |> String.contains?("_id^") ->
              item = item |> String.replace("^", "")
              [_prefix, i] = item |> String.split(".")
              ss = params["search"]["value"]

              if ss != "" do
                case Integer.parse(ss) do
                  {ss, _} ->
                    """
                    |> where([a,b,c,d], a.#{i} == ^"#{ss}") 
                    """

                  _ ->
                    """
                    |> where([a,b,c,d], a.#{i} == ^"#{ss}") 
                    """
                end
              end

            item |> String.contains?("^") ->
              item = item |> String.replace("^", "")
              [prefix, i] = item |> String.split(".")
              ss = params["search"]["value"]

              if ss != "" do
                """
                |> where([a,b,c,d],  ilike(#{prefix}.#{i}, ^"%#{ss}%") ) 
                """
              end

            true ->
              ss = params["search"]["value"]
              items = String.split(item, "|")
              ori_addon_search = addon_search

              addon_search =
                if addon_search != "" do
                  " and #{addon_search}"
                else
                  ""
                end

              subquery =
                for i <- items do
                  if i |> String.contains?(".") do
                    [prefix, i] = i |> String.split(".")
                    # if possible, here need to add back the previous and statements
                    [i, value] =
                      if i |> String.contains?("=") do
                        [i, value] = String.split(i, "=")
                      else
                        [i, ""]
                      end

                    ss =
                      if value != "" do
                        value
                      else
                        ss
                      end

                    check_id = fn tuple ->
                      if tuple |> is_tuple do
                        {prefix, i, ss} = tuple

                        if i |> String.contains?("_id") do
                          case Integer.parse(ss) do
                            {ss, _val} ->
                              """
                              #{prefix}.#{i} == ^#{ss} #{addon_search}
                              """

                            _ ->
                              """
                              ilike(a.#{i}, ^"%#{ss}%")  #{addon_search}
                              """
                          end
                        else
                          with true <-
                                 i |> String.contains?("id") || i in ["year", "month", "day"],
                               false <- i |> String.contains?("uuid"),
                               false <- i |> String.contains?("paid"),
                               false <- i |> String.contains?("is_"),
                               true <- ss != nil do
                            case Integer.parse(ss) |> IO.inspect() do
                              {ss, _val} ->
                                """
                                #{prefix}.#{i} == ^#{ss}  #{addon_search}
                                """

                              _ ->
                                """
                                ilike(a.#{i}, ^"%#{ss}%")  #{addon_search}
                                """
                            end
                          else
                            _ ->
                              tuple
                          end
                        end
                      else
                        tuple
                      end
                    end

                    check_date = fn tuple ->
                      if tuple |> is_tuple do
                        {prefix, i, ss} = tuple

                        if i == "date" do
                          """
                          #{prefix}.#{i} == ^"#{ss}"  #{addon_search}
                          """
                        else
                          tuple
                        end
                      else
                        tuple
                      end
                    end

                    check_bool = fn tuple ->
                      if tuple |> is_tuple do
                        {prefix, i, ss} = tuple

                        if ss == "true" || ss == "false" do
                          """
                          a.#{i} == ^#{ss}  #{addon_search}
                          """
                        else
                          if ss == nil do
                            """
                            #{ori_addon_search}
                            """
                          else
                            """
                            ilike(#{prefix}.#{i}, ^"%#{ss}%")  #{addon_search}
                            """
                          end
                        end
                      else
                        tuple
                      end
                    end

                    check_id.({prefix, i, ss})
                    |> check_date.()
                    |> check_bool.()
                  else
                    [i, value] =
                      if i |> String.contains?("=") do
                        [i, value] = String.split(i, "=")
                      else
                        [i, ""]
                      end

                    ss =
                      if value != "" do
                        value
                      else
                        ss
                      end

                    unless i |> String.contains?("_id") do
                      if ss == "true" || ss == "false" do
                        """
                        a.#{i} == ^#{ss}  #{addon_search}
                        """
                      else
                        """
                        ilike(a.#{i}, ^"%#{ss}%")  #{addon_search}
                        """
                      end
                    else
                      case Integer.parse(ss) do
                        {ss, _val} ->
                          """
                          a.#{i} == ^#{ss}  #{addon_search}
                          """

                        _ ->
                          if ss == "true" || ss == "false" do
                            """
                            a.#{i} == ^#{ss}  #{addon_search}
                            """
                          else
                            """
                            ilike(a.#{i}, ^"%#{ss}%")  #{addon_search}
                            """
                          end
                      end
                    end
                  end
                end
                |> Enum.reject(&(&1 == nil))
                |> Enum.reject(&(&1 == ""))
                |> Enum.join(" and ")
                |> IO.inspect()

              with true <- subquery != "",
                   true <- ss != nil do
                # consider append existing search queries..

                """
                |> or_where([a,b,c,d], #{subquery} )
                """
              else
                _ ->
                  with true <- subquery != "",
                       true <- subquery != "\n",
                       false <- subquery |> String.contains?("and \n") do
                    """
                    |> or_where([a,b,c,d], #{subquery} )
                    """
                  else
                    _ ->
                      nil
                  end
              end
          end
        end
        |> Enum.reject(&(&1 == nil))
        |> Enum.join("")
      end
      |> IO.inspect()

    Enum.map([1, 2, 4], fn x -> x end)

    preloads =
      if preloads == nil do
        preloads = []
      else
        IO.inspect("preload ")

        preloads
        |> Poison.decode!()
        |> Enum.map(&(&1 |> BluePotion.convert_to_atom()))
      end
      |> List.flatten()

    IO.inspect(preloads)

    json =
      BluePotion.post_process_datatable(
        params,
        Module.concat(["CommerceFront", "Settings", model]),
        additional_join_statements,
        additional_search_queries,
        preloads
      )

    %{data: data, draw: _draw, recordsFiltered: _recordsFiltered, recordsTotal: _recordsTotal} =
      json

    sanitize_pw = fn data ->
      if model == "Sale" do
        data
        |> Enum.map(fn x ->
          x
          |> IO.inspect()
          |> Map.put(
            :registration_details,
            x.registration_details
            |> Jason.decode!()
            |> Kernel.get_and_update_in(["user", "password"], &{&1, ""})
            |> elem(1)
            |> Jason.encode!()
          )
        end)
      else
        data
      end
    end

    json = Map.put(json, :data, data |> sanitize_pw.())

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(json))
  end

  def delete_data(conn, params) do
    model = Map.get(params, "model")
    params = Map.delete(params, "model")

    upcase? = fn x -> x == String.upcase(x) end

    sanitized_model =
      model
      |> String.split("")
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(
        &if upcase?.(&1), do: String.replace(&1, &1, "_#{String.downcase(&1)}"), else: &1
      )
      |> Enum.join("")
      |> String.split("")
      |> Enum.reject(&(&1 == ""))
      |> List.pop_at(0)
      |> elem(1)
      |> Enum.join()

    IO.inspect(params)
    json = %{}

    config = Application.get_env(:blue_potion, :contexts)

    mods =
      if config == nil do
        ["Settings", "Secretary"]
      else
        config
      end

    struct =
      for mod <- mods do
        Module.concat([Application.get_env(:blue_potion, :otp_app), mod, model])
      end
      |> Enum.filter(&({:error, :nofile} != Code.ensure_compiled(&1)))
      |> List.first()

    IO.inspect(struct)

    mod =
      struct
      |> Module.split()
      |> Enum.take(2)
      |> Module.concat()

    IO.inspect(mod)

    dynamic_code = """
    struct = #{mod}.get_#{sanitized_model}!(params["id"])
    #{mod}.delete_#{sanitized_model}(struct)
    """

    {result, _values} = Code.eval_string(dynamic_code, params: params)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{status: "already deleted"}))
  end
end
