//
//  ChartViewPage.swift
//  Presentation
//
//  Created by Lennart Wisbar on 01.12.25.
//

import Foundation

public struct ChartViewPage: Identifiable, Equatable {
    public let id: String
    public let entries: [ViewEntry]
    public let title: String
    public let dateRange: ClosedRange<Date>
    public let aggregator: ViewAggregator
    public let aggregate: Double
    public let maxEntries: [UUID]
    public let minEntries: [UUID]

    public init(id: String, entries: [ViewEntry], title: String, dateRange: ClosedRange<Date>, aggregator: ViewAggregator, aggregate: Double, maxEntries: [UUID], minEntries: [UUID]) {
        self.id = id
        self.entries = entries
        self.title = title
        self.dateRange = dateRange
        self.aggregator = aggregator
        self.aggregate = aggregate
        self.maxEntries = maxEntries
        self.minEntries = minEntries
    }

    public func isExtremum(_ entry: ViewEntry) -> Bool {
        isMaxEntry(entry) || isMinEntry(entry)
    }

    public func isMaxEntry(_ entry: ViewEntry) -> Bool {
        maxEntries.contains(entry.id)
    }

    public func isMinEntry(_ entry: ViewEntry) -> Bool {
        minEntries.contains(entry.id)
    }
}
