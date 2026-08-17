//
//  Spec_ShoppingApp.swift
//  Spec-Shopping
//

import SwiftUI

@main
struct Spec_ShoppingApp: App {
    @State private var sessionStore = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView(sessionStore: sessionStore)
        }
    }
}
