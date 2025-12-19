//
//  TimeSpanTests.swift
//  DataProcessingTests
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
        #expect(TimeSpan.year.calendarComponent == .year)
    }

    @Test func componentCount() {
        #expect(TimeSpan.week.componentCount == 1)
        #expect(TimeSpan.month.componentCount == 1)
        #expect(TimeSpan.year.componentCount == 1)
    }

    @Test func availableDataProviders() {
        #expect(TimeSpan.week.availableDataProviders(treatsMissingAsZero: false) == [.dailySum(treatsMissingAsZero: false), .dailyAverage(treatsMissingAsZero: false)])
        #expect(TimeSpan.week.availableDataProviders(treatsMissingAsZero: true) == [.dailySum(treatsMissingAsZero: true), .dailyAverage(treatsMissingAsZero: true)])
        #expect(TimeSpan.month.availableDataProviders(treatsMissingAsZero: false) == [.dailySum(treatsMissingAsZero: false), .dailyAverage(treatsMissingAsZero: false)])
        #expect(TimeSpan.month.availableDataProviders(treatsMissingAsZero: true) == [.dailySum(treatsMissingAsZero: true), .dailyAverage(treatsMissingAsZero: true)])
        #expect(TimeSpan.year.availableDataProviders(treatsMissingAsZero: false) == [.monthlySum(treatsMissingAsZero: false), .monthlyAverage(treatsMissingAsZero: false)])
        #expect(TimeSpan.year.availableDataProviders(treatsMissingAsZero: true) == [.monthlySum(treatsMissingAsZero: true), .monthlyAverage(treatsMissingAsZero: true)])
    }
}
