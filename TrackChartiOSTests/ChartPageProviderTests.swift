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

    // MARK: - Gregorian Calendar Tests

    @Test("Gregorian: Empty array returns empty pages")
    func gregorianEmptyArray() {
        let calendar = Calendar(identifier: .gregorian)
        let pages = ChartPageProvider.pages(for: [], span: .week, aggregator: .dailySum(calendar: calendar), calendar: calendar)
        #expect(pages.isEmpty)
    }

    @Test("Gregorian: Week spanning year boundary")
    func gregorianWeekSpanningYear() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2  // Monday

        // Dec 30, 2024 to Jan 5, 2025 should be in the same week
        let entries = [
            ChartEntry(value: 1, timestamp: date(2024, 12, 30, calendar: calendar)),
            ChartEntry(value: 2, timestamp: date(2025, 1, 2, calendar: calendar)),
            ChartEntry(value: 3, timestamp: date(2025, 1, 5, calendar: calendar))
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum(calendar: calendar), calendar: calendar)

        // All entries should be in the same week page
        #expect(pages.count == 1)
        #expect(pages[0].entries.count == 3)
    }

    @Test("Gregorian: Month boundaries are respected")
    func gregorianMonthBoundaries() {
        let calendar = Calendar(identifier: .gregorian)
        let entries = [
            ChartEntry(value: 1, timestamp: date(2024, 10, 31, calendar: calendar)), // Last day of October
            ChartEntry(value: 2, timestamp: date(2024, 11, 1, calendar: calendar))   // First day of November
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .month, aggregator: .dailySum(calendar: calendar), calendar: calendar)

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
            ChartEntry(value: 1, timestamp: baseDate),
            ChartEntry(value: 2, timestamp: calendar.date(byAdding: .day, value: 2, to: baseDate)!),
            ChartEntry(value: 3, timestamp: calendar.date(byAdding: .day, value: 4, to: baseDate)!)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum(calendar: calendar), calendar: calendar)

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
            ChartEntry(value: 1, timestamp: firstMonth),
            ChartEntry(value: 2, timestamp: secondMonth)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .month, aggregator: .dailySum(calendar: calendar), calendar: calendar)

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
            ChartEntry(value: 10, timestamp: year1),
            ChartEntry(value: 20, timestamp: year2)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .oneYear, aggregator: .monthlySum(calendar: calendar), calendar: calendar)

        #expect(pages.count == 2)
    }

    // MARK: - Islamic Calendar Tests

    @Test("Islamic: Week grouping")
    func islamicWeekGrouping() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let baseDate = date(2024, 11, 10, calendar: calendar)
        let entries = [
            ChartEntry(value: 5, timestamp: baseDate),
            ChartEntry(value: 10, timestamp: calendar.date(byAdding: .day, value: 3, to: baseDate)!)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum(calendar: calendar), calendar: calendar)

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
            ChartEntry(value: 100, timestamp: month1),
            ChartEntry(value: 200, timestamp: month2)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .month, aggregator: .dailySum(calendar: calendar), calendar: calendar)

        #expect(pages.count == 2)
    }

    // MARK: - Edge Cases Across Calendars

    @Test("Multiple calendars: Same timestamp different grouping")
    func multipleCalendarsSameTimestamp() {
        let gregorian = Calendar(identifier: .gregorian)
        var hebrew = Calendar(identifier: .hebrew)
        hebrew.timeZone = TimeZone(identifier: "UTC")!

        let timestamp = Date(timeIntervalSince1970: 1700000000)  // Fixed point in time
        let entries = [ChartEntry(value: 42, timestamp: timestamp)]

        let gregorianPages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum(calendar: gregorian), calendar: gregorian)
        let hebrewPages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum(calendar: hebrew), calendar: hebrew)

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
        let entries = [ChartEntry(value: 10, timestamp: date(2024, 11, 11, calendar: sundayCalendar))]

        let sundayPages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum(calendar: sundayCalendar), calendar: sundayCalendar)
        let mondayPages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum(calendar: mondayCalendar), calendar: mondayCalendar)

        // Both should create pages
        #expect(!sundayPages.isEmpty)
        #expect(!mondayPages.isEmpty)

        // Period starts might differ
        #expect(sundayPages[0].periodStart != mondayPages[0].periodStart)
    }

    @Test("Leap year handling across calendars")
    func leapYearHandling() {
        let gregorian = Calendar(identifier: .gregorian)

        // 2024 is a leap year
        let febEntries = [
            ChartEntry(value: 1, timestamp: date(2024, 2, 28, calendar: gregorian)),
            ChartEntry(value: 2, timestamp: date(2024, 2, 29, calendar: gregorian)),
            ChartEntry(value: 3, timestamp: date(2024, 3, 1, calendar: gregorian))
        ]

        let pages = ChartPageProvider.pages(for: febEntries, span: .month, aggregator: .dailySum(calendar: gregorian), calendar: gregorian)

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
            ChartEntry(value: 10, timestamp: baseDate),
            ChartEntry(value: 20, timestamp: calendar.date(byAdding: .hour, value: 2, to: baseDate)!),
            ChartEntry(value: 30, timestamp: calendar.date(byAdding: .day, value: 1, to: baseDate)!)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .week, aggregator: .dailySum(calendar: calendar), calendar: calendar)

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
            ChartEntry(value: 10, timestamp: jan),
            ChartEntry(value: 20, timestamp: calendar.date(byAdding: .day, value: 1, to: jan)!),
            ChartEntry(value: 30, timestamp: feb)
        ]

        let pages = ChartPageProvider.pages(for: entries, span: .oneYear, aggregator: .monthlyAverage(calendar: calendar), calendar: calendar)

        #expect(pages.count == 1)

        // Should have two months of data
        #expect(pages[0].entries.count == 2)

        // January average should be 15
        let janEntry = pages[0].entries.first
        #expect(janEntry?.value == 15)
    }

    // MARK: - Automatic Preview Tests

    @Test("AutomaticPreview: Less than a week shows raw data")
    func automaticPreviewLessThanWeek() {
        let calendar = Calendar(identifier: .gregorian)
        let baseDate = date(2024, 11, 10, calendar: calendar)

        // 5 days of data with multiple entries per day
        let entries = [
            ChartEntry(value: 1, timestamp: baseDate),
            ChartEntry(value: 2, timestamp: calendar.date(byAdding: .hour, value: 6, to: baseDate)!),
            ChartEntry(value: 3, timestamp: calendar.date(byAdding: .day, value: 1, to: baseDate)!),
            ChartEntry(value: 4, timestamp: calendar.date(byAdding: .day, value: 4, to: baseDate)!)
        ]

        let processed = ChartDataProvider.automaticPreview(calendar: calendar).processedEntries(from: entries)

        // Should return all raw entries without aggregation
        #expect(processed.count == 4)
        #expect(processed.map(\.value) == [1, 2, 3, 4])
    }

    @Test("AutomaticPreview: 10 weeks or less uses daily sum")
    func automaticPreview10Weeks() {
        let calendar = Calendar(identifier: .gregorian)
        let baseDate = date(2024, 9, 1, calendar: calendar)

        // 8 weeks of data (56 days)
        let endDate = calendar.date(byAdding: .weekOfYear, value: 8, to: baseDate)!

        let entries = [
            ChartEntry(value: 10, timestamp: baseDate),
            ChartEntry(value: 20, timestamp: calendar.date(byAdding: .hour, value: 6, to: baseDate)!),  // Same day
            ChartEntry(value: 30, timestamp: calendar.date(byAdding: .day, value: 10, to: baseDate)!),
            ChartEntry(value: 40, timestamp: endDate)
        ]

        let processed = ChartDataProvider.automaticPreview(calendar: calendar).processedEntries(from: entries)

        // Should aggregate by day, so multiple entries on same day are summed
        #expect(processed.count == 3) // 3 different days

        // First day should sum to 30
        #expect(processed[0].value == 30)
    }

    @Test("AutomaticPreview: Up to 1 year uses weekly sum")
    func automaticPreviewOneYear() {
        let calendar = Calendar(identifier: .gregorian)
        let baseDate = date(2024, 1, 1, calendar: calendar)

        // 6 months of weekly data
        let entries = (0..<26).map { weekOffset in
            let date = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: baseDate)!
            return ChartEntry(value: Double(weekOffset + 1), timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(calendar: calendar).processedEntries(from: entries)

        // Should use weekly aggregation
        // Since each entry is in a different week, count should match
        #expect(processed.count == 26)
    }

    @Test("AutomaticPreview: Up to 5 years uses monthly sum")
    func automaticPreview5Years() {
        let calendar = Calendar(identifier: .gregorian)
        let baseDate = date(2020, 1, 1, calendar: calendar)

        // 3 years of monthly data
        let entries = (0..<36).map { monthOffset in
            let date = calendar.date(byAdding: .month, value: monthOffset, to: baseDate)!
            return ChartEntry(value: 100, timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(calendar: calendar).processedEntries(from: entries)

        // Should use monthly aggregation
        #expect(processed.count == 36)
    }

    @Test("AutomaticPreview: More than 5 years uses yearly sum")
    func automaticPreviewMoreThan5Years() {
        let calendar = Calendar(identifier: .gregorian)
        let baseDate = date(2015, 1, 1, calendar: calendar)

        // 8 years of data
        let entries = (0..<8).map { yearOffset in
            let date = calendar.date(byAdding: .year, value: yearOffset, to: baseDate)!
            return ChartEntry(value: 1000, timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(calendar: calendar).processedEntries(from: entries)

        // Should use yearly aggregation
        #expect(processed.count == 8)
    }

    @Test("AutomaticPreview: Hebrew calendar respects week boundaries")
    func automaticPreviewHebrewWeeks() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let baseDate = date(2024, 11, 1, calendar: calendar)

        // Create entries spanning multiple Hebrew weeks but less than 10
        let entries = (0..<6).map { weekOffset in
            let date = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: baseDate)!
            return ChartEntry(value: 5, timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(calendar: calendar).processedEntries(from: entries)

        // Should use daily aggregation (6 weeks < 10 weeks)
        #expect(processed.count == 6)
    }

    @Test("AutomaticPreview: Islamic calendar year boundaries")
    func automaticPreviewIslamicYears() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let baseDate = date(2020, 1, 1, calendar: calendar)

        // 3 Islamic years of data
        let entries = (0..<3).map { yearOffset in
            let date = calendar.date(byAdding: .year, value: yearOffset, to: baseDate)!
            return ChartEntry(value: 500, timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(calendar: calendar).processedEntries(from: entries)

        // Should use monthly aggregation (3 years < 5 years)
        // Each year creates one month entry
        #expect(processed.count == 3)
    }

    @Test("AutomaticPreview: Empty entries returns empty")
    func automaticPreviewEmpty() {
        let calendar = Calendar(identifier: .gregorian)
        let processed = ChartDataProvider.automaticPreview(calendar: calendar).processedEntries(from: [])

        #expect(processed.isEmpty)
    }

    @Test("AutomaticPreview: Single entry returns raw")
    func automaticPreviewSingleEntry() {
        let calendar = Calendar(identifier: .gregorian)
        let entry = ChartEntry(value: 42, timestamp: date(2024, 11, 10, calendar: calendar))

        let processed = ChartDataProvider.automaticPreview(calendar: calendar).processedEntries(from: [entry])

        #expect(processed.count == 1)
        #expect(processed[0].value == 42)
    }

    @Test("AutomaticPreview: Exactly at boundaries")
    func automaticPreviewBoundaries() {
        let calendar = Calendar(identifier: .gregorian)
        let baseDate = date(2024, 1, 1, calendar: calendar)

        // Exactly 10 weeks apart
        let endDate = calendar.date(byAdding: .weekOfYear, value: 10, to: baseDate)!
        let entries = [
            ChartEntry(value: 10, timestamp: baseDate),
            ChartEntry(value: 20, timestamp: endDate)
        ]

        let processed = ChartDataProvider.automaticPreview(calendar: calendar).processedEntries(from: entries)

        // At exactly 10 weeks, should use daily aggregation
        #expect(processed.count == 2)

        // Exactly 1 year apart
        let yearEndDate = calendar.date(byAdding: .year, value: 1, to: baseDate)!
        let yearEntries = [
            ChartEntry(value: 100, timestamp: baseDate),
            ChartEntry(value: 200, timestamp: yearEndDate)
        ]

        let yearProcessed = ChartDataProvider.automaticPreview(calendar: calendar).processedEntries(from: yearEntries)

        // At exactly 1 year, should use weekly aggregation
        #expect(!yearProcessed.isEmpty)
    }

    // MARK: - Helper Methods

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
