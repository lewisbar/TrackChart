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

    var body: some View {
        Button(action: action) {
            image
                .foregroundColor(color)
                .font(.title2)
                .frame(minWidth: 24, minHeight: 24)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
        }
    }
}

#Preview {
    CircleButton(action: {}, image: Image(systemName: "checkmark"), color: .green)
}
