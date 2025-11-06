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
    public static let dailySum = aggregating(.day, .sum, name: "Daily Sum")
    public static let dailyAverage = aggregating(.day, .average, name: "Daily Average")
    public static let weeklySum = aggregating(.weekOfYear, .sum, name: "Weekly Sum")
    public static let weeklyAverage = aggregating(.weekOfYear, .average, name: "Weekly Average")
    public static let monthlySum = aggregating(.month, .sum, name: "Monthly Sum")
    public static let monthlyAverage = aggregating(.month, .average, name: "Monthly Average")

    private static func aggregating(_ unit: Calendar.Component, _ aggregator: Aggregator, name: String) -> ChartDataProvider {
        ChartDataProvider(name: name) { entries in
            let grouped = Dictionary(grouping: entries) {
                Calendar.current.startOfUnit(unit, for: $0.timestamp)
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

public struct ProcessedEntry: Identifiable, Equatable {
    public let id = UUID()
    public let value: Double
    public let timestamp: Date

    public init(value: Double, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
    }
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
    static let automaticPreview = ChartDataProvider(name: "Automatic Preview") { raw in
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
