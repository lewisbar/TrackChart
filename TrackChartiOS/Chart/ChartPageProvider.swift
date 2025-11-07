//
//  ChartPageProvider.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 31.10.25.
//

import Foundation

@MainActor
final class ChartPageProvider {
    static func pages(
        for raw: [ChartEntry],
        span: TimeSpan,
        aggregator: ChartDataProvider
    ) -> [ChartPage] {
        guard !raw.isEmpty else { return [] }

        let sorted = raw.sorted { $0.timestamp < $1.timestamp }
        let calendar = Calendar.current
        var pages: [ChartPage] = []

        var endDate = calendar.startOfDay(for: sorted.last!.timestamp)
        let count = span.componentCount

        while true {
            let startDate = calendar.date(
                byAdding: span.calendarComponent,
                value: -count,
                to: endDate
            ) ?? endDate

            let pageEntries = sorted.filter { $0.timestamp >= startDate && $0.timestamp < endDate }
            guard !pageEntries.isEmpty else { break }

            let aggregated = aggregator.processedEntries(from: pageEntries)
            let limited = Array(aggregated.prefix(60))

            let title = formatPageTitle(start: startDate, end: endDate, span: span)
            pages.append(ChartPage(
                entries: limited,
                span: span,
                title: title
            ))

            endDate = startDate
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
