# Architecture Document — ShopLite (iOS / SwiftUI)
 
## Scope
This is a **living document** covering the overall application architecture. It is updated incrementally as new features/stages are added (Stage 1: Login + Home is covered now; Stage 2: Detail Screen will extend it).
 
## Tech Stack
- **Platform:** iOS 17+
- **UI Framework:** SwiftUI
- **Language:** Swift 5.10+
- **State Management:** `@Observable` (Observation framework, iOS 17+)
- **Networking:** `URLSession` with `async/await` (no third-party dependencies)
- **Persistence:** Keychain (auth token), `UserDefaults` (non-sensitive flags only, if needed)
- **Navigation:** SwiftUI `NavigationStack`
- **Dependency Management:** Swift Package Manager (SPM) — no external packages required for Stage 1
---
 
## 1. Application Architecture
 
**Pattern: MVVM (Model-View-ViewModel)**, idiomatic for SwiftUI + `@Observable`:
 
- **Model** — plain `Codable` structs representing API data (`Product`, `User`, `AuthResponse`).
- **View** — SwiftUI views, declarative, no business logic. Reads state from a ViewModel, sends user intents to it.
- **ViewModel** — `@Observable` classes holding UI state (loading/error/data), calling into Services, exposing view-ready state.
- **Service Layer** — stateless API clients (`AuthService`, `ProductService`) wrapping `URLSession` calls. ViewModels depend on Services, not on `URLSession` directly.
- **Repository (thin)** — `AuthRepository` mediates between `AuthService` and Keychain, so ViewModels don't touch Keychain directly.
Data flow: `View → ViewModel → Service → API`, response flows back `Service → ViewModel → View` (via `@Observable` triggering re-render).
 
---
 
## 2. Coding Standards
 
- Swift API Design Guidelines followed (naming, argument labels).
- One primary type per file; file name matches type name.
- Views kept small and composable; extract subviews once a `body` exceeds ~40–50 lines.
- No business logic in Views — Views only bind to ViewModel state and call ViewModel methods.
- Async work via `async/await`; no completion-handler-based APIs introduced.
- Force-unwraps (`!`) and force-try (`try!`) disallowed except in truly impossible-failure cases (documented inline if used).
- Errors modeled as typed `enum: Error`, not stringly-typed.
- SwiftLint (or equivalent) config recommended for consistency (can be added as a follow-up task, not a Stage 1 blocker).
---
 
## 3. Security
 
- Auth token (`accessToken`, and `refreshToken` if used) stored in **iOS Keychain** — never in `UserDefaults` or plain files.
- No credentials (username/password) persisted anywhere after the login request completes.
- Network calls use HTTPS only (`https://dummyjson.com/`); App Transport Security (ATS) defaults are left enabled (no arbitrary-load exceptions).
- Tokens are never logged to console in release builds.
- On logout, Keychain entry is deleted (not just marked invalid client-side).
---
 
## 4. Folder Structure
 
```
ShopLite/
├── App/
│   ├── ShopLiteApp.swift          # @main entry point
│   └── RootView.swift             # Decides Login vs Home based on session state
│
├── Features/
│   ├── Login/
│   │   ├── LoginView.swift
│   │   └── LoginViewModel.swift
│   │
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── HomeViewModel.swift
│   │   └── Components/
│   │       └── ProductRowView.swift
│   │
│   └── Detail/                    # [STAGE 2]
│       ├── DetailView.swift
│       ├── DetailViewModel.swift
│       └── Components/
│           ├── ProductImageView.swift
│           ├── ProductTitleView.swift
│           ├── ProductRatingView.swift
│           ├── ProductPriceView.swift
│           └── ProductDescriptionView.swift
│
├── Models/
│   ├── User.swift
│   ├── AuthResponse.swift
│   └── Product.swift
│
├── Services/
│   ├── APIClient.swift            # Generic URLSession wrapper (base URL, request builder, decoding)
│   ├── AuthService.swift
│   └── ProductService.swift
│
├── Repositories/
│   └── AuthRepository.swift       # Keychain + AuthService coordination, session state
│
├── Persistence/
│   └── KeychainStore.swift        # Thin Keychain wrapper
│
├── Navigation/
│   └── AppRoute.swift             # NavigationStack path/route definitions
│
├── Common/
│   ├── Views/                     # Shared UI (LoadingView, ErrorView, EmptyStateView)
│   └── Extensions/
│
└── Resources/
    └── Assets.xcassets
```
 
---
 
## 5. State Management
 
- Each screen has one `@Observable` ViewModel owning its state (e.g. `HomeViewModel: loading, products, errorMessage, hasMorePages`).
- Views hold their ViewModel via `@State private var viewModel = ...` (SwiftUI + `@Observable` pattern) and pass it down to subviews via plain property injection (no `@EnvironmentObject` needed at this scale, though `@Environment` may be used later for app-wide session state).
- **Session state** (`isLoggedIn`, current user) lives in a single `SessionStore` (`@Observable`), created once at the app root and read by `RootView` to decide Login vs Home. This is the one piece of state shared across features.
- No global app-wide store/Redux-style single source of truth — state is scoped per-feature except for `SessionStore`.
---
 
## 6. Component (View) Hierarchy — Stage 1 & 2
 
```
ShopLiteApp
 └── RootView                  (observes SessionStore)
      ├── LoginView            (if not authenticated)
      │    └── uses LoginViewModel
      │
      └── NavigationStack       (if authenticated)
           ├── HomeView         (uses HomeViewModel)
           │    ├── ProductRowView (× N, in a List)
           │    ├── LoadingView (initial load)
           │    ├── ErrorView (with Retry)
           │    └── EmptyStateView
           │         [tap on ProductRowView → pushes Detail route]
           │
           └── DetailView       (uses DetailViewModel) [STAGE 2]
                ├── Toolbar (back button)
                ├── ProductImage
                ├── ProductTitle
                ├── ProductRating
                ├── ProductPrice
                ├── ProductDescription (scrollable if long)
                ├── LoadingView (initial fetch)
                └── ErrorView (with Retry)
```
 
---
 
## 7. Storage Management
 
| Data | Storage | Lifetime |
|---|---|---|
| Auth token (access/refresh) | Keychain | Until logout or explicit invalidation |
| Logged-in flag / user id (non-sensitive) | In-memory `SessionStore`, rehydrated from Keychain presence at launch | App session |
| Product list cache | In-memory only (ViewModel state) — no disk cache in Stage 1 | Per app session |
 
No Core Data / SwiftData in Stage 1 — not required until offline caching becomes a requirement.
 
---
 
## 8. API Architecture
 
- **Base URL:** `https://dummyjson.com/`
- **`APIClient`** is a single generic wrapper around `URLSession`: builds requests, attaches `Authorization: Bearer <token>` header when present, decodes JSON via `Codable`, maps HTTP/network errors into a typed `APIError`.
- **Endpoints used:**
  - **Stage 1:**
    - `POST /auth/login` — `{ username, password, expiresInMins }` → `AuthResponse { accessToken, refreshToken, ...user fields }`
    - `GET /products?limit=&skip=` → `{ products: [Product], total, skip, limit }`
  - **Stage 2:**
    - `GET /products/{id}` — fetch single product by ID → `Product { id, title, description, price, rating, thumbnail, ... }`
- Each domain has its own thin Service (`AuthService`, `ProductService`) that calls `APIClient` with typed request/response models — ViewModels never construct URLs or decode JSON directly.
- Pagination (Stage 1) handled by incrementing `skip` by `limit` in `HomeViewModel`, appending results, stopping when `skip >= total`.
- Detail fetch (Stage 2) called once on `DetailView` appear, using product ID from navigation parameter.
---
 
## Changelog
- **Stage 1 (Login + Home):** Initial architecture defined.
- **Stage 2 (Detail Screen):** Extended Component Hierarchy to include DetailView, added Folder Structure for `Features/Detail/`, added `GET /products/{id}` endpoint, specified Detail state management (loading, error, success).
 