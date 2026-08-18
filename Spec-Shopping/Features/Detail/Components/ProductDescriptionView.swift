//
//  ProductDescriptionView.swift
//  Spec-Shopping
//
//  Component for displaying product description section.
//

import SwiftUI

struct ProductDescriptionView: View {
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .bold()
                .foregroundStyle(.primary)

            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProductDescriptionView(
        description: "The Essence Mascara Lash Princess is a popular mascara known for its volume and lengthening effects. It features a specially designed brush for easy application."
    )
    .padding()
}
