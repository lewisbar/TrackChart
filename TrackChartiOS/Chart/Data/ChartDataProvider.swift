//
//  ChartDataProvider.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 24.10.25.
//

import Foundation

public struct ChartDataProvider: Sendable {
    public let name: String
    private let process: @Sendable ([ChartEntry]) -> [ProcessedEntry]

    private init(name: String, process: @escaping @Sendable ([ChartEntry]) -> [ProcessedEntry]) {
        self.name = name
        self.process = process
    }

    public func processedEntries(from rawEntries: [ChartEntry]) -> [ProcessedEntry] {
        process(rawEntries)
    }

    public static let raw = ChartDataProvider(name: "Raw Data") { $0.map { ProcessedEntry(value: $0.value, timestamp: $0.timestamp) } }

    public static func dailySum(calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.day, .sum, name: "Daily Sum", calendar: calendar)
    }

    public static func dailyAverage(calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.day, .average, name: "Daily Average", calendar: calendar)
    }

    public static func weeklySum(calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.weekOfYear, .sum, name: "Weekly Sum", calendar: calendar)
    }

    public static func weeklyAverage(calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.weekOfYear, .average, name: "Weekly Average", calendar: calendar)
    }

    public static func monthlySum(calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.month, .sum, name: "Monthly Sum", calendar: calendar)
    }

    public static func monthlyAverage(calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.month, .average, name: "Monthly Average", calendar: calendar)
    }

    public static func yearlySum(calendar: Calendar = .current) -> ChartDataProvider {
        aggregating(.year, .sum, name: "Yearly Sum", calendar: calendar)
    }

    public static func automaticPreview(calendar: Calendar = .current) -> ChartDataProvider {
        ChartDataProvider(name: "Automatic Preview") { raw in
            guard !raw.isEmpty else { return [] }

            let sorted = raw.sorted { $0.timestamp < $1.timestamp }
            guard let first = sorted.first, let last = sorted.last else { return [] }

            // Calculate time span between first and last entries
            let weeksBetween = calendar.dateComponents([.weekOfYear], from: first.timestamp, to: last.timestamp).weekOfYear ?? 0
            let yearsBetween = calendar.dateComponents([.year], from: first.timestamp, to: last.timestamp).year ?? 0

            // Choose aggregation level based on data span
            if weeksBetween == 0 {
                // Less than a week: show raw data without aggregation
                return raw.map { ProcessedEntry(value: $0.value, timestamp: $0.timestamp) }
            }
            if weeksBetween <= 10 {
                // Up to 10 weeks: aggregate by day
                return dailySum(calendar: calendar).processedEntries(from: raw)
            }
            if yearsBetween < 1 {
                // Up to 1 year: aggregate by week
                return weeklySum(calendar: calendar).processedEntries(from: raw)
            }
            if yearsBetween <= 5 {
                // Up to 5 years: aggregate by month
                return monthlySum(calendar: calendar).processedEntries(from: raw)
            }

            // More than 5 years: aggregate by year
            return yearlySum(calendar: calendar).processedEntries(from: raw)
        }
    }

    private static func aggregating(
        _ unit: Calendar.Component,
        _ aggregator: Aggregator,
        name: String,
        calendar: Calendar
    ) -> ChartDataProvider {
        ChartDataProvider(name: name) { entries in
            let grouped = Dictionary(grouping: entries) {
                calendar.startOfUnit(unit, for: $0.timestamp)
            }
            return grouped.map { date, entries in
                ProcessedEntry(value: aggregator.aggregate(entries.map(\.value)), timestamp: date)
            }.sorted { $0.timestamp < $1.timestamp }
        }
    }
}

extension ChartDataProvider: Hashable {
    public static func == (lhs: ChartDataProvider, rhs: ChartDataProvider) -> Bool {
        lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
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
