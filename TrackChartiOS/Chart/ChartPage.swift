//
//  ChartPage.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 30.10.25.
//

import Foundation

struct ChartPage: Identifiable, Equatable {
    let id = UUID()
    let entries: [ProcessedEntry]
    let span: TimeSpan
    let title: String
    let dateRange: ClosedRange<Date>

    init(entries: [ProcessedEntry], span: TimeSpan, title: String) {
        self.entries = entries
        self.span = span
        self.title = title
        let dates = entries.map(\.timestamp)
        self.dateRange = (dates.min() ?? Date()) ... (dates.max() ?? Date())
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
