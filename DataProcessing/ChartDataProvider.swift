//
//  ChartDataProvider.swift
//  DataProcessing
//
//  Created by Lennart Wisbar on 24.10.25.
//

import Foundation

public struct ChartDataProvider: Sendable {
    public let name: String
    public let aggregator: Aggregator
    public let treatsMissingAsZero: Bool
    private let process: @Sendable ([Entry]) -> [ProcessedEntry]

    private init(name: String, aggregator: Aggregator, treatsMissingAsZero: Bool, process: @escaping @Sendable ([Entry]) -> [ProcessedEntry]) {
        self.name = name
        self.aggregator = aggregator
        self.treatsMissingAsZero = treatsMissingAsZero
        self.process = process
    }

    public func processedEntries(from rawEntries: [Entry]) -> [ProcessedEntry] {
        process(rawEntries)
    }

    /// When looking at a week, aggregates by day. When looking at a month, aggregates by week. When looking at a year, aggregates by month.
    public static func preset(for span: TimeSpan, aggregator: Aggregator, treatsMissingAsZero: Bool, calendar: Calendar) -> ChartDataProvider {
        switch (span, aggregator) {
        case (.week, .sum): ChartDataProvider.dailySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        case (.week, .average): ChartDataProvider.dailyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        case (.month, .sum): ChartDataProvider.dailySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        case (.month, .average): ChartDataProvider.dailyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        case (.year, .sum): ChartDataProvider.monthlySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        case (.year, .average): ChartDataProvider.monthlyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        }
    }

    public static let raw = ChartDataProvider(name: "raw", aggregator: .sum, treatsMissingAsZero: false) { $0.map { ProcessedEntry(value: $0.value, timestamp: $0.timestamp) } }

    public static func dailySum(treatsMissingAsZero: Bool, calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.day, .sum, name: "daily sum", calendar: calendar, treatsMissingAsZero: treatsMissingAsZero)
    }

    public static func dailyAverage(treatsMissingAsZero: Bool, calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.day, .average, name: "daily average", calendar: calendar, treatsMissingAsZero: treatsMissingAsZero)
    }

    public static func weeklySum(treatsMissingAsZero: Bool, calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.weekOfYear, .sum, name: "weekly sum", calendar: calendar, treatsMissingAsZero: treatsMissingAsZero)
    }

    public static func weeklyAverage(treatsMissingAsZero: Bool, calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.weekOfYear, .average, name: "weekly average", calendar: calendar, treatsMissingAsZero: treatsMissingAsZero)
    }

    public static func monthlySum(treatsMissingAsZero: Bool, calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.month, .sum, name: "monthly sum", calendar: calendar, treatsMissingAsZero: treatsMissingAsZero)
    }

    public static func monthlyAverage(treatsMissingAsZero: Bool, calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.month, .average, name: "monthly average", calendar: calendar, treatsMissingAsZero: treatsMissingAsZero)
    }

    public static func yearlySum(treatsMissingAsZero: Bool, calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.year, .sum, name: "yearly sum", calendar: calendar, treatsMissingAsZero: treatsMissingAsZero)
    }

    public static func yearlyAverage(treatsMissingAsZero: Bool, calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.year, .average, name: "yearly average", calendar: calendar, treatsMissingAsZero: treatsMissingAsZero)
    }

    public static func automaticPreview(treatsMissingAsZero: Bool, aggregator: Aggregator, calendar: Calendar = .current) -> ChartDataProvider {
        ChartDataProvider(name: "automatic preview", aggregator: aggregator, treatsMissingAsZero: treatsMissingAsZero) { rawEntries in
            guard !rawEntries.isEmpty else { return [] }

            let sorted = rawEntries.sorted { $0.timestamp < $1.timestamp }
            guard let first = sorted.first, let last = sorted.last else { return [] }

            // Calculate time span between first and last entries
            let daysBetween = calendar.dateComponents([.day], from: first.timestamp, to: last.timestamp).day ?? 0
            let weeksBetween = calendar.dateComponents([.weekOfYear], from: first.timestamp, to: last.timestamp).weekOfYear ?? 0
            let yearsBetween = calendar.dateComponents([.year], from: first.timestamp, to: last.timestamp).year ?? 0

            // Choose aggregation level based on data span
            if daysBetween < 2 {
                // Less than three days: show raw data without aggregation
                return raw.processedEntries(from: rawEntries)
            }
            if weeksBetween <= 10 {
                // Up to 10 weeks: aggregate by day
                return aggregator == .sum
                ? dailySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar).processedEntries(from: rawEntries)
                : dailyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar).processedEntries(from: rawEntries)
            }
            if yearsBetween < 1 {
                // Up to 1 year: aggregate by week
                return aggregator == .sum
                ? weeklySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar).processedEntries(from: rawEntries)
                : weeklyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar).processedEntries(from: rawEntries)
            }
            if yearsBetween <= 5 {
                // Up to 5 years: aggregate by month
                return aggregator == .sum
                ? monthlySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar).processedEntries(from: rawEntries)
                : monthlyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar).processedEntries(from: rawEntries)
            }

            // More than 5 years: aggregate by year
            return aggregator == .sum
            ? yearlySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar).processedEntries(from: rawEntries)
            : yearlyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar).processedEntries(from: rawEntries)
        }
    }

    private static func aggregating(
        _ unit: Calendar.Component,
        _ aggregator: Aggregator,
        name: String,
        calendar: Calendar,
        treatsMissingAsZero: Bool
    ) -> ChartDataProvider {
        ChartDataProvider(name: name, aggregator: aggregator, treatsMissingAsZero: treatsMissingAsZero) { entries in
            guard !entries.isEmpty else { return [] }

            let grouped = Dictionary(grouping: entries) {
                calendar.startOfUnit(unit, for: $0.timestamp)
            }

            let bucketDates = grouped.keys.sorted()

            // Fast path: no zero-filling
            guard treatsMissingAsZero else {
                return bucketDates.map { date in
                    let value = aggregator.aggregate(grouped[date]!.map(\.value))
                    return ProcessedEntry(value: value, timestamp: date)
                }
            }

            // Slow path: fill missing periods with zero
            return filledBuckets(
                from: bucketDates,
                unit: unit,
                calendar: calendar,
                grouped: grouped,
                aggregator: aggregator
            )
        }
    }

    private static func filledBuckets(
        from bucketDates: [Date],
        unit: Calendar.Component,
        calendar: Calendar,
        grouped: [Date: [Entry]],
        aggregator: Aggregator
    ) -> [ProcessedEntry] {
        guard
            let first = bucketDates.first,
            let last = bucketDates.last
        else { return [] }

        let start = calendar.startOfUnit(unit, for: first)
        let end   = calendar.startOfUnit(unit, for: last)

        return sequence(first: start) { current in
            calendar.date(byAdding: unit, value: 1, to: current)
        }
        .prefix(while: { $0 <= end })
        .map { date in
            let entriesInBucket = grouped[date] ?? []

            let value = entriesInBucket.isEmpty
            ? 0.0
            : aggregator.aggregate(entriesInBucket.map(\.value))

            return ProcessedEntry(value: value, timestamp: date)
        }
    }
}

extension ChartDataProvider: Hashable {
    public static func == (lhs: ChartDataProvider, rhs: ChartDataProvider) -> Bool {
        lhs.name == rhs.name &&
        lhs.aggregator == rhs.aggregator &&
        lhs.treatsMissingAsZero == rhs.treatsMissingAsZero
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(aggregator)
        hasher.combine(treatsMissingAsZero)
    }
}

private extension Calendar {
    func startOfUnit(_ component: Calendar.Component, for date: Date) -> Date {
        switch component {
        case .day:
            return self.startOfDay(for: date)
        case .weekOfYear:
            let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            return self.date(from: components) ?? date
        case .month:
            let components = self.dateComponents([.year, .month], from: date)
            return self.date(from: components) ?? date
        case .year:
            let components = self.dateComponents([.year], from: date)
            return self.date(from: components) ?? date
        default:
            guard let interval = self.dateInterval(of: component, for: date) else {
                return date
            }
            return interval.start
        }
    }
}
