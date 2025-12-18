//
//  ChartPageProviderTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 06.11.25.
//

import Testing
import Foundation
import DataProcessing

struct ChartPageProviderTests {
    @Test func emptyInput_returnsEmpty() {
        expect([], for: [], span: .week, provider: .dailySum)
    }

    // TODO: Test titles
    //        let calendar = Calendar.defaultCalendar()
    //
    //        // Dec 30, 2024 to Jan 5, 2025 should be in the same week
    //        let entries = [
    //            RawEntry(value: 1, timestamp: date(2024, 12, 30, calendar: calendar)),
    //            RawEntry(value: 2, timestamp: date(2025, 1, 2, calendar: calendar)),
    //            RawEntry(value: 3, timestamp: date(2025, 1, 5, calendar: calendar))
    //        ]
    //
    //        let pages = pages(for: entries, .week, .dailySum, calendar)
    //
    //        // All entries should be in the same week page
    //        #expect(pages.count == 1)
    //        #expect(pages.first?.entries.map(\.value) == [1, 2, 3])
    //
    //        let expectedDates = entries.map(\.timestamp).map { calendar.startOfDay(for: $0) }
    //        #expect(pages.first?.entries.map(\.timestamp) == expectedDates)
    //
    //        let formatStyle = Date.FormatStyle(calendar: calendar)
    //        let first = expectedDates[0].formatted(formatStyle.day().month(.abbreviated))
    //        let last = expectedDates[2].formatted(formatStyle.day().month(.abbreviated).year())
    //        let expectedTitle = "\(first) – \(last)"
    //        #expect(pages.first?.title == expectedTitle)

    // MARK: - Gregorian Calendar

    @Test func sameWeekAcrossYearBoundary_returnsOneWeekPage() {
        expect(
            [[
                (value: 1, year: 2024, month: 12, day: 30, hour: 0),
                (value: 2, year: 2025, month: 1, day: 2, hour: 0),
                (value: 3, year: 2025, month: 1, day: 5, hour: 0)
            ]],
            for: [
                (value: 1, year: 2024, month: 12, day: 30, hour: 12),
                (value: 2, year: 2025, month: 1, day: 2, hour: 12),
                (value: 3, year: 2025, month: 1, day: 5, hour: 12)
            ],
            span: .week,
            provider: .dailySum
        )
    }

    @Test func crossingMonthBoundaries_returnsTwoMonthPages() {
        expect(
            [
                [(value: 1, year: 2024, month: 10, day: 31, hour: 0)],
                [(value: 2, year: 2024, month: 11, day: 1, hour: 0)]
            ],
            for: [
                (value: 1, year: 2024, month: 10, day: 31, hour: 12),
                (value: 2, year: 2024, month: 11, day: 1, hour: 12)
            ],
            span: .month,
            provider: .dailySum
        )
    }

    // MARK: - Hebrew Calendar

    @Test func hebrewSameWeek() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [[
                (value: 1, year: 5785, month: 2, day: 2, hour: 0),
                (value: 4.5, year: 5785, month: 2, day: 5, hour: 0),
                (value: 3, year: 5785, month: 2, day: 8, hour: 0)
            ]],
            for: [
                (value: 1, year: 5785, month: 2, day: 2, hour: 12),
                (value: 2, year: 5785, month: 2, day: 5, hour: 12),
                (value: 2.5, year: 5785, month: 2, day: 5, hour: 14),
                (value: 3, year: 5785, month: 2, day: 8, hour: 12)
            ],
            in: calendar,
            span: .week,
            provider: .dailySum
        )
    }

    @Test func hebrewTwoWeeks() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [
                [
                    (value: 2.5, year: 5785, month: 2, day: 2, hour: 0),
                    (value: 2, year: 5785, month: 2, day: 5, hour: 0)
                ],
                [
                    (value: 3, year: 5785, month: 2, day: 9, hour: 0)
                ]
            ],
            for: [
                (value: 1, year: 5785, month: 2, day: 2, hour: 12),
                (value: 1.5, year: 5785, month: 2, day: 2, hour: 15),
                (value: 2, year: 5785, month: 2, day: 5, hour: 12),
                (value: 3, year: 5785, month: 2, day: 9, hour: 12)
            ],
            in: calendar,
            span: .week,
            provider: .dailySum
        )
    }

    @Test func hebrewSameMonth() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [[
                (value: 2.5, year: 5785, month: 11, day: 1, hour: 0),
                (value: 2, year: 5785, month: 11, day: 29, hour: 0)
            ]],
            for: [
                (value: 1, year: 5785, month: 11, day: 1, hour: 12),
                (value: 1.5, year: 5785, month: 11, day: 1, hour: 13),
                (value: 2, year: 5785, month: 11, day: 29, hour: 12)
            ],
            in: calendar,
            span: .month,
            provider: .dailySum
        )
    }

    @Test func hebrewTwoMonths() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [
                [(value: 2.5, year: 5785, month: 11, day: 1, hour: 0)],
                [(value: 2, year: 5785, month: 12, day: 1, hour: 0)]
            ],
            for: [
                (value: 1, year: 5785, month: 11, day: 1, hour: 12),
                (value: 1.5, year: 5785, month: 11, day: 1, hour: 13),
                (value: 2, year: 5785, month: 12, day: 1, hour: 12)
            ],
            in: calendar,
            span: .month,
            provider: .dailySum
        )
    }

    @Test func hebrewSameYear() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [[
                (value: 20.5, year: 5785, month: 3, day: 1, hour: 0),
                (value: 20, year: 5785, month: 12, day: 1, hour: 0)
            ]],
            for: [
                (value: 10, year: 5785, month: 3, day: 15, hour: 12),
                (value: 10.5, year: 5785, month: 3, day: 30, hour: 12),
                (value: 20, year: 5785, month: 12, day: 15, hour: 12)
            ],
            in: calendar,
            span: .year,
            provider: .monthlySum
        )
    }

    @Test func hebrewTwoYears() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [
                [
                    (value: 20.5, year: 5785, month: 3, day: 1, hour: 0),
                    (value: 11, year: 5785, month: 12, day: 1, hour: 0)
                ],
                [
                    (value: 20, year: 5786, month: 3, day: 1, hour: 0)
                ]
            ],
            for: [
                (value: 10, year: 5785, month: 3, day: 15, hour: 12),
                (value: 10.5, year: 5785, month: 3, day: 30, hour: 12),
                (value: 11, year: 5785, month: 12, day: 15, hour: 12),
                (value: 20, year: 5786, month: 3, day: 15, hour: 12)
            ],
            in: calendar,
            span: .year,
            provider: .monthlySum
        )
    }

    // MARK: - Islamic Calendar Tests

    @Test func islamicSameWeek() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [[
                (value: 5, year: 1447, month: 6, day: 17, hour: 0),
                (value: 12.5, year: 1447, month: 6, day: 22, hour: 0),
                (value: 10, year: 1447, month: 6, day: 23, hour: 0)
            ]],
            for: [
                (value: 5, year: 1447, month: 6, day: 17, hour: 12),
                (value: 6, year: 1447, month: 6, day: 22, hour: 12),
                (value: 6.5, year: 1447, month: 6, day: 22, hour: 14),
                (value: 10, year: 1447, month: 6, day: 23, hour: 12)
            ],
            in: calendar,
            span: .week,
            provider: .dailySum
        )
    }

    @Test func islamicTwoWeeks() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [
                [
                    (value: 5, year: 1447, month: 6, day: 17, hour: 0),
                    (value: 12.5, year: 1447, month: 6, day: 23, hour: 0)
                ],
                [
                    (value: 10, year: 1447, month: 6, day: 24, hour: 0)
                ]
            ],
            for: [
                (value: 5, year: 1447, month: 6, day: 17, hour: 12),
                (value: 6, year: 1447, month: 6, day: 23, hour: 12),
                (value: 6.5, year: 1447, month: 6, day: 23, hour: 14),
                (value: 10, year: 1447, month: 6, day: 24, hour: 12)
            ],
            in: calendar,
            span: .week,
            provider: .dailySum
        )
    }

    @Test func islamicSameMonth() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [[
                (value: 100, year: 1447, month: 6, day: 1, hour: 0),
                (value: 150, year: 1447, month: 6, day: 15, hour: 0),
                (value: 400.5, year: 1447, month: 6, day: 30, hour: 0)
            ]],
            for: [
                (value: 100, year: 1447, month: 6, day: 1, hour: 12),
                (value: 150, year: 1447, month: 6, day: 15, hour: 12),
                (value: 200, year: 1447, month: 6, day: 30, hour: 12),
                (value: 200.5, year: 1447, month: 6, day: 30, hour: 16)
            ],
            in: calendar,
            span: .month,
            provider: .dailySum
        )
    }

    @Test func islamicTwoMonths() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [
                [
                    (value: 100, year: 1447, month: 6, day: 1, hour: 0),
                    (value: 150, year: 1447, month: 6, day: 30, hour: 0)
                ],
                [
                    (value: 400.5, year: 1447, month: 7, day: 1, hour: 0)
                ]
            ],
            for: [
                (value: 100, year: 1447, month: 6, day: 1, hour: 12),
                (value: 150, year: 1447, month: 6, day: 30, hour: 12),
                (value: 200, year: 1447, month: 7, day: 1, hour: 12),
                (value: 200.5, year: 1447, month: 7, day: 1, hour: 16)
            ],
            in: calendar,
            span: .month,
            provider: .dailySum
        )
    }

    // MARK: - Edge Cases Across Calendars

    @Test func differentFirstWeekday() {
        var sundayCalendar = Calendar(identifier: .gregorian)
        sundayCalendar.firstWeekday = 1  // Sunday

        var mondayCalendar = Calendar(identifier: .gregorian)
        mondayCalendar.firstWeekday = 2  // Monday

        let inputData: [(value: Double, year: Int, month: Int, day: Int, hour: Int)] = [
            (value: 10, year: 2024, month: 11, day: 10, hour: 12),
            (value: 11, year: 2024, month: 11, day: 11, hour: 12)
        ]

        // Sunday calendar: Sunday is in the same week as the following Monday
        expect(
            [[
                (value: 10, year: 2024, month: 11, day: 10, hour: 0),
                (value: 11, year: 2024, month: 11, day: 11, hour: 0)
            ]],
            for: inputData,
            in: sundayCalendar,
            span: .week,
            provider: .dailySum
        )

        // Monday calendar: Monday starts a new week
        expect(
            [
                [(value: 10, year: 2024, month: 11, day: 10, hour: 0)],
                [(value: 11, year: 2024, month: 11, day: 11, hour: 0)]
            ],
            for: inputData,
            in: mondayCalendar,
            span: .week,
            provider: .dailySum
        )
    }

    @Test func leapYearHandling() {
        expect(
            [
                [
                    (value: 2.5, year: 2024, month: 2, day: 28, hour: 0),
                    (value: 2, year: 2024, month: 2, day: 29, hour: 0)
                ],
                [
                    (value: 3, year: 2024, month: 3, day: 1, hour: 0)
                ]
            ],
            for: [
                (value: 1, year: 2024, month: 2, day: 28, hour: 12),
                (value: 1.5, year: 2024, month: 2, day: 28, hour: 17),
                (value: 2, year: 2024, month: 2, day: 29, hour: 12),
                (value: 3, year: 2024, month: 3, day: 1, hour: 12)
            ],
            span: .month,
            provider: .dailySum
        )
    }

    // MARK: - Aggregation Tests

    @Test("Daily sum aggregation across week")
    func dailySumAggregation() {
        let calendar = Calendar.defaultCalendar()
        let baseDate = date(2024, 11, 11, calendar: calendar)

        // Multiple entries on same day, plus another day
        let entries = [
            RawEntry(value: 10, timestamp: baseDate),
            RawEntry(value: 2, timestamp: calendar.date(byAdding: .hour, value: 2, to: baseDate)!),
            RawEntry(value: 40, timestamp: calendar.date(byAdding: .day, value: 2, to: baseDate)!)
        ]

        let pages = pages(for: entries, .week, .dailySum, calendar)

        #expect(pages.count == 1)
        #expect(pages[0].entries.count == 2)  // Two days
        #expect(pages[0].entries.map(\.value) == [12, 40])
    }

    @Test("Daily sum aggregation across week with zero filling")
    func dailySumAggregation_withZeroFilling() {
        let calendar = Calendar.defaultCalendar()
        let baseDate = date(2025, 11, 5, calendar: calendar)  // Wednesday

        // Multiple entries on same day, plus two other days in the next weeks, with empty days in between
        let entries = [
            RawEntry(value: 10, timestamp: baseDate),  // Wednesday
            RawEntry(value: 20, timestamp: calendar.date(byAdding: .hour, value: 2, to: baseDate)!),  // same day
            RawEntry(value: 30, timestamp: calendar.date(byAdding: .day, value: 8, to: baseDate)!),  // Thursday
            RawEntry(value: 40, timestamp: calendar.date(byAdding: .day, value: 10, to: baseDate)!),  // Saturday
            RawEntry(value: 50, timestamp: calendar.date(byAdding: .day, value: 16, to: baseDate)!)  // Friday
        ]

        let pages = pages(for: entries, .week, .dailySum, calendar, treatsMissingAsZero: true)

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
        let calendar = Calendar.defaultCalendar()

        let jan = date(2024, 1, 15, calendar: calendar)
        let mar = date(2024, 3, 15, calendar: calendar)

        let entries = [
            RawEntry(value: 10, timestamp: jan),
            RawEntry(value: 2, timestamp: calendar.date(byAdding: .day, value: 1, to: jan)!),
            RawEntry(value: 30, timestamp: mar)
        ]

        let pages = pages(for: entries, .year, .monthlyAverage, calendar)

        #expect(pages.count == 1)

        // Should have two months of data
        #expect(pages.first?.entries.map(\.value) == [6, 30])
    }

    @Test("Monthly average aggregation with zero filling")
    func monthlyAverageAggregation_withZeroFilling() {
        let calendar = Calendar.defaultCalendar()

        let jan = date(2024, 1, 15, calendar: calendar)
        let mar = date(2024, 3, 15, calendar: calendar)

        let entries = [
            RawEntry(value: 10, timestamp: jan),
            RawEntry(value: 2, timestamp: calendar.date(byAdding: .day, value: 1, to: jan)!),
            RawEntry(value: 30, timestamp: mar)
        ]

        let pages = pages(for: entries, .year, .monthlyAverage, calendar, treatsMissingAsZero: true)

        #expect(pages.count == 1)

        // Should have three months of data
        #expect(pages.first?.entries.map(\.value) == [6, 0, 30])
    }

    @Test("Correct page aggregation (page total)")
    func pageAggregate_sum() {
        let calendar = Calendar.defaultCalendar()

        // Dec 30, 2024 to Jan 5, 2025 should be in the same week
        let entries = [
            RawEntry(value: 1, timestamp: date(2024, 12, 30, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2025, 1, 2, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2025, 1, 5, calendar: calendar))
        ]

        let pages = pages(for: entries, .week, .dailySum, calendar)

        // All entries should be in the same week page
        #expect(pages.count == 1)
        #expect(pages.first?.entries.count == 3)
        #expect(pages.first?.aggregator == .sum)
        #expect(pages.first?.aggregate == 6)
    }

    @Test("Correct page aggregation (page average)")
    func pageAggregate_average() {
        let calendar = Calendar.defaultCalendar()

        // Dec 30, 2024 to Jan 5, 2025 should be in the same week
        let entries = [
            RawEntry(value: 1, timestamp: date(2024, 12, 30, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2025, 1, 2, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2025, 1, 5, calendar: calendar))
        ]

        let pages = pages(for: entries, .week, .dailyAverage, calendar)

        // All entries should be in the same week page
        #expect(pages.count == 1)
        #expect(pages.first?.entries.count == 3)
        #expect(pages.first?.aggregator == .average)
        #expect(pages.first?.aggregate == 2)
    }

    // MARK: - Helpers

    private func expect(
        _ expectedData: [[(value: Double, year: Int, month: Int, day: Int, hour: Int)]],
        for inputData: [(value: Double, year: Int, month: Int, day: Int, hour: Int)],
        in calendar: Calendar = Calendar.defaultCalendar(),
        span: TimeSpan,
        provider: Provider,
        treatsMissingAsZero: Bool = false,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let inputEntries = inputData.map {
            RawEntry(value: $0.value, timestamp: date($0.year, $0.month, $0.day, hour: $0.hour, calendar: calendar))
        }

        let pages = pages(for: inputEntries, span, provider, calendar, treatsMissingAsZero: treatsMissingAsZero)

        let expectedValues = expectedData.map { $0.map(\.value) }
        let expectedDates = expectedData.map { $0.map { date($0.year, $0.month, $0.day, hour: $0.hour, calendar: calendar) } }
        #expect(pages.map { $0.entries.map(\.value) } == expectedValues, sourceLocation: sourceLocation)
        #expect(pages.map { $0.entries.map(\.timestamp) } == expectedDates, sourceLocation: sourceLocation)
    }

    private enum Provider {
        case dailySum
        case dailyAverage
        case monthlySum
        case monthlyAverage
    }

    private func pages(for entries: [RawEntry], _ span: TimeSpan, _ dataProvider: Provider, _ calendar: Calendar, treatsMissingAsZero: Bool = false) -> [ChartPage] {
        let provider: ChartDataProvider = switch dataProvider {
        case .dailySum: .dailySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        case .dailyAverage: .dailyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        case .monthlySum: .monthlySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        case .monthlyAverage: .monthlyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        }

        return ChartPageProvider.pages(for: entries, span: span, dataProvider: provider, calendar: calendar)
    }

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

private extension Calendar {
    static func defaultCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.firstWeekday = 2  // Monday
        return calendar
    }
}
