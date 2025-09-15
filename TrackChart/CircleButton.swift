//
//  CircleButton.swift
//  TrackChart
//
//  Created by LennartWisbar on 16.09.25.
//

import SwiftUI

struct CircleButton: View {
    let action: () -> Void
    let image: Image
    let color: Color
    @ScaledMetric(relativeTo: .title2) var baseSize: CGFloat = 24

    var body: some View {
        Button(action: action) {
            image
                .foregroundColor(color)
                .font(.title2)
                .frame(minWidth: baseSize, minHeight: baseSize)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
        }
    }
}

#Preview {
    CircleButton(action: {}, image: Image(systemName: "checkmark"), color: .green)
}
