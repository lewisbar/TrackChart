//
//  ChartPageProviderTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 06.11.25.
//

import Testing
import Foundation
import TrackChartiOS

@MainActor
struct ChartPageProviderTests {
    let calendar = Calendar.current

    @Test("Empty array returns empty pages")
    func emptyArray() {
        let pages = ChartPageProvider.pages(for: [], span: .week, aggregator: .dailySum)
        #expect(pages.isEmpty)
    }

    @Test("Single entry creates one page")
    func singleEntry() {
        let entry = ChartEntry(value: 10, timestamp: date(2024, 11, 7))
        let pages = ChartPageProvider.pages(for: [entry], span: .week, aggregator: .dailySum)

        #expect(pages.count == 1)
        #expect(pages[0].entries.count == 1)
        #expect(pages[0].entries[0].value == 10)
    }

    @Test("Last entry is included in results")
    func lastEntryIncluded() {
        let entries = [
            ChartEntry(value: 1, timestamp: date(2024, 11, 1)),
            ChartEntry(value: 2, timestamp: date(2024, 11, 5)),
            ChartEntry(value: 3, timestamp: date(2024, 11, 7)) // Last entry
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum)

        // All entries should be in the same week
        #expect(pages.count == 1)
        #expect(pages[0].entries.count == 3)

        // Verify last entry is present
        let lastValue = pages[0].entries.last?.value
        #expect(lastValue == 3)
    }

    @Test("Entries spanning two weeks create two pages")
    func twoWeeks() {
        let entries = [
            ChartEntry(value: 1, timestamp: date(2024, 10, 28)), // Week 1
            ChartEntry(value: 2, timestamp: date(2024, 10, 30)), // Week 1
            ChartEntry(value: 3, timestamp: date(2024, 11, 4)),  // Week 2
            ChartEntry(value: 4, timestamp: date(2024, 11, 7))   // Week 2
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum)

        #expect(pages.count == 2)
        #expect(pages[0].entries.count == 2) // First week
        #expect(pages[1].entries.count == 2) // Second week
    }

    @Test("Entries spanning three months create three pages")
    func threeMonths() {
        let entries = [
            ChartEntry(value: 1, timestamp: date(2024, 9, 10)),  // September
            ChartEntry(value: 2, timestamp: date(2024, 10, 10)), // October
            ChartEntry(value: 3, timestamp: date(2024, 11, 10))   // November
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .month, aggregator: .weeklySum)

        #expect(pages.count == 3)
        #expect(pages[0].entries.count == 1) // September
        #expect(pages[1].entries.count == 1) // October
        #expect(pages[2].entries.count == 1) // November
    }

    @Test("Unsorted entries are handled correctly")
    func unsortedEntries() {
        let entries = [
            ChartEntry(value: 3, timestamp: date(2024, 11, 7)),
            ChartEntry(value: 1, timestamp: date(2024, 11, 1)),
            ChartEntry(value: 2, timestamp: date(2024, 11, 5))
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum)

        #expect(pages.count == 1)
        #expect(pages[0].entries.count == 3)

        // Entries should be sorted by timestamp
        let values = pages[0].entries.map(\.value)
        #expect(values == [1, 2, 3])
    }

    @Test("Entries at midnight are included correctly")
    func midnightEntries() {
        // Entry exactly at start of day
        let midnightEntry = calendar.startOfDay(for: date(2024, 11, 7))
        let entries = [
            ChartEntry(value: 1, timestamp: midnightEntry)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum)

        #expect(pages.count == 1)
        #expect(pages[0].entries.count == 1)
    }

    @Test("Multiple entries on same day are all included")
    func multipleEntriesSameDay() {
        let baseDate = date(2024, 11, 7, 0)
        let entries = [
            ChartEntry(value: 1, timestamp: calendar.date(byAdding: .hour, value: 1, to: baseDate)!),
            ChartEntry(value: 2, timestamp: calendar.date(byAdding: .hour, value: 12, to: baseDate)!),
            ChartEntry(value: 3, timestamp: calendar.date(byAdding: .hour, value: 23, to: baseDate)!)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum)

        #expect(pages.count == 1)
        #expect(pages[0].entries.count == 1)
        #expect(pages.first?.entries.first?.value == 6)
    }

    @Test("Pages are returned in chronological order")
    func chronologicalOrder() {
        let entries = [
            ChartEntry(value: 1, timestamp: date(2024, 9, 15)),
            ChartEntry(value: 2, timestamp: date(2024, 10, 15)),
            ChartEntry(value: 3, timestamp: date(2024, 11, 16))
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .month, aggregator: .dailySum)

        #expect(pages.count == 3)

        // First page should contain September entry
        #expect(pages[0].entries[0].value == 1)
        // Last page should contain November entry
        #expect(pages[2].entries[0].value == 3)
    }

    @Test("Six months span groups correctly")
    func sixMonthsSpan() {
        let entries = [
            ChartEntry(value: 1, timestamp: date(2024, 1, 15)),  // First period
            ChartEntry(value: 2, timestamp: date(2024, 7, 15)),  // Second period
            ChartEntry(value: 3, timestamp: date(2024, 11, 7))   // Still second period
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .sixMonths, aggregator: .weeklySum)

        #expect(pages.count == 2)
    }

    @Test("One year span groups correctly")
    func oneYearSpan() {
        let entries = [
            ChartEntry(value: 1, timestamp: date(2023, 6, 15)),
            ChartEntry(value: 2, timestamp: date(2024, 6, 15)),
            ChartEntry(value: 3, timestamp: date(2024, 11, 7))
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .oneYear, aggregator: .monthlySum)

        #expect(pages.count == 2)
        #expect(pages[0].entries.count == 1) // 2023
        #expect(pages[1].entries.count == 2) // 2024
    }

    @Test("Edge case: Entry on last second of day")
    func lastSecondOfDay() {
        let endOfDay = calendar.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: date(2024, 11, 7)
        )!

        let entries = [ChartEntry(value: 1, timestamp: endOfDay)]
        let pages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum)

        #expect(pages.count == 1)
        #expect(pages[0].entries.count == 1)
    }

    // MARK: - Helpers

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
