//
//  ChartPageProvider.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 31.10.25.
//

import Presentation

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

            let title = formatPageTitle(start: startDate, end: endDate, span: span, calendar: calendar)
            pages.append(ChartPage(
                entries: limited,
                span: span,
                title: title
            ))

            endDate = startDate
        }

        return pages.reversed()
    }

    private static func formatPageTitle(
        start: Date, end: Date, span: TimeSpan, calendar: Calendar
    ) -> String {
        let fmt = DateFormatter()
        fmt.calendar = calendar
        fmt.locale = .current

        switch span {
        case .week:
            fmt.dateFormat = "MMM d"
            let startStr = fmt.string(from: start)
            fmt.dateFormat = "d, yyyy"
            let endExcl = calendar.date(byAdding: .day, value: -1, to: end) ?? end
            return "\(startStr) – \(fmt.string(from: endExcl))"
        case .month:
            fmt.dateFormat = "MMMM yyyy"
            return fmt.string(from: start)
        case .sixMonths:
            fmt.dateFormat = "MMM yyyy"
            let endExcl = calendar.date(byAdding: .day, value: -1, to: end) ?? end
            return "\(fmt.string(from: start)) – \(fmt.string(from: endExcl))"
        case .oneYear:
            fmt.dateFormat = "yyyy"
            return fmt.string(from: start)
        }
    }
}
