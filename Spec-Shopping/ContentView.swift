//
//  ContentView.swift
//  Spec-Shopping
//

import SwiftUI

struct ContentView: View {
    @State private var sessionStore = SessionStore()

    var body: some View {
        RootView(sessionStore: sessionStore)
    }
}

#Preview {
    ContentView()
}
