//
//  ChartDataProviderTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 27.10.25.
//

import Testing
import Foundation
@testable import TrackChartiOS

struct ChartDataProviderTests {
    @Test func raw() {
        let entry1 = ChartEntry(value: 1.1, timestamp: .now.advanced(by: -200))
        let entry2 = ChartEntry(value: -2.2, timestamp: .now.advanced(by: -100))
        let originalEntries = [entry1, entry2]

        let sut = ChartDataProvider.raw
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.map(\.value) == originalEntries.map(\.value))
        #expect(processedEntries.map(\.timestamp) == originalEntries.map(\.timestamp))
    }

    @Test func dailySum() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 100_000))
        let entry2b = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 100_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let sut = ChartDataProvider.dailySum(calendar: Calendar(identifier: .gregorian))
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 4])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.startOfDay(for: $0) },
            "Expected timestamps to match earliest in each day"
        )
    }

    @Test func dailyAverage() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 100_000))
        let entry2b = ChartEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 100_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let sut = ChartDataProvider.dailyAverage(calendar: Calendar(identifier: .gregorian))
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.startOfDay(for: $0) },
            "Expected timestamps to match earliest in each day"
        )
    }

    @Test func weeklySum() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 800_000))
        let entry2b = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 800_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2  // Monday
        let sut = ChartDataProvider.weeklySum(calendar: calendar)

        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 4])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.dateInterval(of: .weekOfYear, for: $0)?.start },
            "Expected timestamps to match earliest in each week"
        )
    }

    @Test func weeklyAverage() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 800_000))
        let entry2b = ChartEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 800_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2  // Monday
        let sut = ChartDataProvider.weeklyAverage(calendar: calendar)
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.dateInterval(of: .weekOfYear, for: $0)?.start },
            "Expected timestamps to match earliest in each week"
        )
    }
    
    @Test func monthlySum() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 4_000_000))
        let entry2b = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 4_000_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let sut = ChartDataProvider.monthlySum(calendar: Calendar(identifier: .gregorian))
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 4])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.dateInterval(of: .month, for: $0)?.start },
            "Expected timestamps to match earliest in each month"
        )
    }

    @Test func monthlyAverage() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 4_000_000))
        let entry2b = ChartEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 4_000_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let sut = ChartDataProvider.monthlyAverage(calendar: Calendar(identifier: .gregorian))
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.dateInterval(of: .month, for: $0)?.start },
            "Expected timestamps to match earliest in each month"
        )
    }
}
