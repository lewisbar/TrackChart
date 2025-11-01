//
//  ChartDataProvider.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 24.10.25.
//

import Foundation

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

struct ProcessedEntry: Identifiable, Equatable {
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

extension ChartDataProvider {
    /// Used only for **preview charts** (TopicCell).
    /// Returns ≤ 60 points, automatically aggregated.
    static let automaticPreview = ChartDataProvider { raw in
        guard !raw.isEmpty else { return [] }

        let sorted = raw.sorted { $0.timestamp < $1.timestamp }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day],
                                           from: sorted.first!.timestamp,
                                           to: sorted.last!.timestamp).day ?? 0

        // --- Choose aggregation level ---
        if days <= 1 {
            return raw.map { ProcessedEntry(value: $0.value, timestamp: $0.timestamp) }
        }
        if days <= 182 {
            return ChartDataProvider.dailySum.processedEntries(from: raw)
        }
        if days <= 365 {
            return ChartDataProvider.weeklySum.processedEntries(from: raw)
        }
        if days <= 1825 {
            return ChartDataProvider.monthlySum.processedEntries(from: raw)
        }

        // --- > 5 years → yearly sum ---
        let grouped = Dictionary(grouping: raw) {
            calendar.startOfUnit(.year, for: $0.timestamp)
        }
        return grouped
            .map { date, entries in
                let sum = entries.reduce(0.0) { $0 + $1.value }   // explicit closure
                return ProcessedEntry(value: sum, timestamp: date)
            }
            .sorted { $0.timestamp < $1.timestamp }
    }
}
