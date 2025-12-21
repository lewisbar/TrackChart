//
//  DecimalInputViewModel.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 24.10.25.
//

import Foundation

@Observable
public class DecimalInputViewModel {
    public var value: String
    public var selectedTimestamp: Date?

    public var timestampDisplay: String {
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
            return nowDescription
        }
    }

    private static let decimalSeparator: String = Locale.current.decimalSeparator ?? "."

    public let keys = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [decimalSeparator, "0", "⌫"]
    ]

    private let submit: (Double, Date) -> Void
    private let now: () -> Date
    private let nowDescription: String

    public init(
        initialValue: Double,
        initialTimestamp: Date?,
        submit: @escaping (Double, Date) -> Void,
        now: @escaping () -> Date = Date.init,
        nowDescription: String
    ) {
        self.value = initialValue.formatted()
        self.selectedTimestamp = initialTimestamp
        self.submit = submit
        self.now = now
        self.nowDescription = nowDescription
    }

    // MARK: Input
    public func handleInput(_ key: String) {
        switch key {
        case "⌫":
            if value.trimmingPrefix("-").count > 1 {
                value.removeLast()
            } else {
                resetValue()
            }
        case Self.decimalSeparator:
            if !value.contains(Self.decimalSeparator) { value += Self.decimalSeparator }
        default:
            if value == "0" { value = key }
            else if value == "-0" { value = "-" + key }
            else { value.append(key) }
        }
    }

    public func toggleSign() {
        value = value.hasPrefix("-") ? String(value.dropFirst()) : "-" + value
    }

    // MARK: Timestamp
    public func setTimestamp(_ date: Date) {
        selectedTimestamp = date
    }

    public func clearTimestamp() {
        selectedTimestamp = nil
    }

    // MARK: Submit – reset everything
    public func submitNumber(onSuccess: (Double) -> Void = { _ in }) {
        if let doubleValue = try? FloatingPointFormatStyle<Double>().parseStrategy.parse(value) {
            let finalDate = selectedTimestamp ?? now()
            submit(doubleValue, finalDate)

            // Notify the view of the exact submitted value
            onSuccess(doubleValue)
        }
        resetValue()
        clearTimestamp()
    }

    private func resetValue() {
        value = "0"
    }
}
