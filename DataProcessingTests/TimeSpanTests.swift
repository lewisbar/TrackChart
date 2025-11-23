//
//  TimeSpanTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 06.11.25.
//

import Foundation
import Testing
import DataProcessing

struct TimeSpanTests {
    @Test func calendarComponent() {
        #expect(TimeSpan.week.calendarComponent == .weekOfYear)
        #expect(TimeSpan.month.calendarComponent == .month)
        #expect(TimeSpan.oneYear.calendarComponent == .year)
    }

    @Test func componentCount() {
        #expect(TimeSpan.week.componentCount == 1)
        #expect(TimeSpan.month.componentCount == 1)
        #expect(TimeSpan.oneYear.componentCount == 1)
    }

    @Test func availableDataProviders() {
        #expect(TimeSpan.week.availableDataProviders() == [.dailySum(), .dailyAverage()])
        #expect(TimeSpan.month.availableDataProviders() == [.dailySum(), .dailyAverage()])
        #expect(TimeSpan.oneYear.availableDataProviders() == [.monthlySum(), .monthlyAverage()])
    }
}
