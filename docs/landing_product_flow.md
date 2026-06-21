# Landing And Product Flow

This document traces the storefront entry points from the Phoenix shell through the landing page, product grid, product detail page, and the backend functions/data models those pages use.

## Entry Points

| File | Role |
| --- | --- |
| `lib/commerce_front_web/templates/page/index.html.eex` | Phoenix shell rendered by `PageController.index`; provides `#content`, footer links, install prompt UI, modals, toast host, and loading overlay. |
| `priv/static/html/v2/landing.html` | Home page fragment loaded into `#content`; renders slideshow containers and the `<products>` component. |
| `assets/js/commerce_app.js` | Storefront component library; renders `<products>`, `<product>`, cart behavior, region selection, product pricing, and API calls. |

## Data Flow

```mermaid
flowchart TD
    Browser["Browser request: / or /home"] --> Router["CommerceFrontWeb.Router"]
    Router --> PageIndex["PageController.index"]
    PageIndex --> Shell["index.html.eex shell"]
    Shell --> AppJS["assets/js/app.js"]
    AppJS --> CountriesApi["GET /api/webhook?scope=countries"]
    CountriesApi --> ApiGet["ApiController.get"]
    ApiGet --> ListCountries["Settings.list_countries()"]
    ListCountries --> CountriesTable[("countries")]
    CountriesTable --> AppState["phxApp_.countries_"]

    AppJS --> Navigate["phxApp_.navigateTo()"]
    Navigate --> Landing["landing.html"]
    Landing --> SlidesApi["GET /api/webhook?scope=slides"]
    SlidesApi --> ListSlides["Settings.list_slides(true)"]
    ListSlides --> SlidesTable[("slides")]
    SlidesTable --> Slick["Render mobile/desktop slick slideshows"]

    Landing --> ProductsTag["<products>"]
    ProductsTag --> RenderProducts["commerceApp_.components.products()"]
    RenderProducts --> RegionChoice{"chosen_country_id_ set?"}
    RegionChoice -- "No" --> RegionModal["Choose region modal"]
    RegionModal --> TranslationApi["GET /api/webhook?scope=translation"]
    RegionModal --> NavigateHome["phxApp_.navigateTo('/home')"]
    RegionChoice -- "Yes" --> ProductGrid["phoenixModel ProductCountry grid"]
    ProductGrid --> ProductCountryApi["GET /api/ProductCountry"]
    ProductCountryApi --> Datatable["ApiController.datatable"]
    Datatable --> ProductCountryTable[("product_countries")]
    ProductCountryTable --> ProductTable[("products")]
    ProductCountryTable --> CountryTable[("countries")]
    ProductGrid --> Cards["Render product cards"]
    Cards --> ProductDetail["/products/:id/:name"]
    Cards --> AddFromGrid["Add button if <products direct>"]

    ProductDetail --> ProductApi["GET /api/webhook?scope=get_product"]
    AddFromGrid --> ProductApi
    ProductApi --> GetProduct["Settings.get_product!(id)"]
    GetProduct --> ProductWithPreloads["Product preloaded with stocks, countries, instalment packages, first payment product"]
    ProductWithPreloads --> ProductPage["Render product detail or add to localStorage cart"]
```

## Backend Trace

| Frontend action | API endpoint | Backend function | Data accessed | Result |
| --- | --- | --- | --- | --- |
| App boot loads countries | `GET /api/webhook?scope=countries` | `ApiController.get` -> `Settings.list_countries()` | `countries` | Populates `phxApp_.countries_` for region selection and pricing conversion. |
| Landing page loads slides | `GET /api/webhook?scope=slides` | `ApiController.get` -> `Settings.list_slides(true)` | `slides` where `is_show == true` | Builds mobile and desktop slideshow markup in `landing.html`. |
| Landing page renders products | `GET /api/ProductCountry` | `ApiController.datatable` via `phoenixModel` | `product_countries` joined to `products`; filtered by `country_id` and `b.is_instalment=false` | Returns grid rows used to render product cards. |
| Product card opens detail page | Client route `/products/:id/:name` | `phxApp_.navigateTo` loads `product.html`; `commerceApp_.components.product()` runs | No server-side route change beyond shell fallback | Product detail component reads `pageParams.id`. |
| Product detail fetches product | `GET /api/webhook?scope=get_product&id=:id` | `ApiController.get` -> `Settings.get_product!(id)` | `products`, with `stocks`, `countries`, `instalment_packages`, `first_payment_product` preloaded | Renders product detail, price, PV, instalment choices, and Add button. |
| Add product to cart | Usually reuses `get_product`; then client-side cart methods | `commerceApp_.addItem_`, `updateCart`, `cartItems` | Browser `localStorage` keys `cart`, `first_cart_country_id` | Adds item locally and validates it belongs to selected/first cart country. |
| Shared-code region path, if present | `GET /api/webhook?scope=get_share_link_by_code&code=:share_code` | `ApiController.get` -> `Settings.get_share_link_by_code(code)` -> preload `:user` | `share_links`, `users` | Selects sponsor/user country and displays sponsor/bank metadata in pages that use `pageParams.share_code`. |

## Entity Relationship Diagram

```mermaid
erDiagram
    COUNTRIES {
        int id PK
        string name
        string alias
        string currency
        float conversion
        string img_url
        datetime inserted_at
        datetime updated_at
    }

    PRODUCTS {
        int id PK
        string name
        string cname
        binary desc
        string img_url
        string category
        int category_id
        int point_value
        float retail_price
        boolean can_pay_by_drp
        boolean is_instalment
        int first_payment_product_id FK
        int instalment_id FK
        datetime inserted_at
        datetime updated_at
    }

    PRODUCT_COUNTRIES {
        int id PK
        int product_id FK
        int country_id FK
        datetime inserted_at
        datetime updated_at
    }

    SLIDES {
        int id PK
        string mobile_img_url
        string img_url
        boolean is_show
        int order
        string remarks
        datetime inserted_at
        datetime updated_at
    }

    SHARE_LINKS {
        int id PK
        int user_id FK
        string share_code
        string position
        datetime inserted_at
        datetime updated_at
    }

    USERS {
        int id PK
        int country_id FK
        string username
        string fullname
        string email
        string phone
        boolean approved
        boolean blocked
        boolean is_stockist
        int stockist_user_id
        datetime inserted_at
        datetime updated_at
    }

    COUNTRIES ||--o{ PRODUCT_COUNTRIES : "has product availability"
    PRODUCTS ||--o{ PRODUCT_COUNTRIES : "available in country"
    COUNTRIES ||--o{ USERS : "user country"
    USERS ||--o{ SHARE_LINKS : "owns share links"
    PRODUCTS ||--o{ PRODUCTS : "first payment product for instalment packages"
```

## Frontend Page Table

| Route or page | Template/fragment | Component or script | What it does |
| --- | --- | --- | --- |
| `/` and fallback routes | `index.html.eex` | `phxApp_.navigateTo()` | Serves the SPA shell, then client-side navigation decides which static HTML fragment to load. |
| `/home` | `landing.html` | Inline slide script, `<products>` | Shows homepage slideshow and the new-arrivals product grid. |
| `/products/:id/:name` | `product.html` | `commerceApp_.components.product()` | Shows one product, pricing, description, instalment choices, and Add-to-cart action. |
| Footer link `/refund_policy` | `refund_policy.html` | Route metadata in `app.js` | Public policy page loaded without the normal nav. |
| Footer link `/terms_condition` | `terms_condition.html` | Route metadata in `app.js` | Public terms page loaded without the normal nav. |
| Floating menu `/sales` | `sales.html` | `commerceApp_` sales-related components | Authenticated sales history page; not deeply traced in this pass. |
| Floating menu `/group_sales` | `gs_summary.html` | group sales components | Authenticated group sales summary; not deeply traced in this pass. |
| Floating menu `/placement` | `placement.html` | placement component | Authenticated placement view; not deeply traced in this pass. |
| Floating menu `/placement_full` | `placement_full.html` | placement component | Authenticated full placement view; not deeply traced in this pass. |
| Floating menu `/referal` | `referal.html` | referral component | Authenticated referral/downline view; not deeply traced in this pass. |

## Notes And Questions

- `commerceApp_.components.products()` sometimes assigns `phxApp_.chosen_country_id_` to a country id string and elsewhere code reads it like a country object with `.id`, `.name`, and `.conversion`. I documented the intended country object flow, but this inconsistency should be verified.
- `showRP`, `includeShippingTax`, and `translationRes` are used as globals in this flow. Their initial values affect pricing display and language replacement, but they are not owned by the three starting files.
- The product grid uses the generic datatable builder and sends dynamic join/search parameters. The ER diagram shows the schema relationships, not every dynamic query branch in `ApiController.datatable`.
