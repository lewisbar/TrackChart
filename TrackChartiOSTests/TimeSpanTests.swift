//
//  TimeSpanTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 06.11.25.
//

import Testing
import TrackChartiOS

struct TimeSpanTests {
    @Test func title() {
        #expect(TimeSpan.week.title == "Week")
        #expect(TimeSpan.month.title == "Month")
        #expect(TimeSpan.sixMonths.title == "6 Months")
        #expect(TimeSpan.oneYear.title == "Year")
    }

    @Test func calendarComponent() {
        #expect(TimeSpan.week.calendarComponent == .weekOfYear)
        #expect(TimeSpan.month.calendarComponent == .month)
        #expect(TimeSpan.sixMonths.calendarComponent == .month)
        #expect(TimeSpan.oneYear.calendarComponent == .year)
    }

    @Test func componentCount() {
        #expect(TimeSpan.week.componentCount == 1)
        #expect(TimeSpan.month.componentCount == 1)
        #expect(TimeSpan.sixMonths.componentCount == 6)
        #expect(TimeSpan.oneYear.componentCount == 1)
    }

    @Test func availableDataProviders() {
        #expect(TimeSpan.week.availableDataProviders == [.dailySum, .dailyAverage])
        #expect(TimeSpan.month.availableDataProviders == [.dailySum, .dailyAverage])
        #expect(TimeSpan.sixMonths.availableDataProviders == [.weeklySum, .weeklyAverage])
        #expect(TimeSpan.oneYear.availableDataProviders == [.monthlySum, .monthlyAverage])
    }
}
