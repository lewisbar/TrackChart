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

    @Test func weekRelativeToNow() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 7, 10, hour: 12, calendar: calendar) // Wednesday

        // Last week should be Thu July 4 to Wed July 10
        // Previous week should be Thu June 27 to Wed July 3

        expect(
            [
                [
                    (value: 1, year: 2024, month: 7, day: 3, hour: 0)
                ],
                [
                    (value: 2, year: 2024, month: 7, day: 4, hour: 0),
                    (value: 3, year: 2024, month: 7, day: 10, hour: 0)
                ]
            ],
            for: [
                (value: 1, year: 2024, month: 7, day: 3, hour: 12),
                (value: 2, year: 2024, month: 7, day: 4, hour: 12),
                (value: 3, year: 2024, month: 7, day: 10, hour: 12)
            ],
            span: .week,
            provider: .dailySum,
            now: now
        )
    }

    @Test func monthRelativeToNow() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 7, 10, hour: 12, calendar: calendar)

        // Last month should be June 11 to July 10
        // Previous month should be May 11 to June 10

        expect(
            [
                [
                    (value: 1, year: 2024, month: 6, day: 10, hour: 0)
                ],
                [
                    (value: 2, year: 2024, month: 6, day: 11, hour: 0),
                    (value: 3, year: 2024, month: 7, day: 10, hour: 0)
                ]
            ],
            for: [
                (value: 1, year: 2024, month: 6, day: 10, hour: 12),
                (value: 2, year: 2024, month: 6, day: 11, hour: 12),
                (value: 3, year: 2024, month: 7, day: 10, hour: 12)
            ],
            span: .month,
            provider: .dailySum,
            now: now
        )
    }

    @Test func yearRelativeToNow() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 7, 10, hour: 12, calendar: calendar)

        // Last year should be July 11, 2023 to July 10, 2024
        // Previous year should be July 11, 2022 to July 10, 2023

        expect(
            [
                [
                    (value: 1, year: 2023, month: 7, day: 1, hour: 0)
                ],
                [
                    (value: 2, year: 2023, month: 8, day: 1, hour: 0),
                    (value: 3, year: 2024, month: 7, day: 1, hour: 0)
                ]
            ],
            for: [
                (value: 1, year: 2023, month: 7, day: 10, hour: 12),
                (value: 2, year: 2023, month: 8, day: 11, hour: 12),
                (value: 3, year: 2024, month: 7, day: 10, hour: 12)
            ],
            span: .year,
            provider: .monthlySum,
            now: now
        )
    }

    // MARK: - Gregorian Calendar

    @Test func oneWeek_returnsOneWeekPage() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 7, 14, hour: 12, calendar: calendar)
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
            provider: .dailySum,
            now: now
        )
    }

    @Test func oneWeek_withZeroFilling() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 7, 14, hour: 12, calendar: calendar)
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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func oneWeek_acrossMonthBoundary_returnsOneWeekPage() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 8, 4, hour: 12, calendar: calendar)
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
            provider: .dailySum,
            now: now
        )
    }

    @Test func oneWeek_acrossMonthBoundary_withZeroFilling() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 8, 4, hour: 12, calendar: calendar)
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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func oneWeek_acrossYearBoundary_returnsOneWeekPage() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2025, 1, 5, hour: 12, calendar: calendar)
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
            provider: .dailySum,
            now: now
        )
    }

    @Test func oneWeek_acrossYearBoundary_withZeroFilling() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2025, 1, 5, hour: 12, calendar: calendar)
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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func twoWeeks_returnsTwoWeekPages() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 7, 15, hour: 12, calendar: calendar)
        // lastPageEnd = July 16
        // Page 1: July 9 - July 16. Contains 10th and 15th
        // Page 2: July 2 - July 9. Contains 8th
        expect(
            [
                [
                    (value: 1, year: 2024, month: 7, day: 8, hour: 0)
                ],
                [
                    (value: 2, year: 2024, month: 7, day: 10, hour: 0),
                    (value: 3, year: 2024, month: 7, day: 15, hour: 0)
                ]
            ],
            for: [
                (value: 1, year: 2024, month: 7, day: 8, hour: 12),
                (value: 2, year: 2024, month: 7, day: 10, hour: 12),
                (value: 3, year: 2024, month: 7, day: 15, hour: 12)
            ],
            span: .week,
            provider: .dailySum,
            now: now
        )
    }

    @Test func twoWeeks_withZeroFilling() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 7, 16, hour: 12, calendar: calendar)
        // lastPageEnd = July 17
        // Page 1: July 10 - July 17. Contains 10th and 16th
        // Page 2: July 3 - July 10. Contains 8th
        expect(
            [
                [
                    (value: 1, year: 2024, month: 7, day: 8, hour: 0),
                    (value: 0, year: 2024, month: 7, day: 9, hour: 0)
                ],
                [
                    (value: 2, year: 2024, month: 7, day: 10, hour: 0),
                    (value: 0, year: 2024, month: 7, day: 11, hour: 0),
                    (value: 0, year: 2024, month: 7, day: 12, hour: 0),
                    (value: 0, year: 2024, month: 7, day: 13, hour: 0),
                    (value: 0, year: 2024, month: 7, day: 14, hour: 0),
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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func oneMonth() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 10, 31, hour: 12, calendar: calendar)
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
            provider: .dailySum,
            now: now
        )
    }

    @Test func oneMonth_withZeroFilling() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 10, 31, hour: 12, calendar: calendar)
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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func twoMonths() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 11, 1, hour: 12, calendar: calendar)
        // lastPageEnd = Nov 2
        // Page 1: Oct 2 - Nov 2. Contains Oct 31 and Nov 1
        expect(
            [
                [(value: 2.5, year: 2024, month: 10, day: 31, hour: 0),
                 (value: 2, year: 2024, month: 11, day: 1, hour: 0)]
            ],
            for: [
                (value: 1, year: 2024, month: 10, day: 31, hour: 12),
                (value: 1.5, year: 2024, month: 10, day: 31, hour: 12),
                (value: 2, year: 2024, month: 11, day: 1, hour: 12)
            ],
            span: .month,
            provider: .dailySum,
            now: now
        )
    }

    @Test func twoMonths_withZeroFilling() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 11, 1, hour: 12, calendar: calendar)
        // lastPageEnd = Nov 2
        // Page 1: Oct 2 - Nov 2. Contains Oct 29 and Nov 1
        expect(
            [
                [
                    (value: 2.5, year: 2024, month: 10, day: 29, hour: 0),
                    (value: 0, year: 2024, month: 10, day: 30, hour: 0),
                    (value: 0, year: 2024, month: 10, day: 31, hour: 0),
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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func oneYear() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 12, 31, hour: 12, calendar: calendar)
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
            provider: .monthlySum,
            now: now
        )
    }

    @Test func oneYear_withZeroFilling() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 12, 31, hour: 12, calendar: calendar)
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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func twoYears() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2025, 1, 1, hour: 12, calendar: calendar)
        // lastPageEnd = Jan 2, 2025
        // Page 1: Jan 2, 2024 - Jan 2, 2025. Contains Dec 10, 2024 and Jan 1, 2025
        expect(
            [
                [(value: 2.5, year: 2024, month: 12, day: 1, hour: 0),
                 (value: 2, year: 2025, month: 1, day: 1, hour: 0)]
            ],
            for: [
                (value: 1, year: 2024, month: 12, day: 10, hour: 12),
                (value: 1.5, year: 2024, month: 12, day: 31, hour: 12),
                (value: 2, year: 2025, month: 1, day: 1, hour: 12)
            ],
            span: .year,
            provider: .monthlySum,
            now: now
        )
    }

    @Test func twoYears_withZeroFilling() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2025, 3, 1, hour: 12, calendar: calendar)
        // lastPageEnd = Mar 2, 2025
        // Page 1: Mar 2, 2024 - Mar 2, 2025. Contains Dec 10, 2024 and Mar 1, 2025
        expect(
            [
                [
                    (value: 2.5, year: 2024, month: 12, day: 1, hour: 0),
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
            treatsMissingAsZero: true,
            now: now
        )
    }

    // MARK: - Hebrew Calendar

    @Test func hebrewSameWeek() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(5785, 2, 8, hour: 12, calendar: calendar)

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
            provider: .dailySum,
            now: now
        )
    }

    @Test func hebrewSameWeek_withZeroFilling() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(5785, 2, 8, hour: 12, calendar: calendar)

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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func hebrewTwoWeeks() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(5785, 2, 9, hour: 12, calendar: calendar)
        // lastPageEnd = 5785-2-10
        // Page 1: 5785-2-3 to 5785-2-10. Contains 2-5 and 2-9
        // Page 2: 5785-1-26 to 5785-2-3. Contains 2-2
        expect(
            [
                [
                    (value: 2.5, year: 5785, month: 2, day: 2, hour: 0)
                ],
                [
                    (value: 2, year: 5785, month: 2, day: 5, hour: 0),
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
            now: now
        )
    }

    @Test func hebrewTwoWeeks_withZeroFilling() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(5785, 2, 9, hour: 12, calendar: calendar)
        // lastPageEnd = 5785-2-10
        // Page 1: 5785-2-3 to 5785-2-10. Contains 2-5 and 2-9
        // Page 2: 5785-1-26 to 5785-2-3. Contains 2-2
        expect(
            [
                [
                    (value: 2.5, year: 5785, month: 2, day: 2, hour: 0)
                ],
                [
                    (value: 0, year: 5785, month: 2, day: 3, hour: 0),
                    (value: 0, year: 5785, month: 2, day: 4, hour: 0),
                    (value: 2, year: 5785, month: 2, day: 5, hour: 0),
                    (value: 0, year: 5785, month: 2, day: 6, hour: 0),
                    (value: 0, year: 5785, month: 2, day: 7, hour: 0),
                    (value: 0, year: 5785, month: 2, day: 8, hour: 0),
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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func hebrewSameMonth() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(5785, 11, 29, hour: 12, calendar: calendar)

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
            provider: .dailySum,
            now: now
        )
    }

    @Test func hebrewSameMonth_withZeroFilling() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(5785, 11, 5, hour: 12, calendar: calendar)

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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func hebrewTwoMonths() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(5785, 12, 1, hour: 12, calendar: calendar)
        // lastPageEnd = 5785-12-2
        // Page 1: 5785-11-2 to 5785-12-2. Contains 11-1 is outside!
        // Wait, 5785-11-1 is exactly 1 month before 5785-12-1.
        // If lastPageEnd is 12-2, then currentStart is 11-2.
        // So 11-1 is in previous page.
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
            provider: .dailySum,
            now: now
        )
    }

    @Test func hebrewTwoMonths_withZeroFilling() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(5785, 12, 1, hour: 12, calendar: calendar)
        // lastPageEnd = 5785-12-2
        // Page 1: 5785-11-2 to 5785-12-2. Contains 11-25 and 12-1
        expect(
            [
                [
                    (value: 2.5, year: 5785, month: 11, day: 25, hour: 0),
                    (value: 0, year: 5785, month: 11, day: 26, hour: 0),
                    (value: 0, year: 5785, month: 11, day: 27, hour: 0),
                    (value: 0, year: 5785, month: 11, day: 28, hour: 0),
                    (value: 0, year: 5785, month: 11, day: 29, hour: 0),
                    (value: 2, year: 5785, month: 12, day: 1, hour: 0)
                ]
            ],
            for: [
                (value: 1, year: 5785, month: 11, day: 25, hour: 12),
                (value: 1.5, year: 5785, month: 11, day: 25, hour: 13),
                (value: 2, year: 5785, month: 12, day: 1, hour: 12)
            ],
            in: calendar,
            span: .month,
            provider: .dailySum,
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func hebrewSameYear() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(5785, 12, 15, hour: 12, calendar: calendar)
        // lastPageEnd = 5785-12-16
        // Page 1: 5784-12-16 to 5785-12-16. Contains both 5785-3 and 5785-12
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
            provider: .monthlySum,
            now: now
        )
    }

    @Test func hebrewSameYear_withZeroFilling() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(5785, 6, 15, hour: 12, calendar: calendar)

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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func hebrewTwoYears() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(5786, 3, 15, hour: 12, calendar: calendar)
        // lastPageEnd = 5786-3-16
        // Page 1: 5785-3-16 to 5786-3-16. Contains 5785-12 and 5786-3
        // Page 2: 5784-3-16 to 5785-3-16. Contains 5785-3
        expect(
            [
                [
                    (value: 20.5, year: 5785, month: 3, day: 1, hour: 0)
                ],
                [
                    (value: 11, year: 5785, month: 12, day: 1, hour: 0),
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
            provider: .monthlySum,
            now: now
        )
    }

    @Test func hebrewTwoYears_withZeroFilling() {
        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(5786, 3, 15, hour: 12, calendar: calendar)
        // lastPageEnd = 5786-3-16
        // Page 1: 5785-3-16 to 5786-3-16. Contains 5785-7, 5785-9 and 5786-3
        // Wait, 5785-7 is after 5785-3-16. (Hebrew months: 1=Tishrei, 7=Nisan)
        // So 5785-7 is in Page 1.
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
            treatsMissingAsZero: true,
            now: now
        )
    }

    // MARK: - Islamic Calendar Tests

    @Test func islamicSameWeek() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(1447, 6, 23, hour: 12, calendar: calendar)

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
            provider: .dailySum,
            now: now
        )
    }

    @Test func islamicSameWeek_withZeroFilling() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(1447, 6, 23, hour: 12, calendar: calendar)

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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func islamicTwoWeeks() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(1447, 6, 24, hour: 12, calendar: calendar)
        // lastPageEnd = 1447-6-25
        // Page 1: 1447-6-18 to 1447-6-25. Contains 6-23 and 6-24
        // Page 2: 1447-6-11 to 1447-6-18. Contains 6-17
        expect(
            [
                [
                    (value: 5, year: 1447, month: 6, day: 17, hour: 0)
                ],
                [
                    (value: 12.5, year: 1447, month: 6, day: 23, hour: 0),
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
            now: now
        )
    }

    @Test func islamicTwoWeeks_withZeroFilling() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(1447, 6, 24, hour: 12, calendar: calendar)
        // lastPageEnd = 1447-6-25
        // Page 1: 1447-6-18 to 1447-6-25. Contains 6-23 and 6-24
        // Page 2: 1447-6-11 to 1447-6-18. Contains 6-17
        expect(
            [
                [
                    (value: 5, year: 1447, month: 6, day: 17, hour: 0)
                ],
                [
                    (value: 0, year: 1447, month: 6, day: 18, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 19, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 20, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 21, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 22, hour: 0),
                    (value: 12.5, year: 1447, month: 6, day: 23, hour: 0),
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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func islamicSameMonth() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(1447, 6, 30, hour: 12, calendar: calendar)

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
            provider: .dailySum,
            now: now
        )
    }

    @Test func islamicSameMonth_withZeroFilling() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(1447, 6, 17, hour: 12, calendar: calendar)

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
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func islamicTwoMonths() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(1447, 7, 1, hour: 12, calendar: calendar)
        // lastPageEnd = 1447-7-2
        // Page 1: 1447-6-2 to 1447-7-2. Contains 6-30 and 7-1
        // Page 2: 1447-5-2 to 1447-6-2. Contains 6-1
        expect(
            [
                [
                    (value: 100, year: 1447, month: 6, day: 1, hour: 0)
                ],
                [
                    (value: 150, year: 1447, month: 6, day: 30, hour: 0),
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
            provider: .dailySum,
            now: now
        )
    }

    @Test func islamicTwoMonths_withZeroFilling() {
        var calendar = Calendar(identifier: .islamic)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = date(1447, 7, 2, hour: 12, calendar: calendar)
        // lastPageEnd = 1447-7-3
        // Page 1: 1447-6-3 to 1447-7-3. Contains 6-25, 6-30, 7-2
        // Page 2: 1447-5-3 to 1447-6-3.
        expect(
            [
                [
                    (value: 100, year: 1447, month: 6, day: 25, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 26, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 27, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 28, hour: 0),
                    (value: 0, year: 1447, month: 6, day: 29, hour: 0),
                    (value: 150, year: 1447, month: 6, day: 30, hour: 0),
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
            treatsMissingAsZero: true,
            now: now
        )
    }

    // MARK: - Edge Cases Across Calendars

    @Test func differentFirstWeekday() {
        var sundayCalendar = Calendar(identifier: .gregorian)
        sundayCalendar.firstWeekday = 1  // Sunday
        sundayCalendar.timeZone = TimeZone(secondsFromGMT: 0)!

        var mondayCalendar = Calendar(identifier: .gregorian)
        mondayCalendar.firstWeekday = 2  // Monday
        mondayCalendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let inputData: [(value: Double, year: Int, month: Int, day: Int, hour: Int)] = [
            (value: 10, year: 2024, month: 11, day: 10, hour: 12),
            (value: 11, year: 2024, month: 11, day: 11, hour: 12)
        ]
        let now = date(2024, 11, 11, hour: 12, calendar: sundayCalendar)

        // Relative logic doesn't care about firstWeekday for alignment
        expect(
            [[
                (value: 10, year: 2024, month: 11, day: 10, hour: 0),
                (value: 11, year: 2024, month: 11, day: 11, hour: 0)
            ]],
            for: inputData,
            in: sundayCalendar,
            span: .week,
            provider: .dailySum,
            now: now
        )

        expect(
            [[
                (value: 10, year: 2024, month: 11, day: 10, hour: 0),
                (value: 11, year: 2024, month: 11, day: 11, hour: 0)
            ]],
            for: inputData,
            in: mondayCalendar,
            span: .week,
            provider: .dailySum,
            now: now
        )
    }

    @Test func leapYearHandling() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 3, 1, hour: 12, calendar: calendar)
        // lastPageEnd = Mar 2
        // Page 1: Feb 2 - Mar 2. Contains all
        expect(
            [
                [
                    (value: 2.5, year: 2024, month: 2, day: 28, hour: 0),
                    (value: 2, year: 2024, month: 2, day: 29, hour: 0),
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
            provider: .dailySum,
            now: now
        )
    }

    // MARK: - Average Aggregation

    @Test func dailyAverageAggregation() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 3, 20, hour: 12, calendar: calendar)
        // lastPageEnd = Mar 21
        // Page 1: Mar 14 - Mar 21. Contains both
        expect(
            [
                [(value: 15, year: 2024, month: 3, day: 15, hour: 0),
                 (value: 16, year: 2024, month: 3, day: 20, hour: 0)]
            ],
            for: [
                (value: 10, year: 2024, month: 3, day: 15, hour: 12),
                (value: 20, year: 2024, month: 3, day: 15, hour: 12),
                (value: 30, year: 2024, month: 3, day: 20, hour: 12),
                (value: 2, year: 2024, month: 3, day: 20, hour: 12)
            ],
            in: calendar,
            span: .week,
            provider: .dailyAverage,
            now: now
        )
    }

    @Test func dailyAverageAggregation_withZeroFilling() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 3, 20, hour: 12, calendar: calendar)
        // lastPageEnd = Mar 21
        // Page 1: Mar 14 - Mar 21
        expect(
            [
                [
                    (value: 15, year: 2024, month: 3, day: 15, hour: 0),
                    (value: 0, year: 2024, month: 3, day: 16, hour: 0),
                    (value: 0, year: 2024, month: 3, day: 17, hour: 0),
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
            in: calendar,
            span: .week,
            provider: .dailyAverage,
            treatsMissingAsZero: true,
            now: now
        )
    }

    @Test func monthlyAverageAggregation() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 3, 28, hour: 12, calendar: calendar)
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
            in: calendar,
            span: .year,
            provider: .monthlyAverage,
            now: now
        )
    }

    @Test func monthlyAverageAggregation_withZeroFilling() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2024, 3, 28, hour: 12, calendar: calendar)
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
            in: calendar,
            span: .year,
            provider: .monthlyAverage,
            treatsMissingAsZero: true,
            now: now
        )
    }

    // MARK: - Extra Data

    @Test func extraData_week_dailySum() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2025, 1, 5, hour: 12, calendar: calendar)

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
            in: calendar,
            now: now
        )
    }

    @Test func extraData_week_dailyAverage() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2025, 1, 5, hour: 12, calendar: calendar)

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
            in: calendar,
            now: now
        )
    }

    @Test func extraData_month_dailySum() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2025, 1, 31, hour: 12, calendar: calendar)
        // lastPageEnd = Feb 1
        // currentStart = Jan 1
        let pageStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let entryStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let entryEnd = date(2025, 1, 9, hour: 0, calendar: calendar)

        expect(
            (
                span: .month,
                title: pageStart.formatted(Date.FormatStyle(calendar: calendar).month(.wide).year()),
                range: entryStart...entryEnd,
                aggregator: .sum,
                aggregate: 6
            ),
            for: [
                (value: 1, year: 2025, month: 1, day: 1),
                (value: 2, year: 2025, month: 1, day: 2),
                (value: 3, year: 2025, month: 1, day: 9)
            ],
            provider: .dailySum,
            in: calendar,
            now: now
        )
    }

    @Test func extraData_month_dailyAverage() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2025, 1, 31, hour: 12, calendar: calendar)
        // lastPageEnd = Feb 1
        // currentStart = Jan 1
        let pageStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let entryStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let entryEnd = date(2025, 1, 9, hour: 0, calendar: calendar)

        expect(
            (
                span: .month,
                title: pageStart.formatted(Date.FormatStyle(calendar: calendar).month(.wide).year()),
                range: entryStart...entryEnd,
                aggregator: .average,
                aggregate: 2
            ),
            for: [
                (value: 1, year: 2025, month: 1, day: 1),
                (value: 2, year: 2025, month: 1, day: 2),
                (value: 3, year: 2025, month: 1, day: 9)
            ],
            provider: .dailyAverage,
            in: calendar,
            now: now
        )
    }

    @Test func extraData_year_monthlySum() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2025, 12, 31, hour: 12, calendar: calendar)
        // lastPageEnd = Jan 1, 2026
        // currentStart = Jan 1, 2025
        let pageStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let entryStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let entryEnd = date(2025, 11, 1, hour: 0, calendar: calendar)

        expect(
            (
                span: .year,
                title: pageStart.formatted(Date.FormatStyle(calendar: calendar).year()),
                range: entryStart...entryEnd,
                aggregator: .sum,
                aggregate: 6
            ),
            for: [
                (value: 1, year: 2025, month: 1, day: 1),
                (value: 2, year: 2025, month: 5, day: 2),
                (value: 3, year: 2025, month: 11, day: 19)
            ],
            provider: .monthlySum,
            in: calendar,
            now: now
        )
    }

    @Test func extraData_year_monthlyAverage() {
        let calendar = Calendar.defaultCalendar()
        let now = date(2025, 12, 31, hour: 12, calendar: calendar)
        // lastPageEnd = Jan 1, 2026
        // currentStart = Jan 1, 2025
        let pageStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let entryStart = date(2025, 1, 1, hour: 0, calendar: calendar)
        let entryEnd = date(2025, 11, 1, hour: 0, calendar: calendar)

        expect(
            (
                span: .year,
                title: pageStart.formatted(Date.FormatStyle(calendar: calendar).year()),
                range: entryStart...entryEnd,
                aggregator: .average,
                aggregate: 2
            ),
            for: [
                (value: 1, year: 2025, month: 1, day: 1),
                (value: 2, year: 2025, month: 5, day: 2),
                (value: 3, year: 2025, month: 11, day: 9)
            ],
            provider: .monthlyAverage,
            in: calendar,
            now: now
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
        now: Date? = nil,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let inputEntries = inputData.map {
            Entry(value: $0.value, timestamp: date($0.year, $0.month, $0.day, hour: $0.hour, calendar: calendar))
        }

        let pages = pages(for: inputEntries, span, provider, calendar, treatsMissingAsZero: treatsMissingAsZero, now: now)

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
        now: Date? = nil,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let inputEntries = inputData.map {
            Entry(value: $0.value, timestamp: date($0.year, $0.month, $0.day, calendar: calendar))
        }

        let pages = pages(for: inputEntries, expected.span, provider, calendar, now: now)

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

    private func pages(for entries: [Entry], _ span: TimeSpan, _ dataProvider: Provider, _ calendar: Calendar, treatsMissingAsZero: Bool = false, now: Date? = nil) -> [ChartPage] {
        let provider: ChartDataProvider = switch dataProvider {
        case .dailySum: .dailySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        case .dailyAverage: .dailyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        case .monthlySum: .monthlySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        case .monthlyAverage: .monthlyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)
        }

        let effectiveNow = now ?? entries.map(\.timestamp).max() ?? .now
        return ChartPageProvider.pages(for: entries, span: span, dataProvider: provider, calendar: calendar, now: effectiveNow)
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
