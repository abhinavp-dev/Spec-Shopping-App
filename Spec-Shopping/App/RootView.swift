//
//  RootView.swift
//  Spec-Shopping
//

import SwiftUI

/// Root container view deciding between LoginView and HomeView based on SessionStore state.
struct RootView: View {
    @Bindable var sessionStore: SessionStore

    var body: some View {
        Group {
            if sessionStore.isLoggedIn {
                HomeView(onLogout: {
                    sessionStore.logout()
                })
            } else {
                LoginView(onLoginSuccess: {
                    sessionStore.loginCompleted()
                })
            }
        }
        .animation(.easeInOut(duration: 0.25), value: sessionStore.isLoggedIn)
    }
}

#Preview {
    RootView(sessionStore: SessionStore())
}
