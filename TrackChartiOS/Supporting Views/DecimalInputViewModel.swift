//
//  DecimalInputViewModel.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 24.10.25.
//

import Foundation

@Observable
class DecimalInputViewModel {
    var value: String
    var timestamp: Date?
    let keys = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]
    private let submit: (Double, Date) -> Void
    private let now: () -> Date

    init(initialValue: Double, initialTimestamp: Date?, submit: @escaping (Double, Date) -> Void, now: @escaping () -> Date = Date.init) {
        self.value = initialValue.formatted()
        self.timestamp = initialTimestamp
        self.submit = submit
        self.now = now
    }

    func handleInput(_ key: String) {
        switch key {
        case "⌫":
            if value.trimmingPrefix("-").count > 1 {
                value.removeLast()
            } else {
                resetValue()
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
        if value.hasPrefix("-") {
            value = String(value.trimmingPrefix("-"))
        } else {
            value = "-" + value
        }
    }

    func submitNumber() {
        if let value = Double(value) {
            submit(value, timestamp ?? now())
        }
        resetValue()
    }

    private func resetValue() {
        value = "0"
    }
}
