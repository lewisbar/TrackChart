//
//  ChartPageMapping.swift
//  Presentation
//
//  Created by Lennart Wisbar on 02.12.25.
//

import Foundation
import DataProcessing

public extension ChartPage {
    var chartViewPage: ChartViewPage {
        ChartViewPage(
            id: "\(span.rawValue)-\(dateRange.lowerBound.timeIntervalSince1970)",
            entries: viewEntries,
            title: title,
            dateRange: dateRange,
            aggregator: aggregator.viewAggregator,
            aggregate: aggregate,
            maxEntries: entries.filter { isMaxPositiveEntry($0) }.map(\.id),
            minEntries: entries.filter { isMinNegativeEntry($0) }.map(\.id)
        )
    }

    private var viewEntries: [ViewEntry] {
        entries.map(\.viewEntry)
    }
}

private extension ProcessedEntry {
    var viewEntry: ViewEntry {
        ViewEntry(id: id, value: value, timestamp: timestamp)
    }
}
