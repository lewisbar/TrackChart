//
//  ViewTimeSpanAdapter.swift
//  Presentation
//
//  Created by Lennart Wisbar on 02.12.25.
//

import Foundation
import DataProcessing

public extension ViewTimeSpan {
    func pages(for topic: ViewTopic, calendar: Calendar = .current, now: Date = .now) -> [ChartViewPage] {
        ChartPageProvider.pages(
            for: topic.entries.map(\.rawEntry),
            span: span,
            aggregator: topic.aggregator.aggregator,
            treatsMissingAsZero: topic.treatsMissingAsZero,
            calendar: calendar,
            now: now
        ).map(\.chartViewPage)
    }

    private var span: TimeSpan {
        switch self {
        case .week: .week
        case .month: .month
        case .year: .year
        }
    }
}

private extension ViewEntry {
    var rawEntry: Entry {
        Entry(value: value, timestamp: timestamp)
    }
}
