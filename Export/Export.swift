//
//  Export.swift
//  Export
//
//  Created by Lennart Wisbar on 16.06.26.
//

import Foundation

public struct ExportEntry: Sendable {
    public let timestamp: Date
    public let value: Double

    public init(timestamp: Date, value: Double) {
        self.timestamp = timestamp
        self.value = value
    }
}

/// Generates CSV with "timestamp,value" header.
/// The caller (Composition Root) must inject a configured DateFormatter so the
/// Export module remains device-agnostic (timezone/locale decided outside).
public func csvString(from entries: [ExportEntry], dateFormatter: DateFormatter) -> String {
    var lines: [String] = ["timestamp,value"]
    for entry in entries {
        let ts = dateFormatter.string(from: entry.timestamp)
        lines.append("\(ts),\(entry.value)")
    }
    return lines.joined(separator: "\n")
}

/// Suggested filename for the exported CSV (sanitized topic name + date).
/// The date part uses a simple format; caller controls any timezone via the provided date if needed.
public func suggestedFilename(for topicName: String, at date: Date = .now) -> String {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    let datePart = df.string(from: date)
    let safe = topicName
        .replacingOccurrences(of: "/", with: "-")
        .replacingOccurrences(of: ":", with: "-")
        .replacingOccurrences(of: "\\", with: "-")
    return "\(safe) - \(datePart).csv"
}
