//
//  ChartPageProvider.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 31.10.25.
//

import Foundation

@MainActor
public final class ChartPageProvider {
    public static func pages(
        for raw: [ChartEntry],
        span: TimeSpan,
        aggregator: ChartDataProvider
    ) -> [ChartPage] {
        let sorted = raw.sorted { $0.timestamp < $1.timestamp }
        guard let lastEntry = sorted.last else { return [] }
        let calendar = Calendar.current
        var pages: [ChartPage] = []

        // End date should be the start of the day AFTER the last entry
        // This ensures the last entry is included in the range
        let endDate = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: lastEntry.timestamp)
        ) ?? calendar.startOfDay(for: lastEntry.timestamp)

        let count = span.componentCount
        var currentEndDate = endDate

        // Keep going as long as we have a valid start date
        while let startDate = calendar.date(
            byAdding: span.calendarComponent,
            value: -count,
            to: currentEndDate
        ) {
            let pageEntries = sorted.filter {
                $0.timestamp >= startDate && $0.timestamp < currentEndDate
            }

            // Break if we've gone past all entries
            guard !pageEntries.isEmpty else { break }

            let aggregated = aggregator.processedEntries(from: pageEntries)

            let title = formatPageTitle(start: startDate, end: currentEndDate, span: span)
            pages.append(ChartPage(
                entries: aggregated,
                span: span,
                title: title
            ))

            currentEndDate = startDate
        }

        return pages.reversed()
    }

    private static func formatPageTitle(start: Date, end: Date, span: TimeSpan) -> String {
        switch span {
        case .week:
            let first = start.formatted(DateStyle.weekStart)
            let last = lastIncludedDay(from: end).formatted(DateStyle.weekEnd)
            return "\(first) – \(last)"
        case .month:
            return start.formatted(DateStyle.month)
        case .sixMonths:
            let first = start.formatted(DateStyle.sixMonths)
            let last = lastIncludedDay(from: end).formatted(DateStyle.sixMonths)
            return "\(first) – \(last)"
        case .oneYear:
            return start.formatted(DateStyle.oneYear)
        }
    }

    private static func lastIncludedDay(from end: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: end) ?? end
    }
}

private enum DateStyle {
    static let weekStart = Date.FormatStyle().day().month(.abbreviated)
    static let weekEnd = Date.FormatStyle().day().month(.abbreviated).year()
    static let month = Date.FormatStyle().month(.wide).year()
    static let sixMonths = Date.FormatStyle().month(.abbreviated).year()
    static let oneYear = Date.FormatStyle().year()
}
