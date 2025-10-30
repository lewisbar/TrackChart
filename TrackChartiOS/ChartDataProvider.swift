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
    static let raw = ChartDataProvider { $0.map { ProcessedEntry(value: $0.value, timestamp: $0.timestamp) } }
    static let dailySum = aggregating(.day, .sum)
    static let dailyAverage = aggregating(.day, .average)
    static let weeklySum = aggregating(.weekOfYear, .sum)
    static let weeklyAverage = aggregating(.weekOfYear, .average)
    static let monthlySum = aggregating(.month, .sum)
    static let monthlyAverage = aggregating(.month, .average)

    private static func aggregating(_ unit: Calendar.Component, _ aggregator: Aggregator) -> ChartDataProvider {
        ChartDataProvider { entries in
            let grouped = Dictionary(grouping: entries) {
                Calendar.current.startOfUnit(unit, for: $0.timestamp)
            }
            return grouped.map { date, entries in
                ProcessedEntry(value: aggregator.aggregate(entries.map(\.value)), timestamp: date)
            }.sorted { $0.timestamp < $1.timestamp }
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
        guard let interval = dateInterval(of: component, for: date) else {
            return date
        }
        return interval.start
    }
}
