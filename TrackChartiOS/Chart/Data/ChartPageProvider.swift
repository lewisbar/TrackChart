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
        guard !sorted.isEmpty else { return [] }

        let calendar = Calendar.current
        let ranges = pageRanges(from: sorted, span: span, calendar: calendar)

        return ranges.compactMap { range in
            let pageEntries = sorted.filter { range.contains($0.timestamp) }
            guard !pageEntries.isEmpty else { return nil }

            let aggregated = aggregator.processedEntries(from: pageEntries)
            let title = formatPageTitle(start: range.lowerBound, end: range.upperBound, span: span)

            return ChartPage(
                entries: aggregated,
                span: span,
                title: title,
                periodStart: range.lowerBound
            )
        }
    }

    private static func formatPageTitle(start: Date, end: Date, span: TimeSpan) -> String {
        switch span {
        case .week:
            let first = start.formatted(DateStyle.weekStart)
            let last = end.formatted(DateStyle.weekEnd)
            return "\(first) – \(last)"
        case .month:
            return start.formatted(DateStyle.month)
        case .sixMonths:
            let first = start.formatted(DateStyle.sixMonths)
            let last = end.formatted(DateStyle.sixMonths)
            return "\(first) – \(last)"
        case .oneYear:
            return start.formatted(DateStyle.oneYear)
        }
    }
    
    private static func lastIncludedDay(from end: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: end) ?? end
    }

    private static func pageRanges(
        from entries: [ChartEntry],
        span: TimeSpan,
        calendar: Calendar = .current
    ) -> [ClosedRange<Date>] {
        guard let minDate = entries.min(by: { $0.timestamp < $1.timestamp })?.timestamp,
              let maxDate = entries.max(by: { $0.timestamp < $1.timestamp })?.timestamp
        else { return [] }

        let start = calendar.startOfPeriod(span, for: minDate)
        let end = calendar.endOfPeriod(span, for: maxDate)

        var ranges: [ClosedRange<Date>] = []
        var current = start

        while current <= end {
            let next = calendar.date(byAdding: span.calendarComponent, value: span.componentCount, to: current)!
            let rangeEnd = min(next.addingTimeInterval(-1), end) // inclusive
            ranges.append(current ... rangeEnd)
            current = next
        }

        return ranges
    }
}

private extension Calendar {
    func startOfPeriod(_ span: TimeSpan, for date: Date) -> Date {
        switch span {
        case .week:
            return self.date(from: self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        case .month:
            return self.date(from: self.dateComponents([.year, .month], from: date))!
        case .sixMonths:
            let components = self.dateComponents([.year, .month], from: date)
            let month = components.month!
            let startMonth = month <= 6 ? 1 : 7
            return self.date(from: DateComponents(year: components.year!, month: startMonth, day: 1))!
        case .oneYear:
            return self.date(from: self.dateComponents([.year], from: date))!
        }
    }

    func endOfPeriod(_ span: TimeSpan, for date: Date) -> Date {
        switch span {
        case .week:
            let start = startOfPeriod(span, for: date)
            return self.date(byAdding: .day, value: 6, to: start)!
        case .month:
            return self.date(byAdding: .month, value: 1, to: startOfPeriod(span, for: date))!.addingTimeInterval(-1)
        case .sixMonths:
            let start = startOfPeriod(span, for: date)
            return self.date(byAdding: .month, value: 6, to: start)!.addingTimeInterval(-1)
        case .oneYear:
            return self.date(byAdding: .year, value: 1, to: startOfPeriod(span, for: date))!.addingTimeInterval(-1)
        }
    }
}

private enum DateStyle {
    static let weekStart = Date.FormatStyle().day().month(.abbreviated)
    static let weekEnd = Date.FormatStyle().day().month(.abbreviated).year()
    static let month = Date.FormatStyle().month(.wide).year()
    static let sixMonths = Date.FormatStyle().month(.abbreviated).year()
    static let oneYear = Date.FormatStyle().year()
}
