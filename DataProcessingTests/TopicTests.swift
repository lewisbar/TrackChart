//
//  TopicTests.swift
//  DataProcessingTests
//
//  Created by Lennart Wisbar on 28.01.26.
//

import Testing
import Foundation
import DataProcessing

public struct Topic {
    public let entries: [RawEntry]
    
    public var sum: Double {
        entries.map(\.value).reduce(0, +)
    }
    
    public var average: Double? {
        let count = Double(entries.count)
        return count > 0 ? sum / count : nil
    }
    
    public var highest: Double? {
        entries.map(\.value).max()
    }
}

struct TopicTests {
    @Test func sum_whenEmpty_returnsZero() {
        let sut = topic(from: [])
        #expect(sut.sum == 0)
    }
    
    @Test func sum_returnsSumOfEntryValues() {
        let sut = topic(from: [5.5, 6.5, -3])
        #expect(sut.sum == 9)
    }
    
    @Test func average_whenEmpty_returnsNil() {
        let sut = topic(from: [])
        #expect(sut.average == nil)
    }
    
    @Test func average_returnsAverageOfEntryValues() {
        let sut = topic(from: [5.5, 6.5, -3])
        #expect(sut.average == 3)
    }
    
    @Test func highest_whenEmpty_returnsNil() {
        let sut = topic(from: [])
        #expect(sut.highest == nil)
    }
    
    @Test func highest_returnsHighestValue() {
        let sut = topic(from: [5.5, 6.5, -3])
        #expect(sut.highest == 6.5)
    }
    
    // MARK: - Helpers
    
    private func topic(from values: [Double]) -> Topic {
        let entries = values.map {
            RawEntry(value: $0, timestamp: .now)
        }
        return Topic(entries: entries)
    }
}
