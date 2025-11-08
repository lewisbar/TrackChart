//
//  CardModifier.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 10.10.25.
//

import SwiftUI

struct CardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let shadowRadius: CGFloat
    let padding: CGFloat?

    init(cornerRadius: CGFloat, backgroundColor: Color, shadowRadius: CGFloat, padding: CGFloat?) {
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.shadowRadius = shadowRadius
        self.padding = padding
    }

    func body(content: Content) -> some View {
        content
            .padding(.all, padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .shadow(radius: shadowRadius)
            )
    }
}

extension View {
    func card(
        cornerRadius: CGFloat = 10,
        backgroundColor: Color = Color(uiColor: .systemBackground),
        shadowRadius: CGFloat = 5,
        padding: CGFloat? = nil
    ) -> some View {
        modifier(
            CardModifier(
                cornerRadius: cornerRadius,
                backgroundColor: backgroundColor,
                shadowRadius: shadowRadius,
                padding: padding
            )
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        Image(systemName: "figure.wave")
            .foregroundStyle(.orange)

        Text("Hello world!")
    }
    .font(.largeTitle)
    .card()
}
