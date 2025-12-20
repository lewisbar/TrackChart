//
//  ChartPageTests.swift
//  DataProcessingTests
//
//  Created by Lennart Wisbar on 06.11.25.
//

import Testing
import Foundation
import DataProcessing

struct ChartPageTests {
    @Test func init_setsDateRangeCorrectly() {
        let earliest = ProcessedEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let latest = ProcessedEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 1000))
        let middle = ProcessedEntry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 500))

        let sut = makeSUT(entries: [earliest, latest, middle])

        #expect(sut.dateRange == earliest.timestamp...latest.timestamp)
    }

    @Test func isExtremum_withOnlyPositiveValues_picksOnlyHighest() {
        let highest = ProcessedEntry(value: 5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let other2 = ProcessedEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = makeSUT(entries: [other1, highest, other2])

        #expect(sut.isExtremum(highest))
        #expect(!sut.isExtremum(other1))
        #expect(!sut.isExtremum(other2))
    }

    @Test func isExtremum_withOnlyNegativeValues_picksOnlyLowest() {
        let lowest = ProcessedEntry(value: -5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: -4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let other2 = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = makeSUT(entries: [other1, lowest, other2])

        #expect(sut.isExtremum(lowest))
        #expect(!sut.isExtremum(other1))
        #expect(!sut.isExtremum(other2))
    }

    @Test func isExtremum_withPositiveAndNegativeValues_picksHighestAndLowest() {
        let highest = ProcessedEntry(value: 5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let lowest = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = makeSUT(entries: [other1, highest, lowest])

        #expect(sut.isExtremum(highest))
        #expect(sut.isExtremum(lowest))
        #expect(!sut.isExtremum(other1))
    }

    @Test func isMaxPositive_withOnlyPositiveValues_picksHighest() {
        let highest = ProcessedEntry(value: 5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let other2 = ProcessedEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = makeSUT(entries: [other1, highest, other2])

        #expect(sut.isMaxPositiveEntry(highest))
        #expect(!sut.isMaxPositiveEntry(other1))
        #expect(!sut.isMaxPositiveEntry(other2))
    }

    @Test func isMaxPositive_withOnlyNegativeValues_picksNone() {
        let lowest = ProcessedEntry(value: -5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: -4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let other2 = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = makeSUT(entries: [other1, lowest, other2])

        #expect(!sut.isMaxPositiveEntry(lowest))
        #expect(!sut.isMaxPositiveEntry(other1))
        #expect(!sut.isMaxPositiveEntry(other2))
    }

    @Test func isMaxPositive_withPositiveAndNegativeValues_picksHighest() {
        let highest = ProcessedEntry(value: 5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let lowest = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = makeSUT(entries: [other1, highest, lowest])

        #expect(sut.isMaxPositiveEntry(highest))
        #expect(!sut.isMaxPositiveEntry(lowest))
        #expect(!sut.isMaxPositiveEntry(other1))
    }

    @Test func isMaxPositive_withZeroAsHighest_picksZero() {
        let other1 = ProcessedEntry(value: -5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let highest = ProcessedEntry(value: 0, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let lowest = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = makeSUT(entries: [other1, highest, lowest])

        #expect(sut.isMaxPositiveEntry(highest))
        #expect(!sut.isMaxPositiveEntry(lowest))
        #expect(!sut.isMaxPositiveEntry(other1))
    }

    @Test func isMinNegative_withOnlyPositiveValues_picksNone() {
        let highest = ProcessedEntry(value: 5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let other2 = ProcessedEntry(value: 0, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = makeSUT(entries: [other1, highest, other2])

        #expect(!sut.isMinNegativeEntry(highest))
        #expect(!sut.isMinNegativeEntry(other1))
        #expect(!sut.isMinNegativeEntry(other2))
    }

    @Test func isMinNegative_withOnlyNegativeValues_picksLowest() {
        let lowest = ProcessedEntry(value: -5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: -4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let other2 = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = makeSUT(entries: [other1, lowest, other2])

        #expect(sut.isMinNegativeEntry(lowest))
        #expect(!sut.isMinNegativeEntry(other1))
        #expect(!sut.isMinNegativeEntry(other2))
    }

    @Test func isMinNegative_withPositiveAndNegativeValues_picksLowest() {
        let highest = ProcessedEntry(value: 5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let lowest = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = makeSUT(entries: [other1, highest, lowest])

        #expect(sut.isMinNegativeEntry(lowest))
        #expect(!sut.isMinNegativeEntry(highest))
        #expect(!sut.isMinNegativeEntry(other1))
    }

    // MARK: - Helpers

    private func makeSUT(entries: [ProcessedEntry]) -> ChartPage {
        ChartPage(
            entries: entries,
            span: .week,
            title: "Title",
            aggregator: .sum,
            aggregate: 0
        )
    }
}
