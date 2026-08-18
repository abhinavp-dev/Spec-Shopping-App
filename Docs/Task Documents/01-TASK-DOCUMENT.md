# Task Document — Stage 1 (Login + Home)

## Project
ShopLite is a native iOS e-commerce application built with SwiftUI, letting users browse and view products, backed by the DummyJSON API (`https://dummyjson.com/`). Development follows a Spec-Driven Development (SDD) workflow, with each feature specified and validated before implementation.

## Stage Scope
This document covers **Stage 1 only**:
- Login
- Home (Product listing)

> Detail Screen is explicitly out of scope for this stage and will be covered in a separate Stage 2 Task Document.

---

## 1. Feature Scope

### 1.1 Login
Authenticate a user against the DummyJSON auth API and persist their session so the app can restore login state on relaunch.

### 1.2 Home (Products)
Display a list of products fetched from DummyJSON, accessible only to an authenticated user, with the ability to log out.

---

## 2. Functional Requirements

### 2.1 Login Screen
| ID | Requirement |
|----|-------------|
| FR-1.1 | User can enter a username and password. |
| FR-1.2 | User can submit credentials via a "Login" button. |
| FR-1.3 | App calls `POST /auth/login` with `{ username, password, expiresInMins }`. |
| FR-1.4 | On success, app stores the returned `accessToken` (and `refreshToken` if used) securely on-device. |
| FR-1.5 | On success, app navigates to the Home screen. |
| FR-1.6 | On failure (401/invalid credentials), app displays an inline error message without navigating. |
| FR-1.7 | Login button is disabled while the request is in-flight, and a loading indicator is shown. |
| FR-1.8 | If a valid stored session already exists on app launch, user is routed directly to Home (skip Login). |
| FR-1.9 | Basic client-side validation: both fields required before the API call is made. |

### 2.2 Home Screen (Products)
| ID | Requirement |
|----|-------------|
| FR-2.1 | On mount, app calls `GET /products` (paginated via `limit`/`skip`). |
| FR-2.2 | Products are rendered in a scrollable list, each item showing thumbnail, title, price, and rating. |
| FR-2.3 | List supports pull-to-refresh. |
| FR-2.4 | List supports infinite scroll / pagination (load more on reaching end). |
| FR-2.5 | A loading state is shown on initial fetch; a distinct loading indicator is shown on pagination fetch. |
| FR-2.6 | An error state with a "Retry" action is shown if the fetch fails. |
| FR-2.7 | An empty state is shown if the API returns zero products. |
| FR-2.8 | User can log out from Home (clears stored session, navigates back to Login). |
| FR-2.9 | Tapping a product item is wired to navigate to a Detail route — but the Detail screen itself is stubbed/deferred (Stage 2). |

---

## 3. Acceptance Criteria

**Login**
- [ ] Given valid DummyJSON test credentials, when submitted, the user lands on Home within one request cycle.
- [ ] Given invalid credentials, an error message appears and the user remains on Login.
- [ ] Given empty username or password, the Login button does not trigger an API call and shows a validation message.
- [ ] Given a previously successful login and app restart, the user is taken directly to Home without re-entering credentials.
- [ ] Given a logout action from Home, the session is cleared and the user returns to Login; relaunching the app does not auto-login.

**Home**
- [ ] Given a successful `/products` fetch, at least the first page of products renders with image, title, price, rating.
- [ ] Given a scroll-to-end action, the next page of products loads and appends to the list.
- [ ] Given a pull-to-refresh action, the list resets to page 1 and reloads.
- [ ] Given an API failure, an error view with Retry is shown; tapping Retry re-attempts the fetch.
- [ ] Given zero products returned, an empty-state view is shown instead of a blank screen.

---

## 4. Dependencies

- DummyJSON API availability (`/auth/login`, `/products`) — external, mock, no auth key required beyond returned token.
- Secure/persistent storage mechanism for the auth token (to be finalized in Architecture Document — e.g. iOS Keychain via `Security` framework or `Keychain`-wrapping libraries).
- Navigation approach (to be finalized in Architecture/Engineering Document — e.g. SwiftUI `NavigationStack`) — needed even in Stage 1 to stub the Login → Home → (Detail placeholder) flow.
- Networking layer (to be finalized in Engineering Document — e.g. `URLSession` with `async/await`, or a lightweight wrapper).

---

## 5. Edge Cases

**Login**
- Network unreachable at submit time → show network error, allow retry.
- Slow response / timeout → loading state should not hang indefinitely; define a timeout and fallback error.
- Token present but expired/invalid on relaunch → app should detect failure on first authenticated call and force re-login rather than looping.
- Rapid double-tap on Login button → must not fire duplicate requests.

**Home**
- First page loads but subsequent page fetch fails → keep already-loaded items visible, show inline pagination error rather than clearing the list.
- Duplicate items across paginated responses → dedupe by product `id`.
- Very long product titles / missing thumbnail → layout must not break; fallback placeholder image.
- Logout triggered while a fetch is in-flight → in-flight request should be ignored/cancelled on unmount to avoid state updates after navigation.

---

## 6. Explicitly Out of Scope (Stage 1)
- Detail Screen implementation (navigation target stubbed only)
- Search / filter / sort on Home
- Cart, wishlist, or checkout functionality
- Profile/account management beyond logout
