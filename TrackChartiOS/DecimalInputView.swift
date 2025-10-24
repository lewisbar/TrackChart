//
//  DecimalInputView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 23.10.25.
//

import SwiftUI

struct DecimalInputView: View {
    let submitValue: (Double) -> Void
    let dismiss: () -> Void
    @State private var value: String = "0"

    var numericValue: Double {
        Double(value) ?? 0
    }

    var body: some View {
        VStack {
            displayLabel
                .padding(.top, 10)

            Divider()

            numberPad
                .padding(.horizontal)

            controlButtons
                .padding(.bottom, 15)
        }
        .background(Color(uiColor: .systemBackground))
    }

    private var displayLabel: some View {
        Text(value)
            .font(.largeTitle)
            .frame(maxHeight: 40)
    }

    private var numberPad: some View {
        VStack(spacing: 10) {
            ForEach([
                ["1", "2", "3"],
                ["4", "5", "6"],
                ["7", "8", "9"],
                [".", "0", "⌫"]
            ], id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        Button(action: { handleInput(key) }) {
                            Text(key)
                                .frame(maxWidth: .infinity, maxHeight: 80)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .font(.title2)
                        }
                    }
                }
            }
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 20) {
            Button("+/-") { toggleSign() }
                .buttonStyle(.bordered)

            Button("Submit") {
                submitNumber()
            }
            .buttonStyle(.borderedProminent)

            Button("Hide") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
    }

    private func handleInput(_ key: String) {
        switch key {
        case "⌫":
            if value.count > 1 {
                value.removeLast()
            } else {
                value = "0"
            }
        case ".":
            if !value.contains(".") {
                value += "."
            }
        default:
            if value == "0" {
                value = key
            } else if value == "-0" {
                value = "-" + key
            } else {
                value.append(key)
            }
        }
    }

    private func toggleSign() {
        if let number = Double(value) {
            let endsWithDecimalPoint = value.hasSuffix(".")
            let toggled = number * -1
            var formattedNumber = formatNumberWithoutTrailingZeros(toggled)
            if endsWithDecimalPoint {
                formattedNumber.append(".")
            }
            value = formattedNumber
        }
    }

    private func formatNumberWithoutTrailingZeros(_ number: Double) -> String {
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", number)
        } else {
            return String(number)
        }
    }

    private func submitNumber() {
        if let value = Double(value) {
            submitValue(value)
        }
        value = "0"
    }
}


#Preview {
    DecimalInputView(submitValue: { _ in }, dismiss: {})
}
