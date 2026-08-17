# Engineering Document — ShopLite (iOS / SwiftUI)

## Scope
This is a **living document** describing implementation-level engineering concerns. Updated incrementally as new features/stages are added.

---

## 1. Libraries / Dependencies

**Stage 1: zero third-party dependencies.** Everything is achievable with Apple-native frameworks:

| Concern | Framework | Notes |
|---|---|---|
| UI | SwiftUI | iOS 17+ |
| State management | Observation (`@Observable`) | Native, iOS 17+ |
| Networking | `URLSession` + `async/await` | No Alamofire needed for this scope |
| Secure storage | `Security` framework (Keychain Services) | Wrapped by `KeychainStore.swift` |
| Images | `AsyncImage` (SwiftUI) | For product thumbnails from remote URLs |
| Navigation | `NavigationStack` (SwiftUI) | iOS 16+, used with iOS 17 target |

If a future need arises (e.g. image caching at scale, analytics), it will be added here with justification rather than pulled in speculatively.

---

## 2. Build Configuration

- **Xcode project**, Swift Package Manager for any future dependencies (no CocoaPods/Carthage).
- **Deployment target:** iOS 17.0.
- **Schemes:** single `ShopLite` scheme for Stage 1; `Debug` and `Release` configurations (default Xcode setup).
- **Signing:** automatic signing, personal/team development certificate (adjust for distribution later).
- No environment-specific build flavors needed yet, since DummyJSON is a single fixed mock base URL — see Section 3 for how this is still made configurable.

---

## 3. Environment Setup

- **Base URL** (`https://dummyjson.com/`) defined as a constant in `APIClient`, not hardcoded per-call — this keeps a future switch to per-environment config (e.g. `Debug.xcconfig` / `Release.xcconfig`) low-effort if ever needed.
- No `.env` file mechanism required for Stage 1 (no secrets — DummyJSON requires no API key).
- **Local setup steps** (also mirrored in README):
  1. Clone repo.
  2. Open `ShopLite.xcodeproj` (or `.xcworkspace` if SPM adds one) in Xcode 15+.
  3. Select a simulator running iOS 17+.
  4. Build & run (`Cmd+R`).

---

## 4. External API Integrations

**Provider:** DummyJSON (`https://dummyjson.com/`) — public mock REST API, JSON over HTTPS, no API key.

| Endpoint | Method | Used By | Purpose |
|---|---|---|---|
| `/auth/login` | POST | `AuthService` | Exchange username/password for access/refresh tokens |
| `/products` | GET | `ProductService` | Fetch paginated product list (`limit`, `skip` query params) — Stage 1 |
| `/products/{id}` | GET | `ProductService` | Fetch single product by ID — Stage 2 |

**Integration pattern:**
- `APIClient` centralizes request construction, header injection (`Authorization: Bearer <token>` when a session exists), `Codable` decoding, and error mapping.
- Each Service method returns a strongly-typed model or throws a typed `APIError` (`.unauthorized`, `.network`, `.decoding`, `.server(statusCode:)`, etc.) — ViewModels switch on this to decide what UI state to show (per Task Document's error/empty/retry requirements).
- Requests use `async/await`; no manual callback/completion-handler chains.
- **Stage 2 additions:** `ProductService.fetchProduct(id:)` added for Detail screen; image URLs loaded via SwiftUI `AsyncImage`, placeholder shown on failure.

---

## 5. Coding Workflow (SDD-specific)

Per the mandatory SDD process, each feature's implementation step follows:
1. Feature Specification (Task Document) — already approved.
2. Static HTML prototype — created and approved before SwiftUI code is written.
3. SwiftUI implementation — Views + ViewModel + Service wiring, following the Architecture Document's structure.
4. Testing — see Section 6.
5. Documentation update — this doc and the Architecture Document's changelog are updated if the feature introduced new patterns/dependencies.

---

## 6. Testing Approach

- **Unit tests** (XCTest / Swift Testing): ViewModels tested in isolation by injecting mock Services (protocol-based `AuthServicing`, `ProductServicing`) — no real network calls in tests.
- **Manual UI verification**: each screen checked against its Task Document acceptance criteria before marking the feature done.
- Snapshot/UI automation tests are not required for Stage 1 but may be added later if the project grows.

---

## Changelog
- **Stage 1 (Login + Home):** Initial engineering setup — no third-party deps, `URLSession`/`async-await` networking, Keychain storage, XCTest-based unit testing.
- **Stage 2 (Detail Screen):** Added `GET /products/{id}` endpoint integration via `ProductService.fetchProduct(id:)`, image loading via `AsyncImage`, same error handling pattern as Stage 1.