# Task Document — Stage 2 (Detail Screen)

## Project
ShopLite is a native iOS e-commerce application built with SwiftUI. This document covers **Stage 2 only**: the Detail Screen, which displays full product information after a user taps a product from the Home list.

> Stage 1 (Login + Home) is complete and documented separately in `01-TASK-DOCUMENT.md`.

---

## Stage Scope
This document covers **Detail Screen only**:
- Display product details (image, name, rating, description, price)
- Navigation (back to Home list)

> Search, filtering, related products, reviews, cart/checkout, and wishlist are explicitly out of scope.

---

## 1. Feature Scope

### 1.1 Detail Screen
Display full details of a single product, navigable from the Home product list. User can view product information and return to the list.

---

## 2. Functional Requirements

### 2.1 Detail Screen
| ID | Requirement |
|----|-------------|
| FR-3.1 | User taps a product row on Home screen → Detail screen pushes onto navigation stack. |
| FR-3.2 | Detail screen has a toolbar with a back button (labeled or icon); tapping it returns to Home without clearing the product list. |
| FR-3.3 | Detail screen displays the product's image (full width or fixed size, no cropping/distortion). |
| FR-3.4 | Detail screen displays product name (title), displayed prominently. |
| FR-3.5 | Detail screen displays product rating (numeric, with star icon if applicable). |
| FR-3.6 | Detail screen displays product description (full text, scrollable if long). |
| FR-3.7 | Detail screen displays product price (formatted as currency, e.g., $19.99). |
| FR-3.8 | Product data is fetched from DummyJSON `/products/{id}` endpoint on screen appear. |
| FR-3.9 | A loading indicator is shown while product data is being fetched. |
| FR-3.10 | If the fetch fails, an error message is shown with a "Retry" button; tapping Retry re-attempts the fetch. |
| FR-3.11 | If the product data is empty or malformed, a fallback message is shown ("Product not found"). |

---

## 3. Acceptance Criteria

**Detail Screen**
- [ ] Given a valid product ID from Home list tap, the Detail screen renders within one request cycle.
- [ ] Given product data loaded, all fields (image, name, rating, description, price) are visible and readable.
- [ ] Given a long product description, the screen is scrollable and description text does not overflow.
- [ ] Given back button tap, user returns to Home list with scroll position preserved (if possible).
- [ ] Given a network failure while fetching product, an error message and Retry button are shown.
- [ ] Given a Retry tap after error, the fetch is re-attempted and succeeds (or shows error again if still down).
- [ ] Given an invalid/missing product ID, a "Product not found" message is shown instead of blank screen.
- [ ] Given app is in dark mode, all text and images are readable on the dark background.

---

## 4. Dependencies

- DummyJSON API `/products/{id}` endpoint — external, mock, returns product object with all fields.
- Navigation system from Stage 1 (`NavigationStack`) — already in place, Detail screen is just another destination.
- Product model from Stage 1 — reused, no new model needed (existing `Product` struct covers all Detail fields).

---

## 5. Edge Cases

**Detail Screen**
- Product ID invalid / product does not exist on backend → show "Product not found" instead of blank/error.
- Network unreachable → show network error; Retry re-attempts.
- Slow network / timeout → loading indicator should not hang indefinitely; define a timeout (e.g., 10s).
- User navigates back from Detail while fetch is in-flight → in-flight request should be cancelled on deinit to avoid state updates after pop.
- Very long product name or description → text should wrap and layout should adapt (no overflow, no truncation without scrolling).
- Missing image URL or image load fails → show a placeholder/fallback icon instead of blank area.
- Rating is null/missing → show "N/A" or skip rating display.
- Price is 0 or missing → display "Price unavailable" or similar.

---

## Explicitly Out of Scope (Stage 2)
- Search, filter, or sort functionality
- Related products or "you might also like"
- User reviews or rating breakdown (stars distribution, review list)
- Add to cart, wishlist, or any transaction functionality
- Share product via social media or messaging
- Product comparison
- Zoom/pan image gallery (single image only, no gallery)
- Stock/availability status
- Product variants (size, color, etc.)

---

## Explicitly Out of Scope (Future Stages)
- Details for products beyond the basic set (image, name, rating, description, price)
- Checkout or payment flow
- Order history or user account details
- Push notifications, favorites, or personalization
