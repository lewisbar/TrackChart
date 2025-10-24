//
//  DecimalInputViewModel.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 24.10.25.
//

import Foundation

@Observable
class DecimalInputViewModel {
    var value = "0"
    let keys = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]
    private let submitValue: (Double) -> Void

    init(submitValue: @escaping (Double) -> Void) {
        self.submitValue = submitValue
    }

    func handleInput(_ key: String) {
        switch key {
        case "⌫":
            if value.trimmingPrefix("-").count > 1 {
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

    func toggleSign() {
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

    func submitNumber() {
        if let value = Double(value) {
            submitValue(value)
        }
        value = "0"
    }
}
