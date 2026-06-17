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
/// Timestamps are formatted as "yyyy-MM-dd HH:mm:ss" (fixed, no locale commas or other separators).
/// A UTF-8 BOM is prefixed so spreadsheet apps (Numbers, Excel) reliably detect UTF-8.
/// Caller provides the timeZone (e.g. .current) so the wall-clock time matches the user's device.
public func csvString(from entries: [ExportEntry], timeZone: TimeZone) -> String {
    var lines: [String] = ["timestamp,value"]
    let iso = Date.ISO8601FormatStyle(timeZone: timeZone)
        .year()
        .month()
        .day()
        .dateSeparator(.dash)
        .time(includingFractionalSeconds: false)
        .timeSeparator(.colon)
        .dateTimeSeparator(.space)
    for entry in entries {
        let ts = entry.timestamp.formatted(iso)
        lines.append("\(ts),\(entry.value)")
    }
    let body = lines.joined(separator: "\n")
    return "\u{FEFF}" + body
}

/// Suggested filename for the exported CSV (sanitized topic name + date).
/// Uses a fixed date format so the filename is consistent and safe across locales
/// (avoids locale-specific separators like "/" that would break the filename on some systems).
/// Caller controls the date if desired.
public func suggestedFilename(for topicName: String, at date: Date = .now) -> String {
    let datePart = date.formatted(
        Date.ISO8601FormatStyle()
            .year()
            .month()
            .day()
            .dateSeparator(.dash)
    )
    let safe = topicName
        .replacingOccurrences(of: "/", with: "-")
        .replacingOccurrences(of: ":", with: "-")
        .replacingOccurrences(of: "\\", with: "-")
    return "\(safe) - \(datePart).csv"
}
