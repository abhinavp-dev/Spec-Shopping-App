//
//  Color+AppColors.swift
//  Spec-Shopping
//
//  Design token reference: Docs/04-DESIGN-DOCUMENT.md § 1. Design Tokens
//

import SwiftUI

extension Color {
    /// `#1D9E75` — Primary teal. Used for buttons, links, and active states.
    static let appPrimary = Color("AppPrimary")

    /// `#107052` — Dark teal. Used as the gradient end on the login logo icon.
    static let appPrimaryDark = Color("AppPrimaryDark")

    /// `#D93025` — Error red. Used for error banners and validation states.
    static let appError = Color("AppError")

    /// `#F5A623` — Amber. Used for star-rating icons.
    static let appWarning = Color("AppWarning")
}
