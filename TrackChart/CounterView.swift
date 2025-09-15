//
//  CounterView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI

struct CounterView: View {
    @State private var count = 0
    let submitNewValue: (Int) -> Void
    let deleteLastValue: () -> Void

    var body: some View {
        HStack {
            deleteButton
            Spacer()
            minusButton
            countLabel
            plusButton
            Spacer()
            submitButton
        }
    }

    private var countLabel: some View {
        Text("\(count)")
            .font(Font(countLabelFont))
            .frame(minWidth: labelWidth)
            .padding(.horizontal, 10)
    }

    private var labelWidth: CGFloat {
        CGFloat(digitCount) * labelFontCharacterWidth
    }

    private var digitCount: Int {
        if count == 0 { return 1 } // Special case: 0 has 1 digit
        var digitCount = Int(log10(abs(Double(count))) + 1)
        if count < 0 {
            digitCount += 1  // Account for the minus sign
        }
        return digitCount
    }

    private var labelFontCharacterWidth: CGFloat { maxCharacterWidth(for: countLabelFont) }
    private var countLabelFont: UIFont { UIFont.preferredFont(forTextStyle: .title2) }

    private func maxCharacterWidth(for font: UIFont) -> CGFloat {
        let characters = "0123456789-" // Include digits and minus for negative numbers
        let maxWidth = characters.map { char in
            NSAttributedString(
                string: String(char),
                attributes: [.font: font]
            ).size().width
        }.max() ?? 0
        return ceil(maxWidth) // Round up for safety
    }

    private var plusButton: some View {
        Button(action: {
            count += 1
        }) {
            Image(systemName: "plus")
                .foregroundColor(.green)
                .font(.title2)
                .frame(minWidth: 24, minHeight: 24)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
        }
    }

    private var minusButton: some View {
        Button(action: {
            count -= 1
        }) {
            Image(systemName: "minus")
                .foregroundColor(.red)
                .font(.title2)
                .frame(minWidth: 24, minHeight: 24)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
        }
    }

    private var submitButton: some View {
        Button(action: {
            submitNewValue(count)
            count = 0
        }) {
            Image(systemName: "checkmark")
                .foregroundColor(.green)
                .font(.title2)
                .frame(minWidth: 24, minHeight: 24)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
        }
    }

    private var deleteButton: some View {
        Button(action: {
            deleteLastValue()
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.red)
                .font(.title2)
                .frame(minWidth: 24, minHeight: 24)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
        }
    }
}

#Preview {
    CounterView(submitNewValue: { _ in }, deleteLastValue: {})
//        .environment(\.layoutDirection, .rightToLeft)
}
