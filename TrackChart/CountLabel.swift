//
//  CountLabel.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 16.09.25.
//

import SwiftUI

/// A label that keeps a consistent width for every digit count.
/// For example, it will have an equal width for the numbers 10 to 99.
/// A minus prefix for negative numbers will also be taken into account.
struct CountLabel: View {
    let count: Int
    
    var body: some View {
        Text("\(count)")
            .font(Font(countLabelFont))
            .frame(minWidth: labelWidth)
        .padding(.horizontal, 10)
    }

    private var countLabelFont: UIFont { UIFont.preferredFont(forTextStyle: .title2) }

    private var labelWidth: CGFloat {
        CGFloat(count.numberOfDigits()) * countLabelFont.maxCharacterWidth()
    }
}

#Preview {
    CountLabel(count: 21)
}
