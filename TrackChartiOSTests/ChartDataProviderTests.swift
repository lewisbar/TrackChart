//
//  ChartDataProviderTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 27.10.25.
//

import Testing
@testable import TrackChartiOS
import Presentation

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

    @Test func minutelySum() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 80))
        let entry2b = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 81))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let sut = ChartDataProvider.minutelySum
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 4])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.dateInterval(of: .minute, for: $0)?.start },
            "Expected timestamps to match earliest in each minute"
        )
    }

    @Test func hourlySum() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 4000))
        let entry2b = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 4001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let sut = ChartDataProvider.hourlySum
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 4])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.dateInterval(of: .hour, for: $0)?.start },
            "Expected timestamps to match earliest in each hour"
        )
    }

    @Test func dailySum() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 100_000))
        let entry2b = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 100_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let sut = ChartDataProvider.dailySum
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 4])
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

        let sut = ChartDataProvider.weeklySum
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 4])
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

        let sut = ChartDataProvider.monthlySum
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 4])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.dateInterval(of: .month, for: $0)?.start },
            "Expected timestamps to match earliest in each month"
        )
    }

    @Test func dailyAverage() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 100_000))
        let entry2b = ChartEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 100_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let sut = ChartDataProvider.dailyAverage
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.startOfDay(for: $0) },
            "Expected timestamps to match earliest in each day"
        )
    }

    @Test func weeklyAverage() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 800_000))
        let entry2b = ChartEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 800_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let sut = ChartDataProvider.weeklyAverage
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.dateInterval(of: .weekOfYear, for: $0)?.start },
            "Expected timestamps to match earliest in each week"
        )
    }

    @Test func monthlyAverage() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 4_000_000))
        let entry2b = ChartEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 4_000_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let sut = ChartDataProvider.monthlyAverage
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.dateInterval(of: .month, for: $0)?.start },
            "Expected timestamps to match earliest in each month"
        )
    }

    @Test func custom() {
        let entry1a = ChartEntry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = ChartEntry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = ChartEntry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 80))
        let entry2b = ChartEntry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 81))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let sut = ChartDataProvider.custom(timeUnit: .minute, aggregator: .average)
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { Calendar.current.dateInterval(of: .minute, for: $0)?.start },
            "Expected timestamps to match earliest in each minute"
        )
    }
}
