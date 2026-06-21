# Commerce Front Rendering & Build Flow

This document describes how JavaScript is compiled and how components are rendered in the browser.

## Build Process

The project uses `nodemon` to monitor changes in the `assets/js` directory and `esbuild` to bundle the code.

```mermaid
graph LR
    A[assets/js/development] -- nodemon watch --> B[mix esbuild]
    B -- compile --> C[priv/static/assets/app.js]
```

## Frontend Rendering Flow

The application uses a custom rendering engine defined in `commerce_app.js`.

```mermaid
sequenceDiagram
    participant Browser
    participant App as commerceApp_
    participant API as Phoenix API
    
    Browser->>App: commerceApp_.render()
    loop For each component in list
        App->>Browser: Check for <tag>
        alt Tag Exists
            App->>App: components[tag]()
            App->>API: phxApp_.api(search/get)
            API-->>App: JSON Data
            App->>Browser: .customHtml() update
        end
    end
```

## Component List
The following components are automatically rendered by the `render()` function if their tags are present:
- `merchantProducts`
- `cartItems`
- `merchantProfile`
- `topup`
- `products`
- `rewardList`
- And others...
