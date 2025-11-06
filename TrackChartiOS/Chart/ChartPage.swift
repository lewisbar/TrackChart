//
//  ChartPage.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 30.10.25.
//

import Foundation

public struct ChartPage: Identifiable, Equatable {
    public let id = UUID()
    public let entries: [ProcessedEntry]
    public let span: TimeSpan
    public let title: String
    public let dateRange: ClosedRange<Date>

    public init(entries: [ProcessedEntry], span: TimeSpan, title: String) {
        self.entries = entries
        self.span = span
        self.title = title
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
