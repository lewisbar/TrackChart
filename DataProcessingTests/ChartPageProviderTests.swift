//
//  ChartPageProviderTests.swift
//  DataProcessingTests
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

    // MARK: - Extra Data

    @Test func extraData_week_dailySum() {
        let calendar = Calendar.defaultCalendar()

        let pageStart = date(2024, 12, 30, hour: 0, calendar: calendar)
        let pageEnd = date(2025, 1, 5, hour: 0, calendar: calendar)

        let formatStyle = Date.FormatStyle(calendar: calendar)
        let titleStart = pageStart.formatted(formatStyle.day().month(.abbreviated))
        let titleEnd = pageEnd.formatted(formatStyle.day().month(.abbreviated).year())

        expect(
            (
                span: .week,
                title: "\(titleStart) – \(titleEnd)",
                range: pageStart...pageEnd,
                aggregator: .sum,
                aggregate: 6
            ),
            for: [
                (value: 1, year: 2024, month: 12, day: 30),
                (value: 2, year: 2025, month: 1, day: 2),
                (value: 3, year: 2025, month: 1, day: 5)
            ],
            provider: .dailySum,
            in: calendar
        )
    }

    @Test func extraData_week_dailyAverage() {
        let calendar = Calendar.defaultCalendar()

        let pageStart = date(2024, 12, 30, hour: 0, calendar: calendar)
        let pageEnd = date(2025, 1, 5, hour: 0, calendar: calendar)

        let formatStyle = Date.FormatStyle(calendar: calendar)
        let titleStart = pageStart.formatted(formatStyle.day().month(.abbreviated))
        let titleEnd = pageEnd.formatted(formatStyle.day().month(.abbreviated).year())

        expect(
            (
                span: .week,
                title: "\(titleStart) – \(titleEnd)",
                range: pageStart...pageEnd,
                aggregator: .average,
                aggregate: 2
            ),
            for: [
                (value: 1, year: 2024, month: 12, day: 30),
                (value: 2, year: 2025, month: 1, day: 2),
                (value: 3, year: 2025, month: 1, day: 5)
            ],
            provider: .dailyAverage,
            in: calendar
        )
    }

    @Test func extraData_month_dailySum() {
        let calendar = Calendar.defaultCalendar()
        let pageStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let pageEnd = date(2025, 1, 9, hour: 0, calendar: calendar)

        expect(
            (
                span: .month,
                title: pageStart.formatted(Date.FormatStyle(calendar: calendar).month(.wide).year()),
                range: pageStart...pageEnd,
                aggregator: .sum,
                aggregate: 6
            ),
            for: [
                (value: 1, year: 2025, month: 1, day: 1),
                (value: 2, year: 2025, month: 1, day: 2),
                (value: 3, year: 2025, month: 1, day: 9)
            ],
            provider: .dailySum,
            in: calendar
        )
    }

    @Test func extraData_month_dailyAverage() {
        let calendar = Calendar.defaultCalendar()
        let pageStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let pageEnd = date(2025, 1, 9, hour: 0, calendar: calendar)

        expect(
            (
                span: .month,
                title: pageStart.formatted(Date.FormatStyle(calendar: calendar).month(.wide).year()),
                range: pageStart...pageEnd,
                aggregator: .average,
                aggregate: 2
            ),
            for: [
                (value: 1, year: 2025, month: 1, day: 1),
                (value: 2, year: 2025, month: 1, day: 2),
                (value: 3, year: 2025, month: 1, day: 9)
            ],
            provider: .dailyAverage,
            in: calendar
        )
    }

    @Test func extraData_year_monthlySum() {
        let calendar = Calendar.defaultCalendar()
        let pageStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let pageEnd = date(2025, 11, 1, hour: 0, calendar: calendar)

        expect(
            (
                span: .year,
                title: pageStart.formatted(Date.FormatStyle(calendar: calendar).year()),
                range: pageStart...pageEnd,
                aggregator: .sum,
                aggregate: 6
            ),
            for: [
                (value: 1, year: 2025, month: 1, day: 1),
                (value: 2, year: 2025, month: 5, day: 2),
                (value: 3, year: 2025, month: 11, day: 19)
            ],
            provider: .monthlySum,
            in: calendar
        )
    }

    @Test func extraData_year_monthlyAverage() {
        let calendar = Calendar.defaultCalendar()
        let pageStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let pageEnd = date(2025, 11, 1, hour: 0, calendar: calendar)

        expect(
            (
                span: .year,
                title: pageStart.formatted(Date.FormatStyle(calendar: calendar).year()),
                range: pageStart...pageEnd,
                aggregator: .average,
                aggregate: 2
            ),
            for: [
                (value: 1, year: 2025, month: 1, day: 1),
                (value: 2, year: 2025, month: 5, day: 2),
                (value: 3, year: 2025, month: 11, day: 9)
            ],
            provider: .monthlyAverage,
            in: calendar
        )
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
            Entry(value: $0.value, timestamp: date($0.year, $0.month, $0.day, hour: $0.hour, calendar: calendar))
        }

        let pages = pages(for: inputEntries, span, provider, calendar, treatsMissingAsZero: treatsMissingAsZero)

        let expectedValues = expectedData.map { $0.map(\.value) }
        let expectedDates = expectedData.map { $0.map { date($0.year, $0.month, $0.day, hour: $0.hour, calendar: calendar) } }
        #expect(pages.map { $0.entries.map(\.value) } == expectedValues, sourceLocation: sourceLocation)
        #expect(pages.map { $0.entries.map(\.timestamp) } == expectedDates, sourceLocation: sourceLocation)
    }

    private func expect(
        _ expected: (
            span: TimeSpan,
            title: String,
            range: ClosedRange<Date>,
            aggregator: Aggregator,
            aggregate: Double
        ),
        for inputData: [(value: Double, year: Int, month: Int, day: Int)],
        provider: Provider,
        in calendar: Calendar = Calendar.defaultCalendar(),
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let inputEntries = inputData.map {
            Entry(value: $0.value, timestamp: date($0.year, $0.month, $0.day, calendar: calendar))
        }

        let pages = pages(for: inputEntries, expected.span, provider, calendar)

        #expect(pages.first?.span == expected.span, sourceLocation: sourceLocation)
        #expect(pages.first?.title == expected.title, sourceLocation: sourceLocation)
        #expect(pages.first?.dateRange == expected.range, sourceLocation: sourceLocation)
        #expect(pages.first?.aggregator == expected.aggregator, sourceLocation: sourceLocation)
        #expect(pages.first?.aggregate == expected.aggregate, sourceLocation: sourceLocation)
    }

    private enum Provider {
        case dailySum
        case dailyAverage
        case monthlySum
        case monthlyAverage
    }

    private func pages(for entries: [Entry], _ span: TimeSpan, _ dataProvider: Provider, _ calendar: Calendar, treatsMissingAsZero: Bool = false) -> [ChartPage] {
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
