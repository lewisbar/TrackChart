//
//  ChartDataProvider.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 24.10.25.
//

import Foundation
import Presentation

struct ChartDataProvider: Sendable {
    private let process: @Sendable ([ChartEntry]) -> [ProcessedEntry]

    private init(process: @escaping @Sendable ([ChartEntry]) -> [ProcessedEntry]) {
        self.process = process
    }

    func processedEntries(from rawEntries: [ChartEntry]) -> [ProcessedEntry] {
        process(rawEntries)
    }

    // Static factories for common providers
    static let raw = ChartDataProvider { rawEntries in
        rawEntries.map { ProcessedEntry(value: $0.value, timestamp: $0.timestamp) }
    }

    static let minutelySum = ChartDataProvider { rawEntries in
        aggregatingProvider(
            timeUnit: .minute,
            aggregator: .sum,
            calendar: .current
        )(rawEntries)
    }

    static let hourlySum = ChartDataProvider { rawEntries in
        aggregatingProvider(
            timeUnit: .hour,
            aggregator: .sum,
            calendar: .current
        )(rawEntries)
    }

    static let dailySum = ChartDataProvider { rawEntries in
        aggregatingProvider(
            timeUnit: .day,
            aggregator: .sum,
            calendar: .current
        )(rawEntries)
    }

    static let weeklySum = ChartDataProvider { rawEntries in
        aggregatingProvider(
            timeUnit: .weekOfYear,
            aggregator: .sum,
            calendar: .current
        )(rawEntries)
    }

    static let monthlySum = ChartDataProvider { rawEntries in
        aggregatingProvider(
            timeUnit: .month,
            aggregator: .sum,
            calendar: .current
        )(rawEntries)
    }

    static let dailyAverage = ChartDataProvider { rawEntries in
        aggregatingProvider(
            timeUnit: .day,
            aggregator: .average,
            calendar: .current
        )(rawEntries)
    }

    static let weeklyAverage = ChartDataProvider { rawEntries in
        aggregatingProvider(
            timeUnit: .weekOfYear,
            aggregator: .average,
            calendar: .current
        )(rawEntries)
    }

    static let monthlyAverage = ChartDataProvider { rawEntries in
        aggregatingProvider(
            timeUnit: .month,
            aggregator: .average,
            calendar: .current
        )(rawEntries)
    }

    static func custom(
        timeUnit: Calendar.Component,
        aggregator: Aggregator,
        calendar: Calendar = .current
    ) -> ChartDataProvider {
        ChartDataProvider { rawEntries in
            aggregatingProvider(
                timeUnit: timeUnit,
                aggregator: aggregator,
                calendar: calendar
            )(rawEntries)
        }
    }

    // Reusable aggregation logic
    private static func aggregatingProvider(
        timeUnit: Calendar.Component,
        aggregator: Aggregator,
        calendar: Calendar
    ) -> ([ChartEntry]) -> [ProcessedEntry] {
        return { rawEntries in
            let grouped = Dictionary(grouping: rawEntries) { entry in
                calendar.startOfUnit(timeUnit, for: entry.timestamp)
            }
            return grouped.map { date, entries in
                let value = aggregator.aggregate(entries.map(\.value))
                return ProcessedEntry(value: value, timestamp: date)
            }.sorted(by: { $0.timestamp < $1.timestamp })
        }
    }
}

struct ProcessedEntry: Identifiable {
    let id = UUID()
    let value: Double
    let timestamp: Date
}

enum Aggregator {
    case sum
    case average

    func aggregate(_ values: [Double]) -> Double {
        switch self {
        case .sum:
            return values.reduce(0, +)
        case .average:
            return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        }
    }
}

private extension Calendar {
    func startOfUnit(_ component: Calendar.Component, for date: Date) -> Date {
        switch component {
        case .day:
            return startOfDay(for: date)
        case .weekOfYear:
            return dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date)
                .date ?? date
        case .month:
            return dateComponents([.year, .month], from: date).date ?? date
        case .year:
            return dateComponents([.year], from: date).date ?? date
        default:
            return date
        }
    }
}
