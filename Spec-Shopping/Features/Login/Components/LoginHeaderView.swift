//
//  LoginHeaderView.swift
//  Spec-Shopping
//

import SwiftUI

/// Brand logo, app name, and tagline displayed at the top of the Login screen.
struct LoginHeaderView: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.appPrimary, .appPrimaryDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.appPrimary.opacity(0.3), radius: 10, x: 0, y: 6)

                Image(systemName: "bag.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.white)
                    .accessibilityHidden(true)
            }

            Text("ShopLite")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.primary)

            Text("Sign in to your e-commerce account")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
        .padding(.bottom, 8)
    }
}

#Preview {
    LoginHeaderView()
}
