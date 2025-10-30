//
//  ChartPage.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 30.10.25.
//

import Foundation

struct ChartPage: Identifiable {
    let id = UUID()
    let entries: [ProcessedEntry]   // ≤ ~60 points
    let span: TimeSpan

    var dateRange: ClosedRange<Date> {
        let dates = entries.map(\.timestamp)
        guard let min = dates.min(), let max = dates.max() else { return Date()...Date() }
        return min...max
    }

    func isExtremum(_ entry: ProcessedEntry) -> Bool {
        isMaxPositiveEntry(entry) || isMinNegativeEntry(entry)
    }

    func isMaxPositiveEntry(_ entry: ProcessedEntry) -> Bool {
        entry.value > 0 && entry.value == entries.map(\.value).max()
    }

    func isMinNegativeEntry(_ entry: ProcessedEntry) -> Bool {
        entry.value < 0 && entry.value == entries.map(\.value).min()
    }
}
