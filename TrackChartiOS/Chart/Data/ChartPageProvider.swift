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
        aggregator: ChartDataProvider,
        calendar: Calendar = .current
    ) -> [ChartPage] {
        let sorted = raw.sorted { $0.timestamp < $1.timestamp }
        guard !sorted.isEmpty else { return [] }

        let ranges = pageRanges(from: sorted, span: span, calendar: calendar)

        return ranges.compactMap { range in
            let pageEntries = sorted.filter { range.contains($0.timestamp) }
            guard !pageEntries.isEmpty else { return nil }

            let aggregated = aggregator.processedEntries(from: pageEntries)
            let title = formatPageTitle(start: range.lowerBound, end: range.upperBound, span: span, calendar: calendar)

            return ChartPage(
                entries: aggregated,
                span: span,
                title: title,
                periodStart: range.lowerBound
            )
        }
    }

    private static func formatPageTitle(start: Date, end: Date, span: TimeSpan, calendar: Calendar) -> String {
        let formatStyle = Date.FormatStyle(calendar: calendar)

        switch span {
        case .week:
            let lastDay = calendar.date(byAdding: .second, value: -1, to: end) ?? end
            let first = start.formatted(formatStyle.day().month(.abbreviated))
            let last = lastDay.formatted(formatStyle.day().month(.abbreviated).year())
            return "\(first) – \(last)"
        case .month:
            return start.formatted(formatStyle.month(.wide).year())
        case .oneYear:
            return start.formatted(formatStyle.year())
        }
    }

    private static func pageRanges(
        from entries: [ChartEntry],
        span: TimeSpan,
        calendar: Calendar
    ) -> [Range<Date>] {
        guard let minDate = entries.min(by: { $0.timestamp < $1.timestamp })?.timestamp,
              let maxDate = entries.max(by: { $0.timestamp < $1.timestamp })?.timestamp
        else { return [] }

        let start = calendar.startOfPeriod(span, for: minDate)
        let endPeriodStart = calendar.startOfPeriod(span, for: maxDate)

        var ranges: [Range<Date>] = []
        var current = start

        while current <= endPeriodStart {
            guard let next = calendar.date(
                byAdding: span.calendarComponent,
                value: span.componentCount,
                to: current
            ) else { break }

            ranges.append(current ..< next)
            current = next
        }

        return ranges
    }
}

private extension Calendar {
    func startOfPeriod(_ span: TimeSpan, for date: Date) -> Date {
        switch span {
        case .week:
            // Use yearForWeekOfYear and weekOfYear for proper week calculation
            let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            return self.date(from: components) ?? date
        case .month:
            let components = self.dateComponents([.year, .month], from: date)
            return self.date(from: components) ?? date
        case .oneYear:
            let components = self.dateComponents([.year], from: date)
            return self.date(from: components) ?? date
        }
    }
}
