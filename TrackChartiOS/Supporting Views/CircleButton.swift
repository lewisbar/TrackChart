//
//  CircleButton.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 16.09.25.
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
                .foregroundStyle(color)
                .font(.title2)
                .frame(minWidth: baseSize, minHeight: baseSize)
                .padding(10)
                .background(background)
        }
    }
    
    @ViewBuilder
    private var background: some View {
        if #available(iOS 26, *) {
            glassBackground
        } else {
            baseBackground
        }
    }
    
    private var baseBackground: some View {
        Circle().fill(.white).shadow(radius: 2)
    }
    
    @available(iOS 26, *)
    private var glassBackground: some View {
        baseBackground.glassEffect()
    }
}

#Preview {
    CircleButton(action: {}, image: Image(systemName: "checkmark"), color: .green)
}
