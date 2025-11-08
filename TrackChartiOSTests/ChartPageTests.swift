//
//  ChartPageTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 06.11.25.
//

import Testing
import Foundation
import TrackChartiOS

struct ChartPageTests {
    @Test func init_setsDateRangeCorrectly() {
        let earliest = Date(timeIntervalSinceReferenceDate: 100)
        let latest = Date(timeIntervalSinceReferenceDate: 1000)
        let middle = Date(timeIntervalSinceReferenceDate: 500)

        let sut = ChartPage(entries: [
            .init(value: 1, timestamp: earliest),
            .init(value: 2, timestamp: latest),
            .init(value: 3, timestamp: middle)
        ], span: .week, title: "Title", periodStart: Calendar.current.startOfDay(for: earliest))

        #expect(sut.dateRange == earliest...latest)
    }

    @Test func isExtremum_withOnlyPositiveValues_picksOnlyHighest() {
        let highest = ProcessedEntry(value: 5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let other2 = ProcessedEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = ChartPage(entries: [other1, highest, other2], span: .week, title: "Title", periodStart: Calendar.current.startOfDay(for: highest.timestamp))

        #expect(sut.isExtremum(highest))
        #expect(!sut.isExtremum(other1))
        #expect(!sut.isExtremum(other2))
    }

    @Test func isExtremum_withOnlyNegativeValues_picksOnlyLowest() {
        let lowest = ProcessedEntry(value: -5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: -4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let other2 = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = ChartPage(entries: [other1, lowest, other2], span: .week, title: "Title", periodStart: Calendar.current.startOfDay(for: lowest.timestamp))

        #expect(sut.isExtremum(lowest))
        #expect(!sut.isExtremum(other1))
        #expect(!sut.isExtremum(other2))
    }

    @Test func isExtremum_withPositiveAndNegativeValues_picksHighestAndLowest() {
        let highest = ProcessedEntry(value: 5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let lowest = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = ChartPage(entries: [other1, highest, lowest], span: .week, title: "Title", periodStart: Calendar.current.startOfDay(for: highest.timestamp))

        #expect(sut.isExtremum(highest))
        #expect(sut.isExtremum(lowest))
        #expect(!sut.isExtremum(other1))
    }

    @Test func isMaxPositive_withOnlyPositiveValues_picksHighest() {
        let highest = ProcessedEntry(value: 5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let other2 = ProcessedEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = ChartPage(entries: [other1, highest, other2], span: .week, title: "Title", periodStart: Calendar.current.startOfDay(for: highest.timestamp))

        #expect(sut.isMaxPositiveEntry(highest))
        #expect(!sut.isMaxPositiveEntry(other1))
        #expect(!sut.isMaxPositiveEntry(other2))
    }

    @Test func isMaxPositive_withOnlyNegativeValues_picksNone() {
        let lowest = ProcessedEntry(value: -5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: -4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let other2 = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = ChartPage(entries: [other1, lowest, other2], span: .week, title: "Title", periodStart: Calendar.current.startOfDay(for: lowest.timestamp))

        #expect(!sut.isMaxPositiveEntry(lowest))
        #expect(!sut.isMaxPositiveEntry(other1))
        #expect(!sut.isMaxPositiveEntry(other2))
    }

    @Test func isMaxPositive_withPositiveAndNegativeValues_picksHighest() {
        let highest = ProcessedEntry(value: 5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let lowest = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = ChartPage(entries: [other1, highest, lowest], span: .week, title: "Title", periodStart: Calendar.current.startOfDay(for: highest.timestamp))

        #expect(sut.isMaxPositiveEntry(highest))
        #expect(!sut.isMaxPositiveEntry(lowest))
        #expect(!sut.isMaxPositiveEntry(other1))
    }

    @Test func isMinNegative_withOnlyPositiveValues_picksNone() {
        let highest = ProcessedEntry(value: 5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let other2 = ProcessedEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = ChartPage(entries: [other1, highest, other2], span: .week, title: "Title", periodStart: Calendar.current.startOfDay(for: highest.timestamp))

        #expect(!sut.isMinNegativeEntry(highest))
        #expect(!sut.isMinNegativeEntry(other1))
        #expect(!sut.isMinNegativeEntry(other2))
    }

    @Test func isMinNegative_withOnlyNegativeValues_picksLowest() {
        let lowest = ProcessedEntry(value: -5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: -4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let other2 = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = ChartPage(entries: [other1, lowest, other2], span: .week, title: "Title", periodStart: Calendar.current.startOfDay(for: lowest.timestamp))

        #expect(sut.isMinNegativeEntry(lowest))
        #expect(!sut.isMinNegativeEntry(other1))
        #expect(!sut.isMinNegativeEntry(other2))
    }

    @Test func isMinNegative_withPositiveAndNegativeValues_picksLowest() {
        let highest = ProcessedEntry(value: 5, timestamp: Date(timeIntervalSinceReferenceDate: 100))
        let other1 = ProcessedEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200))
        let lowest = ProcessedEntry(value: -2, timestamp: Date(timeIntervalSinceReferenceDate: 300))

        let sut = ChartPage(entries: [other1, highest, lowest], span: .week, title: "Title", periodStart: Calendar.current.startOfDay(for: highest.timestamp))

        #expect(sut.isMinNegativeEntry(lowest))
        #expect(!sut.isMinNegativeEntry(highest))
        #expect(!sut.isMinNegativeEntry(other1))
    }
}
