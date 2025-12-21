//
//  ChartPage.swift
//  DataProcessing
//
//  Created by Lennart Wisbar on 30.10.25.
//

import Foundation

public struct ChartPage: Equatable {
    public let entries: [ProcessedEntry]
    public let span: TimeSpan
    public let title: String
    public let dateRange: ClosedRange<Date>
    public let aggregator: Aggregator
    public let aggregate: Double

    public init(entries: [ProcessedEntry], span: TimeSpan, title: String, aggregator: Aggregator, aggregate: Double) {
        self.entries = entries
        self.span = span
        self.title = title
        let dates = entries.map(\.timestamp)
        self.dateRange = (dates.min() ?? Date()) ... (dates.max() ?? Date())
        self.aggregator = aggregator
        self.aggregate = aggregate
    }

    public func isExtremum(_ entry: ProcessedEntry) -> Bool {
        isMaxPositiveEntry(entry) || isMinNegativeEntry(entry)
    }

    public func isMaxPositiveEntry(_ entry: ProcessedEntry) -> Bool {
        entry.value >= 0 && entry.value == entries.map(\.value).max()
    }

    public func isMinNegativeEntry(_ entry: ProcessedEntry) -> Bool {
        entry.value < 0 && entry.value == entries.map(\.value).min()
    }
}
