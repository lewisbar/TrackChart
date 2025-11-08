//
//  ChartPage.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 30.10.25.
//

import Foundation

public struct ChartPage: Identifiable, Equatable {
    public var id: String {
        // ID based on the start of the time period this page represents
        "\(span.title)-\(periodStart.timeIntervalSince1970)"
    }

    public let entries: [ProcessedEntry]
    public let span: TimeSpan
    public let title: String
    public let dateRange: ClosedRange<Date>
    public let periodStart: Date // The start of this time period

    public init(entries: [ProcessedEntry], span: TimeSpan, title: String, periodStart: Date) {
        self.entries = entries
        self.span = span
        self.title = title
        self.periodStart = periodStart
        let dates = entries.map(\.timestamp)
        self.dateRange = (dates.min() ?? Date()) ... (dates.max() ?? Date())
    }

    public func isExtremum(_ entry: ProcessedEntry) -> Bool {
        isMaxPositiveEntry(entry) || isMinNegativeEntry(entry)
    }

    public func isMaxPositiveEntry(_ entry: ProcessedEntry) -> Bool {
        entry.value > 0 && entry.value == entries.map(\.value).max()
    }

    public func isMinNegativeEntry(_ entry: ProcessedEntry) -> Bool {
        entry.value < 0 && entry.value == entries.map(\.value).min()
    }
}
