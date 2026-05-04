defmodule CommerceFrontWeb.Router do
  use CommerceFrontWeb, :router

  if Mix.env() == :dev do
    # If using Phoenix
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  @content_security_policy (case Mix.env() do
                              # :prod  -> "default-src 'self'"

                              # _ -> "default-src 'self' 'unsafe-eval'"

                              _ ->
                                "default-src 'self' 'unsafe-inline' fonts.gstatic.com; img-src 'self' blob data: ; style-src 'self' 'unsafe-inline' fonts.googleapis.com fonts.gstatic.com;"
                            end)
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    # plug :put_secure_browser_headers, %{"content-security-policy" => @content_security_policy}
  end

  pipeline :browser_blank do
    plug :accepts, ["html"]
  end

  pipeline :plain_api do
    plug :accepts, ["json"]
  end

  pipeline :svt_api do
    plug :accepts, ["json"]

    plug CORSPlug,
      origin: [
        "https://fonts.gstatic.com",
        "https://svt.damienslab.com",
        "https://test_svt.damienslab.com",
        "http://svt.damienslab.com",
        "https://admin.haho2u.com",
        "http://admin.haho2u.com",
        "http://test_svt.damienslab.com",
        "http://localhost:5174",
        "http://localhost:5173"
      ]

    plug(CommerceFront.ApiAuthorization)
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :protect_from_forgery

    plug CORSPlug,
      origin: [
        "https://fonts.gstatic.com",
        "https://svt.damienslab.com",
        "http://svt.damienslab.com",
        "https://admin.haho2u.com",
        "http://admin.haho2u.com",
        "https://test_svt.damienslab.com",
        "http://test_svt.damienslab.com",
        "http://localhost:5174",
        "http://localhost:5173"
      ]

    plug(CommerceFront.ApiAuthorization)
  end

  pipeline :admin_api do
    plug :accepts, ["json"]
    plug CORSPlug,
      origin: [
        "https://admin.haho2u.com",
        "http://admin.haho2u.com",
        "http://localhost:5174",
        "http://localhost:5173"
      ]
    # Note: Authorization is handled in the controller
  end

  scope "/svt_api", CommerceFrontWeb do
    pipe_through :svt_api
    get "/stream", ApiController, :stream_get
    options("/:webhook", ApiController, :get)

    get "/webhook", ApiController, :get
    post "/webhook", ApiController, :post
    options("/:model", ApiController, :datatable)
    get("/:model", ApiController, :datatable)
    post("/:model", ApiController, :form_submission)
    options("/:model/:id", ApiController, :delete_data)
    delete("/:model/:id", ApiController, :delete_data)
    
    # Admin operations
    post "/cancel_sales", ApiController, :cancel_sales
  end

  scope "/api", CommerceFrontWeb do
    pipe_through :browser_blank

    post "/notification/razer", PageController, :notification
  end

  scope "/api", CommerceFrontWeb do
    pipe_through :plain_api
    post "/payment/razer", ApiController, :razer_payment
    post "/payment/billplz", ApiController, :payment
  end

  scope "/api", CommerceFrontWeb do
    pipe_through :api

    post "/webhook/login", ApiController, :post
  end

  scope "/api", CommerceFrontWeb do
    pipe_through :api
    get "/stream", ApiController, :stream_get
    options("/:webhook", ApiController, :get)

    get "/webhook", ApiController, :get
    post "/webhook", ApiController, :post
    options("/:model", ApiController, :datatable)
    get("/:model", ApiController, :datatable)
    post("/:model", ApiController, :form_submission)
    delete("/:model/:id", ApiController, :delete_data)
  end

  # Admin endpoint for Code.eval and database operations
  scope "/admin", CommerceFrontWeb do
    pipe_through :admin_api
    
    post "/eval", AdminController, :eval
    post "/db_query", AdminController, :db_query
    get "/logs", AdminController, :logs
  end

  scope "/html/:lang", CommerceFrontWeb do
    pipe_through [:browser]
    get "/*path", PageController, :html
  end

  scope "/", CommerceFrontWeb do
    pipe_through :browser_blank
    post "/test_razer", PageController, :razer_payment
    post "/thank_you", PageController, :thank_you
  end

  scope "/", CommerceFrontWeb do
    pipe_through :browser

    get "/admin_override", PageController, :admin_override
    get "/", PageController, :index
    get "/pdf_preview", PageController, :pdf_preview
    get "/pdf", PageController, :pdf
    get "/log2in", PageController, :login
    post "/auth", PageController, :authenticate
    get "/thank_you", PageController, :thank_you
    post "/thank_you", PageController, :thank_you
    get "/test_razer", PageController, :razer_payment

    get "/*path", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", CommerceFrontWeb do
  #   pipe_through :api
  # end
end
