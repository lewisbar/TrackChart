//
//  ChartDataProviderTests.swift
//  DataProcessingTests
//
//  Created by Lennart Wisbar on 27.10.25.
//

import Testing
import Foundation
import DataProcessing

struct ChartDataProviderTests {
    @Test func raw() {
        let entry1 = Entry(value: 1.1, timestamp: .now.advanced(by: -200))
        let entry2 = Entry(value: -2.2, timestamp: .now.advanced(by: -100))
        let originalEntries = [entry1, entry2]

        let sut = ChartDataProvider.raw
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.map(\.value) == originalEntries.map(\.value))
        #expect(processedEntries.map(\.timestamp) == originalEntries.map(\.timestamp))
    }

    @Test func dailySum() {
        let entry1a = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 100_000))
        let entry2b = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 100_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let calendar = defaultCalendar()
        let sut = ChartDataProvider.dailySum(treatsMissingAsZero: false, calendar: calendar)
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 4])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { calendar.startOfDay(for: $0) },
            "Expected timestamps to match earliest in each day"
        )
    }

    @Test func dailySum_withZeroFilling() {
        let entry1a = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 200_000))
        let entry2b = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 200_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let calendar = defaultCalendar()
        let sut = ChartDataProvider.dailySum(treatsMissingAsZero: true, calendar: calendar)
        let processedEntries = sut.processedEntries(from: originalEntries)

        let expectedFillDate = calendar.startOfDay(for: Date(timeIntervalSinceReferenceDate: 100_000))

        #expect(processedEntries.count == 3, "Expected 3 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 0, 4])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, expectedFillDate, entry2a.timestamp].map { calendar.startOfDay(for: $0) },
            "Expected timestamps to match earliest in each day"
        )
    }

    @Test func dailyAverage() {
        let entry1a = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = Entry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 100_000))
        let entry2b = Entry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 100_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let calendar = defaultCalendar()
        let sut = ChartDataProvider.dailyAverage(treatsMissingAsZero: false, calendar: calendar)
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { calendar.startOfDay(for: $0) },
            "Expected timestamps to match earliest in each day"
        )
    }

    @Test func dailyAverage_withZeroFilling() {
        let entry1a = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = Entry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 200_000))
        let entry2b = Entry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 200_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let calendar = defaultCalendar()
        let sut = ChartDataProvider.dailyAverage(treatsMissingAsZero: true, calendar: calendar)
        let processedEntries = sut.processedEntries(from: originalEntries)

        let expectedFillDate = calendar.startOfDay(for: Date(timeIntervalSinceReferenceDate: 100_000))

        #expect(processedEntries.count == 3, "Expected 3 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 0, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, expectedFillDate, entry2a.timestamp].map { calendar.startOfDay(for: $0) },
            "Expected timestamps to match earliest in each day"
        )
    }

    @Test func weeklySum() {
        let entry1a = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 800_000))
        let entry2b = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 800_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let calendar = defaultCalendar()
        let sut = ChartDataProvider.weeklySum(treatsMissingAsZero: false, calendar: calendar)

        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 4])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { calendar.dateInterval(of: .weekOfYear, for: $0)?.start },
            "Expected timestamps to match earliest in each week"
        )
    }

    @Test func weeklySum_withZeroFilling() {
        let entry1a = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 1_600_000))
        let entry2b = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 1_600_001))

        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let calendar = defaultCalendar()

        let sut = ChartDataProvider.weeklySum(treatsMissingAsZero: true, calendar: calendar)

        let processedEntries = sut.processedEntries(from: originalEntries)

        let expectedFillDate = calendar.startOfDay(for: Date(timeIntervalSinceReferenceDate: 800_000))

        #expect(processedEntries.count == 3, "Expected 3 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 0, 4])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, expectedFillDate, entry2a.timestamp].map { calendar.dateInterval(of: .weekOfYear, for: $0)?.start },
            "Expected timestamps to match earliest in each week"
        )
    }

    @Test func weeklyAverage() {
        let entry1a = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = Entry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 800_000))
        let entry2b = Entry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 800_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let calendar = defaultCalendar()
        let sut = ChartDataProvider.weeklyAverage(treatsMissingAsZero: false, calendar: calendar)
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { calendar.dateInterval(of: .weekOfYear, for: $0)?.start },
            "Expected timestamps to match earliest in each week"
        )
    }

    @Test func weeklyAverage_withZeroFilling() {
        let entry1a = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = Entry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 1_600_000))
        let entry2b = Entry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 1_600_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let calendar = defaultCalendar()
        let sut = ChartDataProvider.weeklyAverage(treatsMissingAsZero: true, calendar: calendar)
        let processedEntries = sut.processedEntries(from: originalEntries)

        let expectedFillDate = calendar.startOfDay(for: Date(timeIntervalSinceReferenceDate: 800_000))

        #expect(processedEntries.count == 3, "Expected 3 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 0, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, expectedFillDate, entry2a.timestamp].map { calendar.dateInterval(of: .weekOfYear, for: $0)?.start },
            "Expected timestamps to match earliest in each week"
        )
    }

    @Test func monthlySum() {
        let entry1a = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 4_000_000))
        let entry2b = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 4_000_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let calendar = defaultCalendar()
        let sut = ChartDataProvider.monthlySum(treatsMissingAsZero: false, calendar: calendar)
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 4])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { calendar.dateInterval(of: .month, for: $0)?.start },
            "Expected timestamps to match earliest in each month"
        )
    }

    @Test func monthlySum_withZeroFilling() {
        let entry1a = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 6_000_000))
        let entry2b = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 6_000_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let calendar = defaultCalendar()
        let sut = ChartDataProvider.monthlySum(treatsMissingAsZero: true, calendar: calendar)
        let processedEntries = sut.processedEntries(from: originalEntries)

        let expectedFillDate = calendar.startOfDay(for: Date(timeIntervalSinceReferenceDate: 3_000_000))

        #expect(processedEntries.count == 3, "Expected 3 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 0, 4])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, expectedFillDate, entry2a.timestamp].map { calendar.dateInterval(of: .month, for: $0)?.start },
            "Expected timestamps to match earliest in each month"
        )
    }

    @Test func monthlyAverage() {
        let entry1a = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = Entry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 4_000_000))
        let entry2b = Entry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 4_000_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let calendar = defaultCalendar()
        let sut = ChartDataProvider.monthlyAverage(treatsMissingAsZero: false, calendar: calendar)
        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.count == 2, "Expected 2 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, entry2a.timestamp].map { calendar.dateInterval(of: .month, for: $0)?.start },
            "Expected timestamps to match earliest in each month"
        )
    }

    @Test func monthlyAverage_withZeroFilling() {
        let entry1a = Entry(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 1))
        let entry1b = Entry(value: 3, timestamp: Date(timeIntervalSinceReferenceDate: 2))
        let entry2a = Entry(value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 6_000_000))
        let entry2b = Entry(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 6_000_001))
        let originalEntries = [entry1a, entry1b, entry2a, entry2b]

        let calendar = defaultCalendar()
        let sut = ChartDataProvider.monthlyAverage(treatsMissingAsZero: true, calendar: calendar)
        let processedEntries = sut.processedEntries(from: originalEntries)

        let expectedFillDate = calendar.startOfDay(for: Date(timeIntervalSinceReferenceDate: 3_000_000))

        #expect(processedEntries.count == 3, "Expected 3 grouped entries")
        #expect(processedEntries.map(\.value) == [2, 0, 3])
        #expect(
            processedEntries.map(\.timestamp) == [entry1a.timestamp, expectedFillDate, entry2a.timestamp].map { calendar.dateInterval(of: .month, for: $0)?.start },
            "Expected timestamps to match earliest in each month"
        )
    }

    // MARK: - Automatic Preview Tests

    @Test("AutomaticPreview: Less than three days shows raw data")
    func automaticPreviewLessThanWeek() {
        let calendar = defaultCalendar()
        let baseDate = date(2024, 11, 10, calendar: calendar)

        // 2 days of data with multiple entries per day
        let entries = [
            Entry(value: 1, timestamp: baseDate),
            Entry(value: 2, timestamp: calendar.date(byAdding: .hour, value: 6, to: baseDate)!),
            Entry(value: 3, timestamp: calendar.date(byAdding: .day, value: 1, to: baseDate)!),
            Entry(value: 4, timestamp: calendar.date(byAdding: .hour, value: 4, to: baseDate)!)
        ]

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        // Should return all raw entries without aggregation
        #expect(processed.count == 4)
        #expect(processed.map(\.value) == [1, 2, 3, 4])
    }

    @Test("AutomaticPreview with zero filling: Less than three days still only shows raw data")
    func automaticPreviewLessThanWeek_withZeroFilling() {
        let calendar = defaultCalendar()
        let baseDate = date(2024, 11, 10, calendar: calendar)

        // 2 days of data with multiple entries per day
        let entries = [
            Entry(value: 1, timestamp: baseDate),
            Entry(value: 2, timestamp: calendar.date(byAdding: .hour, value: 6, to: baseDate)!),
            Entry(value: 3, timestamp: calendar.date(byAdding: .day, value: 1, to: baseDate)!),
            Entry(value: 4, timestamp: calendar.date(byAdding: .hour, value: 4, to: baseDate)!)
        ]

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: true, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        // Should return all raw entries without aggregation
        #expect(processed.count == 4)
        #expect(processed.map(\.value) == [1, 2, 3, 4])
    }

    @Test("AutomaticPreview: Three days uses day aggregation")
    func automaticPreviewThreeDays() {
        let calendar = defaultCalendar()
        let firstDay1 = date(2024, 11, 10, hour: 6, calendar: calendar)
        let firstDay2 = date(2024, 11, 10, hour: 12, calendar: calendar)
        let secondDay = date(2024, 11, 11, hour: 12, calendar: calendar)
        let thirdDay = date(2024, 11, 12, hour: 12, calendar: calendar)

        // 2 days of data with multiple entries per day
        let entries = [
            Entry(value: 1, timestamp: firstDay1),
            Entry(value: 2, timestamp: firstDay2),
            Entry(value: 3, timestamp: secondDay),
            Entry(value: 4, timestamp: thirdDay)
        ]

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        // Should return entries for each day
        #expect(processed.count == 3)
        #expect(processed.map(\.value) == [3, 3, 4])
    }

    @Test("AutomaticPreview with zero filling: Three days uses day aggregation, with gaps filled with zero")
    func automaticPreviewThreeDays_withZeroFilling() {
        let calendar = defaultCalendar()
        let firstDay1 = date(2024, 11, 10, hour: 6, calendar: calendar)
        let firstDay2 = date(2024, 11, 10, hour: 12, calendar: calendar)
        let thirdDay = date(2024, 11, 12, hour: 12, calendar: calendar)

        // 2 days of data with multiple entries per day
        let entries = [
            Entry(value: 1, timestamp: firstDay1),
            Entry(value: 2, timestamp: firstDay2),
            Entry(value: 4, timestamp: thirdDay)
        ]

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: true, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        // Should return entries for each day
        #expect(processed.count == 3)
        #expect(processed.map(\.value) == [3, 0, 4])
    }

    @Test("AutomaticPreview: 10 weeks or less uses daily sum")
    func automaticPreview10Weeks_sum() {
        let calendar = defaultCalendar()
        let baseDate = date(2024, 9, 1, calendar: calendar)

        // 8 weeks of data (56 days)
        let endDate = calendar.date(byAdding: .weekOfYear, value: 8, to: baseDate)!

        let entries = [
            Entry(value: 10, timestamp: baseDate),
            Entry(value: 20, timestamp: calendar.date(byAdding: .hour, value: 6, to: baseDate)!),  // Same day
            Entry(value: 30, timestamp: calendar.date(byAdding: .day, value: 10, to: baseDate)!),
            Entry(value: 40, timestamp: endDate)
        ]

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        // Should aggregate by day, so multiple entries on same day are summed
        #expect(processed.count == 3) // 3 different days

        // First day should sum to 30
        #expect(processed[0].value == 30)
    }

    @Test("AutomaticPreview with zero filling: 10 weeks or less uses daily sum, with gaps filled up with zeroes")
    func automaticPreview10Weeks_sum_withZeroFilling() {
        let calendar = defaultCalendar()
        let baseDate = date(2024, 9, 1, calendar: calendar)

        // 8 weeks of data (56 days)
        let endDate = calendar.date(byAdding: .weekOfYear, value: 8, to: baseDate)!

        let entries = [
            Entry(value: 10, timestamp: baseDate),
            Entry(value: 20, timestamp: calendar.date(byAdding: .hour, value: 6, to: baseDate)!),  // Same day
            Entry(value: 30, timestamp: calendar.date(byAdding: .day, value: 10, to: baseDate)!),
            Entry(value: 40, timestamp: endDate)
        ]

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: true, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        #expect(processed.count == 57)
        #expect(processed.first?.value == 30)
        #expect(processed[1].value == 0)
        #expect(processed.last?.value == 40)
    }

    @Test("AutomaticPreview: 10 weeks or less uses daily average")
    func automaticPreview10Weeks_average() {
        let calendar = defaultCalendar()
        let baseDate = date(2024, 9, 1, calendar: calendar)

        // 8 weeks of data (56 days)
        let endDate = calendar.date(byAdding: .weekOfYear, value: 8, to: baseDate)!

        let entries = [
            Entry(value: 10, timestamp: baseDate),
            Entry(value: 20, timestamp: calendar.date(byAdding: .hour, value: 6, to: baseDate)!),  // Same day
            Entry(value: 30, timestamp: calendar.date(byAdding: .day, value: 10, to: baseDate)!),
            Entry(value: 40, timestamp: endDate)
        ]

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .average, calendar: calendar).processedEntries(from: entries)

        // Should aggregate by day, so multiple entries on same day are summed
        #expect(processed.count == 3) // 3 different days

        // First day should average to 15
        #expect(processed[0].value == 15)
    }

    @Test("AutomaticPreview with zero filling: 10 weeks or less uses daily average, with gaps filled up with zeroes")
    func automaticPreview10Weeks_average_withZeroFilling() {
        let calendar = defaultCalendar()
        let baseDate = date(2024, 9, 1, calendar: calendar)

        // 8 weeks of data (56 days)
        let endDate = calendar.date(byAdding: .weekOfYear, value: 8, to: baseDate)!

        let entries = [
            Entry(value: 10, timestamp: baseDate),
            Entry(value: 20, timestamp: calendar.date(byAdding: .hour, value: 6, to: baseDate)!),  // Same day
            Entry(value: 30, timestamp: calendar.date(byAdding: .day, value: 10, to: baseDate)!),
            Entry(value: 40, timestamp: endDate)
        ]

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: true, aggregator: .average, calendar: calendar).processedEntries(from: entries)

        #expect(processed.count == 57)
        #expect(processed.first?.value == 15)
        #expect(processed[1].value == 0)
        #expect(processed.last?.value == 40)
    }

    @Test("AutomaticPreview: Up to 1 year uses weekly aggregation")
    func automaticPreviewOneYear() {
        let calendar = defaultCalendar()
        let baseDate = date(2024, 1, 1, calendar: calendar)

        // 6 months of weekly data
        let entries = (0..<26).map { weekOffset in
            let date = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: baseDate)!
            return Entry(value: Double(weekOffset + 1), timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        // Should use weekly aggregation
        // Since each entry is in a different week, count should match
        #expect(processed.count == 26)
    }

    @Test("AutomaticPreview with zero filling: Up to 1 year uses weekly aggregation, with gaps filled with zeroes")
    func automaticPreviewOneYear_withZeroFilling() {
        let calendar = defaultCalendar()
        let baseDate = date(2024, 1, 1, calendar: calendar)

        let indicesToExclude = [7, 14, 21]

        // 6 months of weekly data
        let entries = (0..<26).compactMap { weekOffset -> Entry? in
            guard !indicesToExclude.contains(weekOffset) else { return nil }
            let date = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: baseDate)!
            return Entry(value: Double(weekOffset + 1), timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: true, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        // Fills up all gaps
        #expect(processed.count == 26)
    }

    @Test("Zero filling only fills gaps in between, not start and end")
    func automaticPreviewOneYear_withZeroFilling_butNotAtStartOrEnd() {
        let calendar = defaultCalendar()
        let baseDate = date(2024, 1, 1, calendar: calendar)

        let indicesToExclude = [0, 1, 2, 14, 24, 25]

        // 6 months of weekly data
        let entries = (0..<26).compactMap { weekOffset -> Entry? in
            guard !indicesToExclude.contains(weekOffset) else { return nil }
            let date = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: baseDate)!
            return Entry(value: Double(weekOffset + 1), timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: true, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        // Fills up gap, but not start and end
        #expect(processed.count == 21)
    }

    @Test("AutomaticPreview: Up to 5 years uses monthly aggregation")
    func automaticPreview5Years_sum() {
        let calendar = defaultCalendar()
        let baseDate = date(2020, 1, 1, calendar: calendar)

        // 3 years of monthly data
        let entries = (0..<36).map { monthOffset in
            let date = calendar.date(byAdding: .month, value: monthOffset, to: baseDate)!
            return Entry(value: 100, timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .average, calendar: calendar).processedEntries(from: entries)

        // Should use monthly aggregation
        #expect(processed.count == 36)
    }

    @Test("AutomaticPreview with zero filling: Up to 5 years uses monthly aggregation, with gaps filled up with zeroes")
    func automaticPreview5Years_sum_withZeroFilling() {
        let calendar = defaultCalendar()
        let baseDate = date(2020, 1, 1, calendar: calendar)

        let indicesToExclude = [7, 14, 21]

        // 3 years of monthly data
        let entries = (0..<36).compactMap { monthOffset -> Entry? in
            guard !indicesToExclude.contains(monthOffset) else { return nil }
            let date = calendar.date(byAdding: .month, value: monthOffset, to: baseDate)!
            return Entry(value: 100, timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: true, aggregator: .average, calendar: calendar).processedEntries(from: entries)

        // All gaps are filled up
        #expect(processed.count == 36)
    }

    @Test("AutomaticPreview: More than 5 years uses yearly aggregation")
    func automaticPreviewMoreThan5Years_sum() {
        let calendar = defaultCalendar()
        let baseDate = date(2015, 1, 1, calendar: calendar)

        // 8 years of data
        let entries = (0..<8).map { yearOffset in
            let date = calendar.date(byAdding: .year, value: yearOffset, to: baseDate)!
            return Entry(value: 1000, timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        // Should use yearly aggregation
        #expect(processed.count == 8)
    }

    @Test("AutomaticPreview with zero filling: More than 5 years uses yearly aggregation, with gaps filled up with zeroes")
    func automaticPreviewMoreThan5Years_sum_withZeroFilling() {
        let calendar = defaultCalendar()
        let baseDate = date(2015, 1, 1, calendar: calendar)

        let indicesToExclude = [3, 5]

        // 8 years of data
        let entries = (0..<8).compactMap { yearOffset -> Entry? in
            guard !indicesToExclude.contains(yearOffset) else { return nil }
            let date = calendar.date(byAdding: .year, value: yearOffset, to: baseDate)!
            return Entry(value: 1000, timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: true, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        // Fills up all gaps
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
            return Entry(value: 5, timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

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
            return Entry(value: 500, timestamp: date)
        }

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        // Should use monthly aggregation (3 years < 5 years)
        // Each year creates one month entry
        #expect(processed.count == 3)
    }

    @Test("AutomaticPreview: Empty entries returns empty")
    func automaticPreviewEmpty() {
        let calendar = defaultCalendar()
        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .sum, calendar: calendar).processedEntries(from: [])

        #expect(processed.isEmpty)
    }

    @Test("AutomaticPreview: Single entry returns raw")
    func automaticPreviewSingleEntry() {
        let calendar = defaultCalendar()
        let entry = Entry(value: 42, timestamp: date(2024, 11, 10, calendar: calendar))

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .sum, calendar: calendar).processedEntries(from: [entry])

        #expect(processed.count == 1)
        #expect(processed[0].value == 42)
    }

    @Test("AutomaticPreview: Exactly at boundaries")
    func automaticPreviewBoundaries() {
        let calendar = defaultCalendar()
        let baseDate = date(2024, 1, 1, calendar: calendar)

        // Exactly 10 weeks apart
        let endDate = calendar.date(byAdding: .weekOfYear, value: 10, to: baseDate)!
        let entries = [
            Entry(value: 10, timestamp: baseDate),
            Entry(value: 20, timestamp: endDate)
        ]

        let processed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .sum, calendar: calendar).processedEntries(from: entries)

        // At exactly 10 weeks, should use daily aggregation
        #expect(processed.count == 2)

        // Exactly 1 year apart
        let yearEndDate = calendar.date(byAdding: .year, value: 1, to: baseDate)!
        let yearEntries = [
            Entry(value: 100, timestamp: baseDate),
            Entry(value: 200, timestamp: yearEndDate)
        ]

        let yearProcessed = ChartDataProvider.automaticPreview(treatsMissingAsZero: false, aggregator: .sum, calendar: calendar).processedEntries(from: yearEntries)

        // At exactly 1 year, should use weekly aggregation
        #expect(!yearProcessed.isEmpty)
    }

    // MARK: - Preset Tests

    @Test func preset_weekView_withSumAggregator_returnsDailySumProvider() {
        let provider = ChartDataProvider.preset(for: .week, aggregator: .sum, treatsMissingAsZero: false, calendar: Calendar(identifier: .gregorian))

        #expect(provider.name == "daily sum")
        #expect(provider.aggregator == .sum)
        #expect(provider.treatsMissingAsZero == false)
    }

    @Test func preset_weekView_withAverageAggregator_returnsDailyAverageProvider() {
        let provider = ChartDataProvider.preset(for: .week, aggregator: .average, treatsMissingAsZero: true, calendar: Calendar(identifier: .gregorian))

        #expect(provider.name == "daily average")
        #expect(provider.aggregator == .average)
        #expect(provider.treatsMissingAsZero == true)
    }

    @Test func preset_monthView_withSumAggregator_returnsDailySumProvider() {
        let provider = ChartDataProvider.preset(for: .month, aggregator: .sum, treatsMissingAsZero: true, calendar: Calendar(identifier: .gregorian))

        #expect(provider.name == "daily sum")
        #expect(provider.aggregator == .sum)
        #expect(provider.treatsMissingAsZero == true)
    }

    @Test func preset_monthView_withAverageAggregator_returnsDailyAverageProvider() {
        let provider = ChartDataProvider.preset(for: .month, aggregator: .average, treatsMissingAsZero: false, calendar: Calendar(identifier: .gregorian))

        #expect(provider.name == "daily average")
        #expect(provider.aggregator == .average)
        #expect(provider.treatsMissingAsZero == false)
    }

    @Test func preset_yearView_withSumAggregator_returnsMonthlySumProvider() {
        let provider = ChartDataProvider.preset(for: .year, aggregator: .sum, treatsMissingAsZero: false, calendar: Calendar(identifier: .gregorian))

        #expect(provider.name == "monthly sum")
        #expect(provider.aggregator == .sum)
        #expect(provider.treatsMissingAsZero == false)
    }

    @Test func preset_yearView_withAverageAggregator_returnsMonthlyAverageProvider() {
        let provider = ChartDataProvider.preset(for: .year, aggregator: .average, treatsMissingAsZero: true, calendar: Calendar(identifier: .gregorian))

        #expect(provider.name == "monthly average")
        #expect(provider.aggregator == .average)
        #expect(provider.treatsMissingAsZero == true)
    }

    // MARK: - Helpers

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12, calendar: Calendar) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.timeZone = calendar.timeZone

        return calendar.date(from: components)!
    }

    private func defaultCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.firstWeekday = 2  // Monday
        return calendar
    }
}
