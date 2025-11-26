defmodule CommerceFrontWeb.PageController do
  use CommerceFrontWeb, :controller
  require IEx

  @doc """
  from svt admin the link will redirect user to page index with login details?
  """
  def admin_override(conn, _params) do
    render(conn, "override.html")
  end

  def index(conn, _params) do
    IO.inspect("it's reloading!")
    render(conn, "index.html")
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def notification(conn, params) do
    IO.inspect(params)

    %{
      "amount" => "2.50",
      "appcode" => "",
      "channel" => "FPX_MB2U",
      "currency" => "RM",
      "domain" => "MGhaho2u",
      "error_code" => "",
      "error_desc" => "",
      "extraP" => "{\"fpx_buyer_name\":\"LEE YIT HANG\",\"fpx_txn_id\":\"2501050214000277\"}",
      "nbcb" => "2",
      "orderid" => "HAHOSALE268",
      "paydate" => "2025-01-05 02:13:58",
      "skey" => "2d73918ab3d95f3d4eaa97e3c44a01c1",
      "status" => "00",
      "tranID" => "2617777380"
    }

    json(conn, %{})
  end

  def razer_payment(conn, %{"chan" => chan, "amt" => amt, "ref_no" => ref} = params) do
    # case Razer.init(chan, amt, ref) |> IO.inspect() do
    #   %{status: :ok, url: url, params: params} ->
    #     encoded_params = URI.encode_query(params)
    #     redirect_to = "#{url}?" <> encoded_params

    #     conn
    #     |> redirect(external: redirect_to)

    #   %{status: :error, reason: reason} ->
    #     conn
    #     |> redirect(external: Razer.payment_page(chan, amt, ref))

    #   _ ->
    #     conn
    #     |> redirect(to: "/")
    # end

    conn
    |> redirect(external: Razer.payment_page(chan, amt, ref))
  end

  def html(conn, params) do
    app_dir = Application.app_dir(:commerce_front)
    path = app_dir <> "/priv/static/html/v2/#{params["path"] |> Enum.join("/")}"

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

    case File.read(path) do
      {:ok, bin} ->
        bin = bin |> String.replace("   ", "")

        translate = fn keyword, html ->
          if keyword == "Sales History" && html |> String.contains?("Sales History") do
            
          end

          String.replace(html, keyword, translation_map[keyword])
        end

        final_html =
          Enum.reduce(Map.keys(translation_map), bin, &translate.(&1, &2)) |> IO.inspect()

        append_cache_request = fn conn ->
          # conn
          # |> put_resp_header("cache-control", "max-age=900, must-revalidate")
          conn
        end

        conn
        |> append_cache_request.()
        |> put_resp_content_type("document/html")
        |> send_resp(200, final_html)

      _ ->
        final_html = ""

        conn
        |> put_resp_content_type("document/html")
        |> send_resp(200, final_html)
    end
  end

  def pdf_preview(conn, %{"id" => id, "type" => "do"} = params) do
    sale = CommerceFront.Settings.get_sale!(id)

    conn
    |> render("do_pdf.html",
      title: "Delivery Order",
      sale: sale,
      order_lines: sale.sales_items,
      layout: {CommerceFrontWeb.LayoutView, "blank.html"}
    )
  end

  def pdf(conn, %{"id" => id, "type" => "do"} = params) do
    sale = CommerceFront.Settings.get_sale!(id)

    server_url = "http://localhost:4000"
    server_url = Application.get_env(:commerce_front, :url)

    html =
      Phoenix.View.render_to_string(
        CommerceFrontWeb.PageView,
        "do_pdf.html",
        conn: conn,
        merchant: nil,
        title: "Delivery Order",
        sale: sale,
        order_lines: sale.sales_items
      )
      |> String.replace("/images", "#{server_url}/images")

    IO.inspect(server_url)

    css = "<link rel='stylesheet' href='#{server_url}/css/app.css' >
        <link rel='stylesheet' href='#{server_url}/css/all.css' >"

    pdf_params = %{
      "html" => "<!DOCTYPE html><html><head>#{css}</head><body>#{html}</body></html>"
    }

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
      "attachment; filename=\"DeliveryOrder_#{params["id"]}.pdf\""
    )
    |> send_resp(200, pdf_binary)
  end

  def pdf_preview(conn, %{"id" => id, "type" => "merchant_do"} = params) do
    sale = CommerceFront.Settings.get_sale!(id) |> CommerceFront.Repo.preload(:merchant)

    conn
    |> render("do_pdf.html",
      title: "Delivery Order",
      merchant: sale.merchant,
      sale: sale,
      order_lines: sale.sales_items,
      layout: {CommerceFrontWeb.LayoutView, "blank.html"}
    )
  end

  def pdf(conn, %{"id" => id, "type" => "merchant_do"} = params) do
    sale =
      CommerceFront.Settings.get_sale!(id)
      |> CommerceFront.Repo.preload(:merchant)

    server_url = "http://localhost:4000"
    server_url = Application.get_env(:commerce_front, :url)

    html =
      Phoenix.View.render_to_string(
        CommerceFrontWeb.PageView,
        "do_pdf.html",
        conn: conn,
        merchant: sale.merchant,
        title: "Delivery Order",
        sale: sale,
        order_lines: sale.sales_items
      )
      |> String.replace("/images", "#{server_url}/images")

    IO.inspect(server_url)

    css = "<link rel='stylesheet' href='#{server_url}/css/app.css' >
        <link rel='stylesheet' href='#{server_url}/css/all.css' >"

    pdf_params = %{
      "html" => "<!DOCTYPE html><html><head>#{css}</head><body>#{html}</body></html>"
    }

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
      "attachment; filename=\"DeliveryOrder_#{params["id"]}.pdf\""
    )
    |> send_resp(200, pdf_binary)
  end

  def pdf_preview(conn, %{"id" => id, "type" => "commission", "year" => year} = params) do
    commission_data = CommerceFront.Settings.user_monthly_reward_summary_by_years(id, year)

    # 516, 2024
    conn
    |> render("commission_pdf.html",
      title: "Commission Summary",
      year: year,
      commission_data: commission_data,
      layout: {CommerceFrontWeb.LayoutView, "blank.html"}
    )
  end

  def pdf(conn, %{"id" => id, "type" => "commission", "year" => year} = params) do
    commission_data = CommerceFront.Settings.user_monthly_reward_summary_by_years(id, year)

    server_url = "http://localhost:4000"
    server_url = Application.get_env(:commerce_front, :url)

    html =
      Phoenix.View.render_to_string(
        CommerceFrontWeb.PageView,
        "commission_pdf.html",
        conn: conn,
        year: year,
        title: "Commission Summary",
        commission_data: commission_data
      )
      |> String.replace("/images", "#{server_url}/images")

    IO.inspect(server_url)

    css = "<link rel='stylesheet' href='#{server_url}/css/app.css' >
        <link rel='stylesheet' href='#{server_url}/css/all.css' >"

    pdf_params = %{
      "html" => "<!DOCTYPE html><html><head>#{css}</head><body>#{html}</body></html>"
    }

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
      "attachment; filename=\"CommissionSummary_#{params["id"]}.pdf\""
    )
    |> send_resp(200, pdf_binary)
  end

  def pdf_preview(conn, %{"id" => id, "type" => "merchant"} = params) do
    sale =
      CommerceFront.Settings.get_sale!(id) |> CommerceFront.Repo.preload([:merchant, :country])

    conn
    |> render("co_pdf.html",
      title: "Invoice",
      merchant: sale.merchant,
      sale: sale,
      order_lines: sale.sales_items,
      layout: {CommerceFrontWeb.LayoutView, "blank.html"}
    )
  end

  def pdf(conn, %{"id" => id, "type" => "merchant"} = params) do
    sale =
      CommerceFront.Settings.get_sale!(id)
      |> CommerceFront.Repo.preload([:country, :merchant])

    server_url = "http://localhost:4000"
    server_url = Application.get_env(:commerce_front, :url)

    html =
      Phoenix.View.render_to_string(
        CommerceFrontWeb.PageView,
        "co_pdf.html",
        conn: conn,
        merchant: sale.merchant,
        title: "Invoice",
        sale: sale,
        order_lines: sale.sales_items
      )
      |> String.replace("/images", "#{server_url}/images")

    IO.inspect(server_url)

    css = "<link rel='stylesheet' href='#{server_url}/css/app.css' >
        <link rel='stylesheet' href='#{server_url}/css/all.css' >"

    pdf_params = %{
      "html" => "<!DOCTYPE html><html><head>#{css}</head><body>#{html}</body></html>"
    }

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
      "attachment; filename=\"Invoice_#{params["id"]}.pdf\""
    )
    |> send_resp(200, pdf_binary)
  end

  def pdf_preview(conn, %{"id" => id} = params) do
    sale =
      CommerceFront.Settings.get_sale!(id)
      |> CommerceFront.Repo.preload([:country, :merchant])
      

    conn
    |> render("co_pdf.html",
      title: "Invoice",
      sale: sale,
      merchant: nil,
      order_lines: sale.sales_items,
      layout: {CommerceFrontWeb.LayoutView, "blank.html"}
    )
  end

  def pdf(conn, %{"id" => id} = params) do
    sale =
      CommerceFront.Settings.get_sale!(id)
      |> CommerceFront.Repo.preload([:country, :merchant])

    server_url = "http://localhost:4000"
    server_url = Application.get_env(:commerce_front, :url)

    html =
      Phoenix.View.render_to_string(
        CommerceFrontWeb.PageView,
        "co_pdf.html",
        conn: conn,
        merchant: nil,
        title: "Invoice",
        sale: sale,
        order_lines: sale.sales_items
      )
      |> String.replace("/images", "#{server_url}/images")

    IO.inspect(server_url)

    css = "<link rel='stylesheet' href='#{server_url}/css/app.css' >
        <link rel='stylesheet' href='#{server_url}/css/all.css' >"

    pdf_params = %{
      "html" => "<!DOCTYPE html><html><head>#{css}</head><body>#{html}</body></html>"
    }

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
      "attachment; filename=\"Invoice_#{params["id"]}.pdf\""
    )
    |> send_resp(200, pdf_binary)
  end

  def authenticate(conn, params) do
    case check_password(params) do
      {true, user} ->
        conn
        |> put_session(:current_user, BluePotion.s_to_map(user))
        |> redirect(to: "/home")

      _ ->
        conn
        |> redirect(to: "/login")
    end
  end

  def check_password(params) do
    # your auth method here

    user = CommerceFront.Settings.get_user_by_username(params["username"])

    if user != nil do
      crypted_password =
        :crypto.hash(:sha512, params["password"]) |> Base.encode16() |> String.downcase()

      {crypted_password == user.crypted_password, user}
    else
      false
    end
  end

  @doc """
  CommerceFrontWeb.PageController.thank_you(%Plug.Conn{}, %{
        "amount" => "2.50",
        "appcode" => "",
        "channel" => "FPX_MB2U",
        "currency" => "RM",
        "domain" => "MGhaho2u",
        "error_desc" => "",
        "orderid" => "HAHOSALE310",
        "paydate" => "2025-01-05 02:13:58",
        "skey" => "2d73918ab3d95f3d4eaa97e3c44a01c1",
        "status" => "00",
        "tranID" => "2617777380"
      })
  """
  def thank_you(conn, params) do
    IO.inspect(params)

    payment = CommerceFront.Settings.get_payment_by_billplz_code(params["orderid"])
    payment |> CommerceFront.Settings.update_payment(%{webhook_details: Jason.encode!(params)})

    # case params["status"] do
    #   "00" ->
    #     with true <- payment.wallet_topup != nil do
    #       case CommerceFront.Settings.approve_topup(%{"id" => payment.wallet_topup.id}) do
    #         {:ok, tp} ->
    #           %{status: "ok", res: tp |> BluePotion.sanitize_struct()}

    #         _ ->
    #           %{status: "error"}
    #       end
    #     else
    #       _ ->
    #         %{status: "ok"}
    #     end

    #   _ ->
    #     %{status: "error"}
    # end
    with true <- params["status"] == "00",
         true <- payment != nil,
         true <- payment.sales != nil,
         sales <- payment.sales,
         {:ok, register_params} <- sales.registration_details |> Jason.decode() do
      Elixir.Task.start_link(CommerceFront.Settings, :register, [register_params["user"], sales])
    else
      _ ->
        with true <- params["status"] == "00",
             true <- payment != nil,
             true <- payment.wallet_topup != nil do
          case CommerceFront.Settings.approve_topup(%{"id" => payment.wallet_topup.id})
               |> IO.inspect() do
            {:ok, tp} ->
              %{status: "ok", res: tp |> BluePotion.sanitize_struct()}

            _ ->
              %{status: "error", reason: "Already Approved!"}
          end
        else
          _ ->
            %{status: "error"}
        end
    end

    IO.inspect("it's thank you-ing!")
    render(conn, "thank_you.html", params)
  end
end
