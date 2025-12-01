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
        let calendar = Calendar(identifier: .gregorian)
        let pages = ChartPageProvider.pages(for: [], span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)
        #expect(pages.isEmpty)
    }

    @Test("Gregorian: Week spanning year boundary")
    func gregorianWeekSpanningYear() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2  // Monday

        // Dec 30, 2024 to Jan 5, 2025 should be in the same week
        let entries = [
            RawEntry(value: 1, timestamp: date(2024, 12, 30, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2025, 1, 2, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2025, 1, 5, calendar: calendar))
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        // All entries should be in the same week page
        #expect(pages.count == 1)
        #expect(pages[0].entries.count == 3)
    }

    @Test("Gregorian: Month boundaries are respected")
    func gregorianMonthBoundaries() {
        let calendar = Calendar(identifier: .gregorian)
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
        let gregorian = Calendar(identifier: .gregorian)

        // 2024 is a leap year
        let febEntries = [
            RawEntry(value: 1, timestamp: date(2024, 2, 28, calendar: gregorian)),
            RawEntry(value: 2, timestamp: date(2024, 2, 29, calendar: gregorian)),
            RawEntry(value: 3, timestamp: date(2024, 3, 1, calendar: gregorian))
        ]

        let pages = ChartPageProvider.pages(for: febEntries, span: .month, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: gregorian), calendar: gregorian)

        // Feb and March should be separate pages
        #expect(pages.count == 2)
        #expect(pages[0].entries.count == 2)  // Feb 28 and 29
        #expect(pages[1].entries.count == 1)  // March 1
    }

    // MARK: - Aggregation Tests

    @Test("Daily sum aggregation across week")
    func dailySumAggregation() {
        let calendar = Calendar(identifier: .gregorian)
        let baseDate = date(2024, 11, 11, calendar: calendar)

        // Multiple entries on same day, plus another day
        let entries = [
            RawEntry(value: 10, timestamp: baseDate),
            RawEntry(value: 20, timestamp: calendar.date(byAdding: .hour, value: 2, to: baseDate)!),
            RawEntry(value: 30, timestamp: calendar.date(byAdding: .day, value: 1, to: baseDate)!)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, dataProvider: .dailySum(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        #expect(pages.count == 1)
        #expect(pages[0].entries.count == 2)  // Two days

        // First day should sum to 30
        let firstDay = pages[0].entries.first { calendar.isDate($0.timestamp, inSameDayAs: baseDate) }
        #expect(firstDay?.value == 30)
    }

    @Test("Monthly average aggregation")
    func monthlyAverageAggregation() {
        let calendar = Calendar(identifier: .gregorian)

        let jan = date(2024, 1, 15, calendar: calendar)
        let feb = date(2024, 2, 15, calendar: calendar)

        let entries = [
            RawEntry(value: 10, timestamp: jan),
            RawEntry(value: 20, timestamp: calendar.date(byAdding: .day, value: 1, to: jan)!),
            RawEntry(value: 30, timestamp: feb)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .year, dataProvider: .monthlyAverage(treatsMissingAsZero: false, calendar: calendar), calendar: calendar)

        #expect(pages.count == 1)

        // Should have two months of data
        #expect(pages[0].entries.count == 2)

        // January average should be 15
        let janEntry = pages[0].entries.first
        #expect(janEntry?.value == 15)
    }

    @Test("Correct page aggregation (page total)")
    func pageAggregate_sum() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2  // Monday

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
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2  // Monday

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
}
