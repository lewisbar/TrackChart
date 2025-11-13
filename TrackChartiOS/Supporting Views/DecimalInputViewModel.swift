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
    var selectedTimestamp: Date?

    var timestampDisplay: String {
        if let timestamp = selectedTimestamp {
            return timestamp.formatted(
                .dateTime
                    .day(.defaultDigits)
                    .month(.abbreviated)
                    .year(.defaultDigits)
                    .hour(.defaultDigits(amPM: .abbreviated))
                    .minute()
            )
        } else {
            return "Now"
        }
    }

    let keys = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]

    private let submit: (Double, Date) -> Void
    private let now: () -> Date

    init(initialValue: Double,
         initialTimestamp: Date?,
         submit: @escaping (Double, Date) -> Void,
         now: @escaping () -> Date = Date.init) {
        self.value = initialValue.formatted()
        self.selectedTimestamp = initialTimestamp
        self.submit = submit
        self.now = now
    }

    // MARK: Input
    func handleInput(_ key: String) {
        switch key {
        case "⌫":
            if value.trimmingPrefix("-").count > 1 {
                value.removeLast()
            } else {
                resetValue()
            }
        case ".":
            if !value.contains(".") { value += "." }
        default:
            if value == "0" { value = key }
            else if value == "-0" { value = "-" + key }
            else { value.append(key) }
        }
    }

    func toggleSign() {
        value = value.hasPrefix("-") ? String(value.dropFirst()) : "-" + value
    }

    // MARK: Timestamp
    func setTimestamp(_ date: Date) {
        selectedTimestamp = date
    }

    func clearTimestamp() {
        selectedTimestamp = nil
    }

    // MARK: Submit – reset everything
    func submitNumber() {
        if let doubleValue = Double(value) {
            let finalDate = selectedTimestamp ?? now()
            submit(doubleValue, finalDate)
        }
        resetValue()
        clearTimestamp()
    }

    private func resetValue() {
        value = "0"
    }
}
