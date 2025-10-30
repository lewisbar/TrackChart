//
//  TimeSpanPager.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 30.10.25.
//

import Presentation

struct TimeSpanPager {
    static func pages(for raw: [ChartEntry]) -> [ChartPage] {
        guard !raw.isEmpty else { return [] }

        let sorted = raw.sorted { $0.timestamp < $1.timestamp }
        let calendar = Calendar.current
        var pages: [ChartPage] = []

        // Start from the **most recent** entry and walk backwards
        guard let lastEntry = sorted.last?.timestamp else { return []}
        var currentEnd = calendar.startOfDay(for: lastEntry)

        for span in TimeSpan.allCases {
            let (pageEntries, nextEnd) = aggregateSpan(
                span: span,
                entries: sorted,
                endDate: currentEnd,
                calendar: calendar
            )
            guard !pageEntries.isEmpty else { continue }

            pages.append(ChartPage(
                entries: pageEntries,
                span: span
            ))
            currentEnd = nextEnd
        }

        return pages
    }

    // MARK: – Aggregation per span
    private static func aggregateSpan(
        span: TimeSpan,
        entries: [ChartEntry],
        endDate: Date,
        calendar: Calendar
    ) -> (entries: [ProcessedEntry], nextEnd: Date) {

        let component = span.calendarComponent
        let count = span.componentCount

        // Define the *end* of this page
        let pageEnd = calendar.date(
            byAdding: component,
            value: -count,
            to: endDate
        ) ?? endDate

        // Filter entries that belong to this page
        let pageEntries = entries.filter {
            $0.timestamp >= pageEnd && $0.timestamp < endDate
        }

        guard !pageEntries.isEmpty else {
            // No data → skip page, move to previous span
            let next = calendar.date(byAdding: component, value: -count, to: pageEnd) ?? pageEnd
            return ([], next)
        }

        // Choose aggregation level that fits into `maxPoints`
        let provider = bestProvider(for: span, entries: pageEntries, calendar: calendar)
        let aggregated = provider.processedEntries(from: pageEntries)

        // Safety: never exceed 60 points
        let limited = Array(aggregated.prefix(60))

        let nextEnd = pageEnd
        return (limited, nextEnd)
    }

    // MARK: – Choose the right aggregation for the span
    private static func bestProvider(
        for span: TimeSpan,
        entries: [ChartEntry],
        calendar: Calendar
    ) -> ChartDataProvider {

        let days = calendar.dateComponents([.day], from: entries.first!.timestamp, to: entries.last!.timestamp).day ?? 0

        switch span {
        case .week:
            return days <= 7 ? .raw : .dailySum
        case .month:
            return days <= 31 ? .dailySum : .weeklySum
        case .sixMonths:
            return days <= 182 ? .weeklySum : .monthlySum
        case .oneYear:
            return days <= 365 ? .weeklySum : .monthlySum
        case .twoYears, .threeYears, .fourYears, .fiveYears:
            return .monthlySum
        }
    }
}
