//
//  ChartPageProvider.swift
//  DataProcessing
//
//  Created by Lennart Wisbar on 31.10.25.
//

import Foundation

public final class ChartPageProvider {
    public static func pages(
        for raw: [Entry],
        span: TimeSpan,
        aggregator: Aggregator,
        treatsMissingAsZero: Bool,
        calendar: Calendar = .current,
        now: Date = .now
    ) -> [ChartPage] {
        let provider = ChartDataProvider.preset(for: span, aggregator: aggregator, treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        return pages(for: raw, span: span, dataProvider: provider, calendar: calendar, now: now)
    }
    public static func pages(
        for raw: [Entry],
        span: TimeSpan,
        dataProvider: ChartDataProvider,
        calendar: Calendar = .current,
        now: Date = .now
    ) -> [ChartPage] {
        let sortedEntries = raw.sorted { $0.timestamp < $1.timestamp }
        let aggregatedEntries = dataProvider.processedEntries(from: sortedEntries)
        let ranges = pageRanges(from: aggregatedEntries, span: span, calendar: calendar, now: now)

        return ranges.compactMap { range -> ChartPage? in
            let pageEntries = aggregatedEntries.filter { range.contains($0.timestamp) }
            guard !pageEntries.isEmpty else { return nil }

            return ChartPage(
                entries: pageEntries,
                span: span,
                title: formatPageTitle(start: range.lowerBound, end: range.upperBound, span: span, calendar: calendar),
                aggregator: dataProvider.aggregator,
                aggregate: aggregated(values: pageEntries.map(\.value), using: dataProvider.aggregator)
            )
        }
    }

    private static func aggregated(values: [Double], using aggregator: Aggregator) -> Double {
        switch aggregator {
            case .sum:
            return values.reduce(0, +)
        case .average:
            return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        }
    }

    private static func formatPageTitle(start: Date, end: Date, span: TimeSpan, calendar: Calendar) -> String {
        let formatStyle = Date.FormatStyle(calendar: calendar)

        switch span {
        case .week:
            let lastDay = calendar.date(byAdding: .day, value: -1, to: end) ?? end
            let first = start.formatted(formatStyle.day().month(.abbreviated))
            let last = lastDay.formatted(formatStyle.day().month(.abbreviated).year())
            return "\(first) – \(last)"
        case .month:
            return start.formatted(formatStyle.month(.wide).year())
        case .year:
            return start.formatted(formatStyle.year())
        }
    }

    private static func pageRanges(
        from entries: [ProcessedEntry],
        span: TimeSpan,
        calendar: Calendar,
        now: Date
    ) -> [Range<Date>] {
        guard let minDate = entries.min(by: { $0.timestamp < $1.timestamp })?.timestamp else { return [] }

        guard let lastPageEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) else { return [] }

        var ranges: [Range<Date>] = []
        var currentEnd = lastPageEnd

        while true {
            guard let currentStart = calendar.date(
                byAdding: span.calendarComponent,
                value: -span.componentCount,
                to: currentEnd
            ) else { break }

            ranges.append(currentStart ..< currentEnd)
            currentEnd = currentStart

            if currentEnd <= minDate {
                break
            }
        }

        return ranges.reversed()
    }
}

private extension Calendar {
    func startOfPeriod(_ span: TimeSpan, for date: Date) -> Date {
        switch span {
        case .week:
            let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            return self.date(from: components) ?? date
        case .month:
            let components = self.dateComponents([.year, .month], from: date)
            return self.date(from: components) ?? date
        case .year:
            let components = self.dateComponents([.year], from: date)
            return self.date(from: components) ?? date
        }
    }
}
