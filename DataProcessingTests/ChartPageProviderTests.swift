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

    @Test func emptyInput_withZeroFilling_returnsEmpty() {
        expect([], for: [], span: .week, provider: .dailySum, treatsMissingAsZero: true)
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

    @Test func oneWeek_returnsOneWeekPage() {
        expect(
            [[
                (value: 1, year: 2024, month: 7, day: 8, hour: 0),
                (value: 2, year: 2024, month: 7, day: 10, hour: 0),
                (value: 3, year: 2024, month: 7, day: 14, hour: 0)
            ]],
            for: [
                (value: 1, year: 2024, month: 7, day: 8, hour: 12),
                (value: 2, year: 2024, month: 7, day: 10, hour: 12),
                (value: 3, year: 2024, month: 7, day: 14, hour: 12)
            ],
            span: .week,
            provider: .dailySum
        )
    }

    @Test func oneWeek_withZeroFilling() {
        expect(
            [[
                (value: 1, year: 2024, month: 7, day: 8, hour: 0),
                (value: 0, year: 2024, month: 7, day: 9, hour: 0),
                (value: 2, year: 2024, month: 7, day: 10, hour: 0),
                (value: 0, year: 2024, month: 7, day: 11, hour: 0),
                (value: 0, year: 2024, month: 7, day: 12, hour: 0),
                (value: 0, year: 2024, month: 7, day: 13, hour: 0),
                (value: 3, year: 2024, month: 7, day: 14, hour: 0)
            ]],
            for: [
                (value: 1, year: 2024, month: 7, day: 8, hour: 12),
                (value: 2, year: 2024, month: 7, day: 10, hour: 12),
                (value: 3, year: 2024, month: 7, day: 14, hour: 12)
            ],
            span: .week,
            provider: .dailySum,
            treatsMissingAsZero: true
        )
    }

    @Test func oneWeek_acrossMonthBoundary_returnsOneWeekPage() {
        expect(
            [[
                (value: 1, year: 2024, month: 7, day: 29, hour: 0),
                (value: 2, year: 2024, month: 8, day: 1, hour: 0),
                (value: 3, year: 2024, month: 8, day: 4, hour: 0)
            ]],
            for: [
                (value: 1, year: 2024, month: 7, day: 29, hour: 12),
                (value: 2, year: 2024, month: 8, day: 1, hour: 12),
                (value: 3, year: 2024, month: 8, day: 4, hour: 12)
            ],
            span: .week,
            provider: .dailySum
        )
    }

    @Test func oneWeek_acrossMonthBoundary_withZeroFilling() {
        expect(
            [[
                (value: 1, year: 2024, month: 7, day: 29, hour: 0),
                (value: 0, year: 2024, month: 7, day: 30, hour: 0),
                (value: 0, year: 2024, month: 7, day: 31, hour: 0),
                (value: 2, year: 2024, month: 8, day: 1, hour: 0),
                (value: 0, year: 2024, month: 8, day: 2, hour: 0),
                (value: 0, year: 2024, month: 8, day: 3, hour: 0),
                (value: 3, year: 2024, month: 8, day: 4, hour: 0)
            ]],
            for: [
                (value: 1, year: 2024, month: 7, day: 29, hour: 12),
                (value: 2, year: 2024, month: 8, day: 1, hour: 12),
                (value: 3, year: 2024, month: 8, day: 4, hour: 12)
            ],
            span: .week,
            provider: .dailySum,
            treatsMissingAsZero: true
        )
    }

    @Test func oneWeek_acrossYearBoundary_returnsOneWeekPage() {
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

    @Test func oneWeek_acrossYearBoundary_withZeroFilling() {
        expect(
            [[
                (value: 1, year: 2024, month: 12, day: 30, hour: 0),
                (value: 0, year: 2024, month: 12, day: 31, hour: 0),
                (value: 0, year: 2025, month: 1, day: 1, hour: 0),
                (value: 2, year: 2025, month: 1, day: 2, hour: 0),
                (value: 0, year: 2025, month: 1, day: 3, hour: 0),
                (value: 0, year: 2025, month: 1, day: 4, hour: 0),
                (value: 3, year: 2025, month: 1, day: 5, hour: 0)
            ]],
            for: [
                (value: 1, year: 2024, month: 12, day: 30, hour: 12),
                (value: 2, year: 2025, month: 1, day: 2, hour: 12),
                (value: 3, year: 2025, month: 1, day: 5, hour: 12)
            ],
            span: .week,
            provider: .dailySum,
            treatsMissingAsZero: true
        )
    }

    @Test func twoWeeks_returnsTwoWeekPages() {
        expect(
            [
                [
                    (value: 1, year: 2024, month: 7, day: 8, hour: 0),
                    (value: 2, year: 2024, month: 7, day: 10, hour: 0)
                ],
                [
                    (value: 3, year: 2024, month: 7, day: 15, hour: 0)
                ]
            ],
            for: [
                (value: 1, year: 2024, month: 7, day: 8, hour: 12),
                (value: 2, year: 2024, month: 7, day: 10, hour: 12),
                (value: 3, year: 2024, month: 7, day: 15, hour: 12)
            ],
            span: .week,
            provider: .dailySum
        )
    }

    @Test func twoWeeks_withZeroFilling() {
        expect(
            [
                [
                    (value: 1, year: 2024, month: 7, day: 8, hour: 0),
                    (value: 0, year: 2024, month: 7, day: 9, hour: 0),
                    (value: 2, year: 2024, month: 7, day: 10, hour: 0),
                    (value: 0, year: 2024, month: 7, day: 11, hour: 0),
                    (value: 0, year: 2024, month: 7, day: 12, hour: 0),
                    (value: 0, year: 2024, month: 7, day: 13, hour: 0),
                    (value: 0, year: 2024, month: 7, day: 14, hour: 0),
                ],
                [
                    (value: 0, year: 2024, month: 7, day: 15, hour: 0),
                    (value: 3, year: 2024, month: 7, day: 16, hour: 0)
                ]
            ],
            for: [
                (value: 1, year: 2024, month: 7, day: 8, hour: 12),
                (value: 2, year: 2024, month: 7, day: 10, hour: 12),
                (value: 3, year: 2024, month: 7, day: 16, hour: 12)
            ],
            span: .week,
            provider: .dailySum,
            treatsMissingAsZero: true
        )
    }

    @Test func oneMonth() {
        expect(
            [[
                (value: 2.5, year: 2024, month: 10, day: 30, hour: 0),
                (value: 2, year: 2024, month: 10, day: 31, hour: 0)
            ]],
            for: [
                (value: 1, year: 2024, month: 10, day: 30, hour: 12),
                (value: 1.5, year: 2024, month: 10, day: 30, hour: 12),
                (value: 2, year: 2024, month: 10, day: 31, hour: 12)
            ],
            span: .month,
            provider: .dailySum
        )
    }

    @Test func oneMonth_withZeroFilling() {
        expect(
            [[
                (value: 2.5, year: 2024, month: 10, day: 28, hour: 0),
                (value: 0, year: 2024, month: 10, day: 29, hour: 0),
                (value: 0, year: 2024, month: 10, day: 30, hour: 0),
                (value: 2, year: 2024, month: 10, day: 31, hour: 0)
            ]],
            for: [
                (value: 1, year: 2024, month: 10, day: 28, hour: 12),
                (value: 1.5, year: 2024, month: 10, day: 28, hour: 12),
                (value: 2, year: 2024, month: 10, day: 31, hour: 12)
            ],
            span: .month,
            provider: .dailySum,
            treatsMissingAsZero: true
        )
    }

    @Test func twoMonths() {
        expect(
            [
                [(value: 2.5, year: 2024, month: 10, day: 31, hour: 0)],
                [(value: 2, year: 2024, month: 11, day: 1, hour: 0)]
            ],
            for: [
                (value: 1, year: 2024, month: 10, day: 31, hour: 12),
                (value: 1.5, year: 2024, month: 10, day: 31, hour: 12),
                (value: 2, year: 2024, month: 11, day: 1, hour: 12)
            ],
            span: .month,
            provider: .dailySum
        )
    }

    @Test func twoMonths_withZeroFilling() {
        expect(
            [
                [
                    (value: 2.5, year: 2024, month: 10, day: 29, hour: 0),
                    (value: 0, year: 2024, month: 10, day: 30, hour: 0),
                    (value: 0, year: 2024, month: 10, day: 31, hour: 0)
                ],
                [
                    (value: 2, year: 2024, month: 11, day: 1, hour: 0)
                ]
            ],
            for: [
                (value: 1, year: 2024, month: 10, day: 29, hour: 12),
                (value: 1.5, year: 2024, month: 10, day: 29, hour: 12),
                (value: 2, year: 2024, month: 11, day: 1, hour: 12)
            ],
            span: .month,
            provider: .dailySum,
            treatsMissingAsZero: true
        )
    }

    @Test func oneYear() {
        expect(
            [[
                (value: 1, year: 2024, month: 1, day: 1, hour: 0),
                (value: 4.5, year: 2024, month: 5, day: 1, hour: 0),
                (value: 3, year: 2024, month: 12, day: 1, hour: 0)
            ]],
            for: [
                (value: 1, year: 2024, month: 1, day: 10, hour: 12),
                (value: 2, year: 2024, month: 5, day: 14, hour: 12),
                (value: 2.5, year: 2024, month: 5, day: 19, hour: 12),
                (value: 3, year: 2024, month: 12, day: 31, hour: 12)
            ],
            span: .year,
            provider: .monthlySum
        )
    }

    @Test func oneYear_withZeroFilling() {
        expect(
            [[
                (value: 1, year: 2024, month: 1, day: 1, hour: 0),
                (value: 0, year: 2024, month: 2, day: 1, hour: 0),
                (value: 0, year: 2024, month: 3, day: 1, hour: 0),
                (value: 0, year: 2024, month: 4, day: 1, hour: 0),
                (value: 4.5, year: 2024, month: 5, day: 1, hour: 0),
                (value: 0, year: 2024, month: 6, day: 1, hour: 0),
                (value: 0, year: 2024, month: 7, day: 1, hour: 0),
                (value: 0, year: 2024, month: 8, day: 1, hour: 0),
                (value: 0, year: 2024, month: 9, day: 1, hour: 0),
                (value: 0, year: 2024, month: 10, day: 1, hour: 0),
                (value: 0, year: 2024, month: 11, day: 1, hour: 0),
                (value: 3, year: 2024, month: 12, day: 1, hour: 0)
            ]],
            for: [
                (value: 1, year: 2024, month: 1, day: 10, hour: 12),
                (value: 2, year: 2024, month: 5, day: 14, hour: 12),
                (value: 2.5, year: 2024, month: 5, day: 19, hour: 12),
                (value: 3, year: 2024, month: 12, day: 31, hour: 12)
            ],
            span: .year,
            provider: .monthlySum,
            treatsMissingAsZero: true
        )
    }

    @Test func twoYears() {
        expect(
            [
                [(value: 2.5, year: 2024, month: 12, day: 1, hour: 0)],
                [(value: 2, year: 2025, month: 1, day: 1, hour: 0)]
            ],
            for: [
                (value: 1, year: 2024, month: 12, day: 10, hour: 12),
                (value: 1.5, year: 2024, month: 12, day: 31, hour: 12),
                (value: 2, year: 2025, month: 1, day: 1, hour: 12)
            ],
            span: .year,
            provider: .monthlySum
        )
    }

    @Test func twoYears_withZeroFilling() {
        expect(
            [
                [
                    (value: 2.5, year: 2024, month: 12, day: 1, hour: 0)
                ],
                [
                    (value: 0, year: 2025, month: 1, day: 1, hour: 0),
                    (value: 0, year: 2025, month: 2, day: 1, hour: 0),
                    (value: 2, year: 2025, month: 3, day: 1, hour: 0)
                ]
            ],
            for: [
                (value: 1, year: 2024, month: 12, day: 10, hour: 12),
                (value: 1.5, year: 2024, month: 12, day: 31, hour: 12),
                (value: 2, year: 2025, month: 3, day: 1, hour: 12)
            ],
            span: .year,
            provider: .monthlySum,
            treatsMissingAsZero: true
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

    @Test func hebrewSameWeek_withZeroFilling() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [[
                (value: 1, year: 5785, month: 2, day: 2, hour: 0),
                (value: 0, year: 5785, month: 2, day: 3, hour: 0),
                (value: 0, year: 5785, month: 2, day: 4, hour: 0),
                (value: 4.5, year: 5785, month: 2, day: 5, hour: 0),
                (value: 0, year: 5785, month: 2, day: 6, hour: 0),
                (value: 0, year: 5785, month: 2, day: 7, hour: 0),
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
            provider: .dailySum,
            treatsMissingAsZero: true
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

    @Test func hebrewTwoWeeks_withZeroFilling() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [
                [
                    (value: 2.5, year: 5785, month: 2, day: 2, hour: 0),
                    (value: 0, year: 5785, month: 2, day: 3, hour: 0),
                    (value: 0, year: 5785, month: 2, day: 4, hour: 0),
                    (value: 2, year: 5785, month: 2, day: 5, hour: 0),
                    (value: 0, year: 5785, month: 2, day: 6, hour: 0),
                    (value: 0, year: 5785, month: 2, day: 7, hour: 0),
                    (value: 0, year: 5785, month: 2, day: 8, hour: 0),
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
            provider: .dailySum,
            treatsMissingAsZero: true
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

    @Test func hebrewSameMonth_withZeroFilling() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [[
                (value: 2.5, year: 5785, month: 11, day: 1, hour: 0),
                (value: 0, year: 5785, month: 11, day: 2, hour: 0),
                (value: 0, year: 5785, month: 11, day: 3, hour: 0),
                (value: 0, year: 5785, month: 11, day: 4, hour: 0),
                (value: 2, year: 5785, month: 11, day: 5, hour: 0)
            ]],
            for: [
                (value: 1, year: 5785, month: 11, day: 1, hour: 12),
                (value: 1.5, year: 5785, month: 11, day: 1, hour: 13),
                (value: 2, year: 5785, month: 11, day: 5, hour: 12)
            ],
            in: calendar,
            span: .month,
            provider: .dailySum,
            treatsMissingAsZero: true
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

    @Test func hebrewTwoMonths_withZeroFilling() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [
                [(value: 2.5, year: 5785, month: 11, day: 25, hour: 0),
                (value: 0, year: 5785, month: 11, day: 26, hour: 0),
                (value: 0, year: 5785, month: 11, day: 27, hour: 0),
                (value: 0, year: 5785, month: 11, day: 28, hour: 0),
                (value: 0, year: 5785, month: 11, day: 29, hour: 0)],
                [(value: 2, year: 5785, month: 12, day: 1, hour: 0)]
            ],
            for: [
                (value: 1, year: 5785, month: 11, day: 25, hour: 12),
                (value: 1.5, year: 5785, month: 11, day: 25, hour: 13),
                (value: 2, year: 5785, month: 12, day: 1, hour: 12)
            ],
            in: calendar,
            span: .month,
            provider: .dailySum,
            treatsMissingAsZero: true
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

    @Test func hebrewSameYear_withZeroFilling() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [[
                (value: 20.5, year: 5785, month: 3, day: 1, hour: 0),
                (value: 0, year: 5785, month: 4, day: 1, hour: 0),
                (value: 0, year: 5785, month: 5, day: 1, hour: 0),
                (value: 20, year: 5785, month: 6, day: 1, hour: 0)
            ]],
            for: [
                (value: 10, year: 5785, month: 3, day: 15, hour: 12),
                (value: 10.5, year: 5785, month: 3, day: 30, hour: 12),
                (value: 20, year: 5785, month: 6, day: 15, hour: 12)
            ],
            in: calendar,
            span: .year,
            provider: .monthlySum,
            treatsMissingAsZero: true
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

    @Test func hebrewTwoYears_withZeroFilling() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [
                [
                    (value: 20.5, year: 5785, month: 7, day: 1, hour: 0),
                    (value: 0, year: 5785, month: 8, day: 1, hour: 0),
                    (value: 11, year: 5785, month: 9, day: 1, hour: 0),
                    (value: 0, year: 5785, month: 10, day: 1, hour: 0),
                    (value: 0, year: 5785, month: 11, day: 1, hour: 0),
                    (value: 0, year: 5785, month: 12, day: 1, hour: 0),
                    (value: 0, year: 5785, month: 13, day: 1, hour: 0),
                ],
                [
                    (value: 0, year: 5786, month: 1, day: 1, hour: 0),
                    (value: 0, year: 5786, month: 2, day: 1, hour: 0),
                    (value: 20, year: 5786, month: 3, day: 1, hour: 0)
                ]
            ],
            for: [
                (value: 10, year: 5785, month: 7, day: 15, hour: 12),
                (value: 10.5, year: 5785, month: 7, day: 20, hour: 12),
                (value: 11, year: 5785, month: 9, day: 15, hour: 12),
                (value: 20, year: 5786, month: 3, day: 15, hour: 12)
            ],
            in: calendar,
            span: .year,
            provider: .monthlySum,
            treatsMissingAsZero: true
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

    @Test func islamicSameWeek_withZeroFilling() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [[
                (value: 5, year: 1447, month: 6, day: 17, hour: 0),
                (value: 0, year: 1447, month: 6, day: 18, hour: 0),
                (value: 0, year: 1447, month: 6, day: 19, hour: 0),
                (value: 0, year: 1447, month: 6, day: 20, hour: 0),
                (value: 0, year: 1447, month: 6, day: 21, hour: 0),
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
            provider: .dailySum,
            treatsMissingAsZero: true
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

    @Test func islamicTwoWeeks_withZeroFilling() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [
                [
                    (value: 5, year: 1447, month: 6, day: 17, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 18, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 19, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 20, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 21, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 22, hour: 0),
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
            provider: .dailySum,
            treatsMissingAsZero: true
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

    @Test func islamicSameMonth_withZeroFilling() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [[
                (value: 100, year: 1447, month: 6, day: 12, hour: 0),
                (value: 0, year: 1447, month: 6, day: 13, hour: 0),
                (value: 0, year: 1447, month: 6, day: 14, hour: 0),
                (value: 150, year: 1447, month: 6, day: 15, hour: 0),
                (value: 0, year: 1447, month: 6, day: 16, hour: 0),
                (value: 400.5, year: 1447, month: 6, day: 17, hour: 0)
            ]],
            for: [
                (value: 100, year: 1447, month: 6, day: 12, hour: 12),
                (value: 150, year: 1447, month: 6, day: 15, hour: 12),
                (value: 200, year: 1447, month: 6, day: 17, hour: 12),
                (value: 200.5, year: 1447, month: 6, day: 17, hour: 16)
            ],
            in: calendar,
            span: .month,
            provider: .dailySum,
            treatsMissingAsZero: true
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

    @Test func islamicTwoMonths_withZeroFilling() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        expect(
            [
                [
                    (value: 100, year: 1447, month: 6, day: 25, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 26, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 27, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 28, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 29, hour: 0),
                    (value: 150, year: 1447, month: 6, day: 30, hour: 0)
                ],
                [
                    (value: 0, year: 1447, month: 7, day: 1, hour: 0),
                    (value: 400.5, year: 1447, month: 7, day: 2, hour: 0)
                ]
            ],
            for: [
                (value: 100, year: 1447, month: 6, day: 25, hour: 12),
                (value: 150, year: 1447, month: 6, day: 30, hour: 12),
                (value: 200, year: 1447, month: 7, day: 2, hour: 12),
                (value: 200.5, year: 1447, month: 7, day: 2, hour: 16)
            ],
            in: calendar,
            span: .month,
            provider: .dailySum,
            treatsMissingAsZero: true
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

    // MARK: - Average Aggregation

    @Test func dailyAverageAggregation() {
        expect(
            [
                [(value: 15, year: 2024, month: 3, day: 15, hour: 0)],
                [(value: 16, year: 2024, month: 3, day: 20, hour: 0)]
            ],
            for: [
                (value: 10, year: 2024, month: 3, day: 15, hour: 12),
                (value: 20, year: 2024, month: 3, day: 15, hour: 12),
                (value: 30, year: 2024, month: 3, day: 20, hour: 12),
                (value: 2, year: 2024, month: 3, day: 20, hour: 12)
            ],
            in: Calendar.defaultCalendar(),
            span: .week,
            provider: .dailyAverage
        )
    }

    @Test func dailyAverageAggregation_withZeroFilling() {
        expect(
            [
                [
                    (value: 15, year: 2024, month: 3, day: 15, hour: 0),
                    (value: 0, year: 2024, month: 3, day: 16, hour: 0),
                    (value: 0, year: 2024, month: 3, day: 17, hour: 0)
                ],
                [
                    (value: 0, year: 2024, month: 3, day: 18, hour: 0),
                    (value: 0, year: 2024, month: 3, day: 19, hour: 0),
                    (value: 16, year: 2024, month: 3, day: 20, hour: 0)
                ]
            ],
            for: [
                (value: 10, year: 2024, month: 3, day: 15, hour: 12),
                (value: 20, year: 2024, month: 3, day: 15, hour: 12),
                (value: 30, year: 2024, month: 3, day: 20, hour: 12),
                (value: 2, year: 2024, month: 3, day: 20, hour: 12)
            ],
            in: Calendar.defaultCalendar(),
            span: .week,
            provider: .dailyAverage,
            treatsMissingAsZero: true
        )
    }

    @Test func monthlyAverageAggregation() {
        expect(
            [[
                (value: 6, year: 2024, month: 1, day: 1, hour: 0),
                (value: 16, year: 2024, month: 3, day: 1, hour: 0)
            ]],
            for: [
                (value: 10, year: 2024, month: 1, day: 15, hour: 12),
                (value: 2, year: 2024, month: 1, day: 16, hour: 12),
                (value: 30, year: 2024, month: 3, day: 15, hour: 12),
                (value: 2, year: 2024, month: 3, day: 28, hour: 12)
            ],
            in: Calendar.defaultCalendar(),
            span: .year,
            provider: .monthlyAverage
        )
    }

    @Test func monthlyAverageAggregation_withZeroFilling() {
        expect(
            [[
                (value: 6, year: 2024, month: 1, day: 1, hour: 0),
                (value: 0, year: 2024, month: 2, day: 1, hour: 0),
                (value: 16, year: 2024, month: 3, day: 1, hour: 0)
            ]],
            for: [
                (value: 10, year: 2024, month: 1, day: 15, hour: 12),
                (value: 2, year: 2024, month: 1, day: 16, hour: 12),
                (value: 30, year: 2024, month: 3, day: 15, hour: 12),
                (value: 2, year: 2024, month: 3, day: 28, hour: 12)
            ],
            in: Calendar.defaultCalendar(),
            span: .year,
            provider: .monthlyAverage,
            treatsMissingAsZero: true
        )
    }

    // MARK: - Page Aggregate

    @Test func extraData_week_dailySum() {
        let calendar = Calendar.defaultCalendar()

        // Dec 30, 2024 to Jan 5, 2025 should be in the same week
        let entries = [
            RawEntry(value: 1, timestamp: date(2024, 12, 30, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2025, 1, 2, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2025, 1, 5, calendar: calendar))
        ]

        let pages = pages(for: entries, .week, .dailySum, calendar)

        #expect(pages.count == 1)
        #expect(pages.first?.entries.count == 3)
        #expect(pages.first?.aggregator == .sum)
        #expect(pages.first?.aggregate == 6)
        #expect(pages.first?.span == .week)

        let pageStart = date(2024, 12, 30, hour: 0, calendar: calendar)
        let pageEnd = date(2025, 1, 5, hour: 0, calendar: calendar)
        #expect(pages.first?.dateRange == pageStart...pageEnd)

        let formatStyle = Date.FormatStyle(calendar: calendar)
        let first = pageStart.formatted(formatStyle.day().month(.abbreviated))
        let last = pageEnd.formatted(formatStyle.day().month(.abbreviated).year())
        let expectedTitle = "\(first) – \(last)"
        #expect(pages.first?.title == expectedTitle)
    }

    @Test func extraData_week_dailyAverage() {
        let calendar = Calendar.defaultCalendar()

        // Dec 30, 2024 to Jan 5, 2025 should be in the same week
        let entries = [
            RawEntry(value: 1, timestamp: date(2024, 12, 30, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2025, 1, 2, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2025, 1, 5, calendar: calendar))
        ]

        let pages = pages(for: entries, .week, .dailyAverage, calendar)

        #expect(pages.count == 1)
        #expect(pages.first?.entries.count == 3)
        #expect(pages.first?.aggregator == .average)
        #expect(pages.first?.aggregate == 2)
        #expect(pages.first?.span == .week)

        let pageStart = date(2024, 12, 30, hour: 0, calendar: calendar)
        let pageEnd = date(2025, 1, 5, hour: 0, calendar: calendar)
        #expect(pages.first?.dateRange == pageStart...pageEnd)

        let formatStyle = Date.FormatStyle(calendar: calendar)
        let first = pageStart.formatted(formatStyle.day().month(.abbreviated))
        let last = pageEnd.formatted(formatStyle.day().month(.abbreviated).year())
        let expectedTitle = "\(first) – \(last)"
        #expect(pages.first?.title == expectedTitle)
    }

    @Test func extraData_month_dailySum() {
        let calendar = Calendar.defaultCalendar()

        let entries = [
            RawEntry(value: 1, timestamp: date(2025, 1, 1, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2025, 1, 2, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2025, 1, 9, calendar: calendar))
        ]

        let pages = pages(for: entries, .month, .dailySum, calendar)

        #expect(pages.count == 1)
        #expect(pages.first?.entries.count == 3)
        #expect(pages.first?.aggregator == .sum)
        #expect(pages.first?.aggregate == 6)
        #expect(pages.first?.span == .month)

        let pageStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let pageEnd = date(2025, 1, 9, hour: 0, calendar: calendar)
        #expect(pages.first?.dateRange == pageStart...pageEnd)

        let formatStyle = Date.FormatStyle(calendar: calendar)
        let expectedTitle = pageStart.formatted(formatStyle.month(.wide).year())
        #expect(pages.first?.title == expectedTitle)
    }

    @Test func extraData_month_dailyAverage() {
        let calendar = Calendar.defaultCalendar()

        let entries = [
            RawEntry(value: 1, timestamp: date(2025, 1, 1, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2025, 1, 2, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2025, 1, 9, calendar: calendar))
        ]

        let pages = pages(for: entries, .month, .dailyAverage, calendar)

        #expect(pages.count == 1)
        #expect(pages.first?.entries.count == 3)
        #expect(pages.first?.aggregator == .average)
        #expect(pages.first?.aggregate == 2)
        #expect(pages.first?.span == .month)

        let pageStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let pageEnd = date(2025, 1, 9, hour: 0, calendar: calendar)
        #expect(pages.first?.dateRange == pageStart...pageEnd)

        let formatStyle = Date.FormatStyle(calendar: calendar)
        let expectedTitle = pageStart.formatted(formatStyle.month(.wide).year())
        #expect(pages.first?.title == expectedTitle)
    }

    @Test func extraData_year_monthlySum() {
        let calendar = Calendar.defaultCalendar()

        let entries = [
            RawEntry(value: 1, timestamp: date(2025, 1, 1, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2025, 5, 2, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2025, 11, 19, calendar: calendar))
        ]

        let pages = pages(for: entries, .year, .monthlySum, calendar)

        #expect(pages.count == 1)
        #expect(pages.first?.entries.count == 3)
        #expect(pages.first?.aggregator == .sum)
        #expect(pages.first?.aggregate == 6)
        #expect(pages.first?.span == .year)

        let pageStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let pageEnd = date(2025, 11, 1, hour: 0, calendar: calendar)
        #expect(pages.first?.dateRange == pageStart...pageEnd)

        let formatStyle = Date.FormatStyle(calendar: calendar)
        let expectedTitle = pageStart.formatted(formatStyle.year())
        #expect(pages.first?.title == expectedTitle)
    }

    @Test func extraData_year_monthlyAverage() {
        let calendar = Calendar.defaultCalendar()

        let entries = [
            RawEntry(value: 1, timestamp: date(2025, 1, 1, calendar: calendar)),
            RawEntry(value: 2, timestamp: date(2025, 5, 2, calendar: calendar)),
            RawEntry(value: 3, timestamp: date(2025, 11, 19, calendar: calendar))
        ]

        let pages = pages(for: entries, .year, .monthlyAverage, calendar)

        #expect(pages.count == 1)
        #expect(pages.first?.entries.count == 3)
        #expect(pages.first?.aggregator == .average)
        #expect(pages.first?.aggregate == 2)
        #expect(pages.first?.span == .year)

        let pageStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let pageEnd = date(2025, 11, 1, hour: 0, calendar: calendar)
        #expect(pages.first?.dateRange == pageStart...pageEnd)

        let formatStyle = Date.FormatStyle(calendar: calendar)
        let expectedTitle = pageStart.formatted(formatStyle.year())
        #expect(pages.first?.title == expectedTitle)
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
