# Design Document — ShopLite (iOS / SwiftUI)

## Scope
This is a **living document** defining how each feature behaves from the user's perspective — UI flow, navigation, interactions, validations, and visual design — before implementation. Covers Login + Home for Stage 1.

---

## 1. Design Tokens

| Token | Value | Usage |
|---|---|---|
| `color.primary` | `#1D9E75` (teal) | Primary buttons, links, active states |
| `color.background` | `#FFFFFF` (light) / system background (dark mode) | Screen backgrounds |
| `color.surface` | `#F5F5F7` | Cards, list rows |
| `color.textPrimary` | `#111111` / system label | Main text |
| `color.textSecondary` | `#6E6E73` / system secondary label | Subtext, captions |
| `color.error` | `#D93025` | Error messages, validation states |
| `color.success` | `#188038` | Success confirmation (if used) |
| `spacing.xs` | 4pt | Tight gaps |
| `spacing.sm` | 8pt | Default inner padding |
| `spacing.md` | 16pt | Standard screen margins |
| `spacing.lg` | 24pt | Section spacing |
| `radius.default` | 12pt | Card / input corner radius |
| `radius.button` | 10pt | Button corner radius |

All colors use `Color` assets in `Assets.xcassets` (not hardcoded hex in views), with light/dark variants defined via system semantic colors where possible.

---

## 2. Typography

Uses the **SF Pro** system font via SwiftUI's Dynamic Type text styles (for accessibility — no fixed point sizes):

| Style | SwiftUI Font | Usage |
|---|---|---|
| Large Title | `.largeTitle`, bold | Screen titles (e.g. "ShopLite" on Login) |
| Title | `.title2`, semibold | Section headers |
| Body | `.body` | Product titles, general text |
| Callout | `.callout` | Secondary product info (price, rating) |
| Caption | `.caption` | Helper text, error messages |

All text respects Dynamic Type scaling — no `.fixedSize()` overrides on body copy.

---

## 3. Color Theming

- Supports **Light and Dark mode** natively via SwiftUI semantic colors / asset catalog variants.
- `color.primary` (teal accent) stays consistent across both modes; backgrounds/surfaces adapt automatically.
- Error states always use `color.error` regardless of mode, with sufficient contrast checked against both backgrounds.

---

## 4. Aesthetics

- Clean, minimal e-commerce look — generous white space, card-based product rows, single accent color.
- Rounded corners (per `radius` tokens) on inputs, buttons, and product cards.
- Subtle shadow on product cards (`opacity 0.08`, `radius 4`) for depth without heaviness.
- SF Symbols used for iconography (e.g. `person.circle` on Login, `cart` placeholder if needed later) — no custom icon set for Stage 1.

---

## 5. Screen: Login

### UI Flow
1. App launches → `RootView` checks session state.
2. No valid session → Login screen shown.
3. User enters username + password → taps "Log In".
4. Loading state (button shows spinner, disabled) while request is in-flight.
5. Success → navigates to Home.
6. Failure → inline error banner appears above the form; fields remain populated (except password, which is cleared for security).

### Layout
- Centered vertical stack: app logo/title → username field → password field (secure entry) → error message (conditional) → "Log In" button.
- Username field: standard `TextField`, `autocapitalization: none`, `keyboardType: default`.
- Password field: `SecureField`, with a show/hide toggle (eye icon) — optional nice-to-have, not blocking.

### Validation
- Both fields required; "Log In" button is **disabled** (not just error-on-tap) until both fields are non-empty — matches Task Doc's FR-1.9.
- No client-side password complexity rules (DummyJSON doesn't require it) — validation is purely "non-empty."
- Server-side validation errors (401) surface as a single banner: "Invalid username or password."
- Network/timeout errors surface as: "Something went wrong. Please try again."

### Functional Interactions
- Return key on username field moves focus to password field.
- Return key on password field triggers the same action as tapping "Log In" (if valid).
- Button tap is debounced / disabled during in-flight request (prevents double submission per Task Doc edge case).

---

## 6. Screen: Home (Products)

### UI Flow
1. On appear, `HomeViewModel` triggers initial fetch (page 1).
2. Loading indicator (centered spinner) shown until first page resolves.
3. Success with data → product list renders.
4. Success with zero items → empty-state view ("No products found").
5. Failure → full-screen error view with message + "Retry" button.
6. User scrolls near the bottom → next page silently loads, appended to the list (small inline spinner at list bottom during this fetch — does not block already-visible content).
7. Pull down from top → refresh triggers, list resets to page 1.
8. Logout button (top-right nav bar icon, e.g. `rectangle.portrait.and.arrow.right`) → confirms nothing (immediate action, per Task Doc) → clears session → returns to Login.

### Layout
- Navigation bar: title "Products", logout icon button trailing.
- List (`List` or `LazyVStack` in a `ScrollView`) of `ProductRowView`:
  - Leading: thumbnail image (`AsyncImage`, fixed square frame, placeholder while loading, fallback icon on failure).
  - Trailing (stacked vertically): product title (`.body`, 1–2 lines, truncated with ellipsis), price (`.callout`, bold), rating (small star icon + numeric value, `.caption`).
- Row is tappable (whole row is a `NavigationLink` target) → pushes toward Detail route (stubbed placeholder screen for Stage 1, per Task Doc FR-2.9).

### Validation / States
- Loading (initial): centered `ProgressView`.
- Loading (pagination): small `ProgressView` appended at list bottom, list content stays visible.
- Error (initial): icon + "Couldn't load products" + "Retry" button, centered.
- Error (pagination): non-blocking inline row at list bottom — "Couldn't load more — Retry" — rest of list untouched, per Task Doc edge case.
- Empty: icon + "No products found" centered message.

### Functional Interactions
- Pull-to-refresh uses native SwiftUI `.refreshable`.
- Infinite scroll triggers pagination fetch when the last visible row is within ~3 items of the end of the currently loaded list.
- Tapping logout is immediate (no confirmation dialog) — matches Task Doc, can be revisited if user testing suggests otherwise.

---

## 7. Screen: Detail (Product Details)

### UI Flow
1. User taps a product row on Home → Detail screen pushes onto NavigationStack.
2. DetailView appears with loading indicator while product data is fetched from `/products/{id}`.
3. Product data loads → detail content renders: image, title, rating, price, description.
4. User scrolls to read full description if text is long.
5. Back button (toolbar) pops Detail, returns to Home list with scroll position preserved.

### Layout
- Toolbar (top safe area): back button (labeled "Back" or arrow icon) + title (optional, can show product name or empty).
- ScrollView for long content:
  - Product image (full width, aspect ratio preserved, no cropping).
  - Product title (`.title2`, bold, margin around).
  - Product rating (star icon + numeric rating, `.callout`).
  - Product price (`.title`, bold, teal accent if applicable, formatted currency).
  - Divider (optional, subtle).
  - Product description (`.body`, wrapped text, scrollable if long).
  - Extra padding at bottom for safe area.

### Validation / States
- Loading: centered `ProgressView` while fetch is in-flight.
- Success: all fields (image, title, rating, price, description) rendered.
- Error (fetch failed): centered error icon + message ("Couldn't load product") + "Retry" button; tapping Retry re-attempts fetch.
- Error (invalid/missing product): centered message ("Product not found") with back button to return to Home.
- Image load failure: placeholder icon (e.g., 📦) shown instead of blank area.

### Functional Interactions
- Toolbar back button: taps pop DetailView, returns to HomeView (NavigationStack handles this).
- Retry button (on error): re-attempts the `/products/{id}` fetch.
- Scroll: description scrolls smoothly if it exceeds screen height; image stays fixed or scrolls with content (your preference — fixed is simpler).
- Text selection: description text may be selectable (native SwiftUI behavior, no special handling).

### Dark Mode
- All text and backgrounds adapt to light/dark mode using semantic colors (same as Stage 1).
- Image is displayed as-is (no inversion or filters).
- Error/loading states use same colors as Home screen.

---

## Changelog
- **Stage 1 (Login + Home):** Design tokens, typography, theming, and full screen-level design specified as above.
- **Stage 2 (Detail Screen):** Added Detail screen layout (image, title, rating, price, description), state transitions (loading, success, error), and interaction flows.