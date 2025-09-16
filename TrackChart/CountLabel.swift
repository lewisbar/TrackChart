//
//  CountLabel.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 16.09.25.
//

import SwiftUI

/// A label that keeps a consistent width for every digit count.
/// For example, it will have an equal width for the numbers 10 to 99.
struct CountLabel: View {
    let count: Int

    var body: some View {
        Text(countString)
            .font(swiftUIFont)
            .frame(minWidth: labelWidth)
        .padding(.horizontal, 10)
    }

    private var countString: String { "\(count)" }
    private var labelWidth: CGFloat { uiFont.width(of: countString) }

    @ScaledMetric(relativeTo: .title2) private var scaledFontSize: CGFloat = 22
    private var swiftUIFont: Font { .title2 }
    private var uiFont: UIFont { UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: scaledFontSize)) }
}

#Preview {
    CountLabel(count: 21)
}
