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
            let formattedStart = ChartPageDateFormatter.weekStart.string(from: start)
            let lastIncludedDay = Calendar.current.date(byAdding: .day, value: -1, to: end) ?? end
            return "\(formattedStart) – \(ChartPageDateFormatter.weekEnd.string(from: lastIncludedDay))"
        case .month:
            return ChartPageDateFormatter.month.string(from: start)
        case .sixMonths:
            let lastIncludedDay = Calendar.current.date(byAdding: .day, value: -1, to: end) ?? end
            return "\(ChartPageDateFormatter.sixMonths.string(from: start)) – \(ChartPageDateFormatter.sixMonths.string(from: lastIncludedDay))"
        case .oneYear:
            return ChartPageDateFormatter.oneYear.string(from: start)
        }
    }
}

private enum ChartPageDateFormatter {
    static let weekStart: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = .current
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    static let weekEnd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = .current
        formatter.dateFormat = "d, yyyy"
        return formatter
    }()

    static let month: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = .current
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    static let sixMonths: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = .current
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()

    static let oneYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = .current
        formatter.dateFormat = "yyyy"
        return formatter
    }()
}
