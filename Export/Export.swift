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

public struct CSVExport {
    public let content: String
    public let filename: String

    public init(content: String, filename: String) {
        self.content = content
        self.filename = filename
    }
}

/// Generates CSV with "timestamp,value" header.
/// The caller (Composition Root) must inject a configured Date.FormatStyle so the
/// Export module remains device-agnostic (timezone decided outside).
public func csvString(from entries: [ExportEntry], dateStyle: Date.FormatStyle) -> String {
    var lines: [String] = ["timestamp,value"]
    for entry in entries {
        let ts = entry.timestamp.formatted(dateStyle)
        lines.append("\(ts),\(entry.value)")
    }
    return lines.joined(separator: "\n")
}

/// Suggested filename for the exported CSV (sanitized topic name + date).
/// Caller controls the date if desired.
public func suggestedFilename(for topicName: String, at date: Date = .now) -> String {
    let datePart = date.formatted(
        .dateTime
            .year(.defaultDigits)
            .month(.twoDigits)
            .day(.twoDigits)
    )
    let safe = topicName
        .replacingOccurrences(of: "/", with: "-")
        .replacingOccurrences(of: ":", with: "-")
        .replacingOccurrences(of: "\\", with: "-")
    return "\(safe) - \(datePart).csv"
}
