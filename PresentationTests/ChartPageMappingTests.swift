//
//  ChartPageMappingTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 02.12.25.
//

import Testing
import Foundation
import Presentation
import DataProcessing

struct ChartPageMappingTests {
    @Test func chartViewPage() {
        let entry1 = ProcessedEntry(value: 0.1, timestamp: Date(timeIntervalSinceReferenceDate: 0))
        let entry2 = ProcessedEntry(value: 0.2, timestamp: Date(timeIntervalSinceReferenceDate: 10))
        let entry3 = ProcessedEntry(value: 0.3, timestamp: Date(timeIntervalSinceReferenceDate: 20))
        let entries = [entry1, entry2, entry3]

        let sut = ChartPage(
            entries: entries,
            span: .month,
            title: "a title",
            aggregator: .average,
            aggregate: 0.2
        )

        let result = sut.chartViewPage

        let expectedResult = ChartViewPage(
            id: "month-\(entry1.timestamp.timeIntervalSince1970)",
            entries: entries.map { ViewEntry(id: $0.id, value: $0.value, timestamp: $0.timestamp)},
            title: sut.title,
            dateRange: entries.map(\.timestamp).min()! ... entries.map(\.timestamp).max()!,
            aggregator: .average,
            aggregate: sut.aggregate,
            maxEntries: [entry3.id],
            minEntries: []
        )

        #expect(result.id == expectedResult.id)
        #expect(result.entries == expectedResult.entries)
        #expect(result.title == expectedResult.title)
        #expect(result.dateRange == expectedResult.dateRange)
        #expect(result.aggregator == expectedResult.aggregator)
        #expect(result.aggregate == expectedResult.aggregate)
        #expect(result.maxEntries == expectedResult.maxEntries)
        #expect(result.minEntries == expectedResult.minEntries)
    }
}
