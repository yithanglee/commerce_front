defmodule CommerceFrontWeb.PageController do
  use CommerceFrontWeb, :controller
  require IEx

  def index(conn, _params) do
    IO.inspect("it's reloading!")
    render(conn, "index.html")
  end

  def login(conn, _params) do
    render(conn, "login.html")
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
            # IEx.pry()
          end

          String.replace(html, keyword, translation_map[keyword])
        end

        final_html =
          Enum.reduce(Map.keys(translation_map), bin, &translate.(&1, &2)) |> IO.inspect()

        append_cache_request = fn conn ->
          conn
          |> put_resp_header("cache-control", "max-age=900, must-revalidate")
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

  def pdf_preview(conn, %{"id" => id} = params) do
    sale = CommerceFront.Settings.get_sale!(id)

    conn
    |> render("co_pdf.html",
      title: "Customer Order",
      sale: sale,
      order_lines: sale.sales_items,
      layout: {CommerceFrontWeb.LayoutView, "blank.html"}
    )
  end

  def pdf(conn, %{"id" => id} = params) do
    sale = CommerceFront.Settings.get_sale!(id)

    server_url = "http://localhost:4000"
    server_url = Application.get_env(:commerce_front, :url)

    html =
      Phoenix.View.render_to_string(
        CommerceFrontWeb.PageView,
        "co_pdf.html",
        conn: conn,
        title: "Customer Order",
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
      "attachment; filename=\"CustomerOrder_#{params["id"]}.pdf\""
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

  def thank_you(conn, params) do
    IO.inspect("it's reloading!")
    render(conn, "thank_you.html", params)
  end
end
