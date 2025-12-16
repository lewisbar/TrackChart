//
//  ChartPageProviderTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 06.11.25.
//

import Testing
import Foundation
import DataProcessing

@MainActor
struct ChartPageProviderTests {

    // MARK: - Gregorian Calendar Tests

    @Test("Gregorian: Empty array returns empty pages")
    func gregorianEmptyArray() {
        let calendar = defaultCalendar()
        let pages = ChartPageProvider.pages(for: [], span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)
        #expect(pages.isEmpty)
    }

    @Test("Gregorian: Week spanning year boundary")
    func gregorianWeekSpanningYear() {
        let calendar = defaultCalendar()

        // Dec 30, 2024 to Jan 5, 2025 should be in the same week
        let entries = [
            RawEntry(value: 1, timestamp: date(2024, 12, 30, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2025, 1, 2, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2025, 1, 5, calendar: calendar))
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        // All entries should be in the same week page
        #expect(pages.count == 1)
        #expect(pages.first?.entries.map(\.value) == [1, 2, 3])

        let expectedDates = [
            date(2024, 12, 30, hour: 0, calendar: calendar),
            date(2025, 1, 2, hour: 0, calendar: calendar),
            date(2025, 1, 5, hour: 0, calendar: calendar)
        ]
        #expect(pages.first?.entries.map(\.timestamp) == expectedDates)

        let formatStyle = Date.FormatStyle(calendar: calendar)
        let first = expectedDates[0].formatted(formatStyle.day().month(.abbreviated))
        let last = expectedDates[2].formatted(formatStyle.day().month(.abbreviated).year())
        let expectedTitle = "\(first) – \(last)"
        #expect(pages.first?.title == expectedTitle)
    }

    @Test("Gregorian: Month boundaries are respected")
    func gregorianMonthBoundaries() {
        let calendar = defaultCalendar()
        let entries = [
            RawEntry(value: 1, timestamp: date(2024, 10, 31, calendar: calendar)), // Last day of October
            RawEntry(value: 2, timestamp: date(2024, 11, 1, calendar: calendar))   // First day of November
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .month, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        #expect(pages.count == 2)
        #expect(pages[0].entries.count == 1)  // October
        #expect(pages[1].entries.count == 1)  // November
    }

    // MARK: - Hebrew Calendar Tests

    @Test("Hebrew: Basic week grouping")
    func hebrewBasicWeek() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        // Create entries within the same Hebrew week
        let baseDate = date(2024, 11, 10, calendar: calendar)
        let entries = [
            RawEntry(value: 1, timestamp: baseDate),
            RawEntry(value: 2, timestamp: calendar.date(byAdding: .day, value: 2, to: baseDate)!),
            RawEntry(value: 3, timestamp: calendar.date(byAdding: .day, value: 4, to: baseDate)!)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        #expect(!pages.isEmpty)
        // Verify entries are properly aggregated
        let totalValue = pages.flatMap { $0.entries }.map(\.value).reduce(0, +)
        #expect(totalValue == 6.0)
    }

    @Test("Hebrew: Month boundaries")
    func hebrewMonthBoundaries() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        // Get two consecutive Hebrew months
        let firstMonth = date(2024, 11, 1, calendar: calendar)
        let secondMonth = calendar.date(byAdding: .month, value: 1, to: firstMonth)!

        let entries = [
            RawEntry(value: 1, timestamp: firstMonth),
            RawEntry(value: 2, timestamp: secondMonth)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .month, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        #expect(pages.count >= 1) // Should create at least one page
        // Verify all values are accounted for
        let totalValue = pages.flatMap { $0.entries }.map(\.value).reduce(0, +)
        #expect(totalValue == 3.0)
    }

    @Test("Hebrew: Year grouping")
    func hebrewYearGrouping() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let year1 = date(2024, 1, 15, calendar: calendar)
        let year2 = calendar.date(byAdding: .year, value: 1, to: year1)!

        let entries = [
            RawEntry(value: 10, timestamp: year1),
            RawEntry(value: 20, timestamp: year2)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .year, dataProvider: .monthlySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        #expect(pages.count == 2)
    }

    // MARK: - Islamic Calendar Tests

    @Test("Islamic: Week grouping")
    func islamicWeekGrouping() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let baseDate = date(2024, 11, 10, calendar: calendar)
        let entries = [
            RawEntry(value: 5, timestamp: baseDate),
            RawEntry(value: 10, timestamp: calendar.date(byAdding: .day, value: 3, to: baseDate)!)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        #expect(!pages.isEmpty)
        let totalValue = pages.flatMap { $0.entries }.map(\.value).reduce(0, +)
        #expect(totalValue == 15.0)
    }

    @Test("Islamic: Month boundaries")
    func islamicMonthBoundaries() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let month1 = date(2024, 6, 15, calendar: calendar)
        let month2 = calendar.date(byAdding: .month, value: 1, to: month1)!

        let entries = [
            RawEntry(value: 100, timestamp: month1),
            RawEntry(value: 200, timestamp: month2)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .month, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        #expect(pages.count == 2)
    }

    // MARK: - Edge Cases Across Calendars

    @Test("Multiple calendars: Same timestamp different grouping")
    func multipleCalendarsSameTimestamp() {
        let gregorian = Calendar(identifier: .gregorian)
        var hebrew = Calendar(identifier: .hebrew)
        hebrew.timeZone = TimeZone(identifier: "UTC")!

        let timestamp = Date(timeIntervalSince1970: 1700000000)  // Fixed point in time
        let entries = [RawEntry(value: 42, timestamp: timestamp)]

        let gregorianPages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: gregorian), calendar: gregorian)
        let hebrewPages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: hebrew), calendar: hebrew)

        // Both should create pages, but periods may differ
        #expect(!gregorianPages.isEmpty)
        #expect(!hebrewPages.isEmpty)

        // Values should be preserved
        #expect(gregorianPages[0].entries[0].value == 42)
        #expect(hebrewPages[0].entries[0].value == 42)
    }

    @Test("Calendar with different first weekday")
    func differentFirstWeekday() {
        var sundayCalendar = Calendar(identifier: .gregorian)
        sundayCalendar.firstWeekday = 1  // Sunday

        var mondayCalendar = Calendar(identifier: .gregorian)
        mondayCalendar.firstWeekday = 2  // Monday

        // Entry on a Monday
        let entries = [RawEntry(value: 10, timestamp: date(2024, 11, 11, calendar: sundayCalendar))]

        let sundayPages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: sundayCalendar), calendar: sundayCalendar)
        let mondayPages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: mondayCalendar), calendar: mondayCalendar)

        // Both should create pages
        #expect(!sundayPages.isEmpty)
        #expect(!mondayPages.isEmpty)

        // Period starts differ
        let sundayComponents = sundayCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: sundayPages[0].entries[0].timestamp)
        let sundayWeekStart = sundayCalendar.date(from: sundayComponents)

        let mondayComponents = mondayCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: mondayPages[0].entries[0].timestamp)
        let mondayWeekStart = mondayCalendar.date(from: mondayComponents)

        #expect(sundayWeekStart != mondayWeekStart)
    }

    @Test("Leap year handling across calendars")
    func leapYearHandling() {
        let calendar = defaultCalendar()

        // 2024 is a leap year
        let febEntries = [
            RawEntry(value: 1, timestamp: date(2024, 2, 28, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2024, 2, 29, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2024, 3, 1, calendar: calendar))
        ]

        let pages = ChartPageProvider.pages(for: febEntries, span: .month, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        // Feb and March should be separate pages
        #expect(pages.count == 2)
        #expect(pages[0].entries.count == 2)  // Feb 28 and 29
        #expect(pages[1].entries.count == 1)  // March 1
    }

    // MARK: - Aggregation Tests

    @Test("Daily sum aggregation across week")
    func dailySumAggregation() {
        let calendar = defaultCalendar()
        let baseDate = date(2024, 11, 11, calendar: calendar)

        // Multiple entries on same day, plus another day
        let entries = [
            RawEntry(value: 10, timestamp: baseDate),
            RawEntry(value: 2, timestamp: calendar.date(byAdding: .hour, value: 2, to: baseDate)!),
            RawEntry(value: 40, timestamp: calendar.date(byAdding: .day, value: 2, to: baseDate)!)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        #expect(pages.count == 1)
        #expect(pages[0].entries.count == 2)  // Two days

        #expect(pages.first?.entries.map(\.value) == [12, 40])
    }

    @Test("Daily sum aggregation across week with zero filling")
    func dailySumAggregation_withZeroFilling() {
        let calendar = defaultCalendar()
        let baseDate = date(2025, 11, 5, calendar: calendar)  // Wednesday

        // Multiple entries on same day, plus two other days in the next weeks, with empty days in between
        let entries = [
            RawEntry(value: 10, timestamp: baseDate),  // Wednesday
            RawEntry(value: 20, timestamp: calendar.date(byAdding: .hour, value: 2, to: baseDate)!),  // same day
            RawEntry(value: 30, timestamp: calendar.date(byAdding: .day, value: 8, to: baseDate)!),  // Thursday
            RawEntry(value: 40, timestamp: calendar.date(byAdding: .day, value: 10, to: baseDate)!),  // Saturday
            RawEntry(value: 50, timestamp: calendar.date(byAdding: .day, value: 16, to: baseDate)!)  // Friday
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailySum(treatsMissingAsZero: true, calendar: calendar), calendar: calendar)

        #expect(pages.count == 3)
        #expect(pages[0].entries.count == 5)  // Filled from the first entry on
        #expect(pages[1].entries.count == 7)  // Fully filled, because there are weeks before and after
        #expect(pages[2].entries.count == 5)  // Filled up to the last entry

        #expect(pages[0].entries.map(\.value) == [30, 0, 0, 0, 0])  // Wednesday (first entry) through Sunday
        #expect(pages[1].entries.map(\.value) == [0, 0, 0, 30, 0, 40, 0])  // Monday through Sunday
        #expect(pages[2].entries.map(\.value) == [0, 0, 0, 0, 50])  // Monday through Friday (last entry)
    }

    @Test("Monthly average aggregation")
    func monthlyAverageAggregation() {
        let calendar = defaultCalendar()

        let jan = date(2024, 1, 15, calendar: calendar)
        let mar = date(2024, 3, 15, calendar: calendar)

        let entries = [
            RawEntry(value: 10, timestamp: jan),
            RawEntry(value: 2, timestamp: calendar.date(byAdding: .day, value: 1, to: jan)!),
            RawEntry(value: 30, timestamp: mar)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .year, dataProvider: .monthlyAverage(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        #expect(pages.count == 1)

        // Should have two months of data
        #expect(pages.first?.entries.map(\.value) == [6, 30])
    }

    @Test("Monthly average aggregation with zero filling")
    func monthlyAverageAggregation_withZeroFilling() {
        let calendar = defaultCalendar()

        let jan = date(2024, 1, 15, calendar: calendar)
        let mar = date(2024, 3, 15, calendar: calendar)

        let entries = [
            RawEntry(value: 10, timestamp: jan),
            RawEntry(value: 2, timestamp: calendar.date(byAdding: .day, value: 1, to: jan)!),
            RawEntry(value: 30, timestamp: mar)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .year, dataProvider: .monthlyAverage(treatsMissingAsZero: true, calendar: calendar), calendar: calendar)

        #expect(pages.count == 1)

        // Should have three months of data
        #expect(pages.first?.entries.map(\.value) == [6, 0, 30])
    }

    @Test("Correct page aggregation (page total)")
    func pageAggregate_sum() {
        let calendar = defaultCalendar()

        // Dec 30, 2024 to Jan 5, 2025 should be in the same week
        let entries = [
            RawEntry(value: 1, timestamp: date(2024, 12, 30, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2025, 1, 2, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2025, 1, 5, calendar: calendar))
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        // All entries should be in the same week page
        #expect(pages.count == 1)
        #expect(pages.first?.entries.count == 3)
        #expect(pages.first?.aggregator == .sum)
        #expect(pages.first?.aggregate == 6)
    }

    @Test("Correct page aggregation (page average)")
    func pageAggregate_average() {
        let calendar = defaultCalendar()

        // Dec 30, 2024 to Jan 5, 2025 should be in the same week
        let entries = [
            RawEntry(value: 1, timestamp: date(2024, 12, 30, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2025, 1, 2, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2025, 1, 5, calendar: calendar))
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailyAverage(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        // All entries should be in the same week page
        #expect(pages.count == 1)
        #expect(pages.first?.entries.count == 3)
        #expect(pages.first?.aggregator == .average)
        #expect(pages.first?.aggregate == 2)
    }

    // MARK: - Helpers

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12, calendar: Calendar) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.timeZone = calendar.timeZone

        return calendar.date(from: components)!
    }

    private func defaultCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.firstWeekday = 2  // Monday
        return calendar
    }
}
