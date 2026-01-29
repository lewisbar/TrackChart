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
        let sut = Topic(entries: [])
        #expect(sut.sum == 0)
    }
    
    @Test func sum_returnsSumOfEntryValues() {
        let sut = Topic(entries: [
            RawEntry(value: 5.5, timestamp: .now),
            RawEntry(value: 6.5, timestamp: .now),
            RawEntry(value: -3, timestamp: .now)
        ])
        
        #expect(sut.sum == 9)
    }
    
    @Test func average_whenEmpty_returnsNil() {
        let sut = Topic(entries: [])
        #expect(sut.average == nil)
    }
    
    @Test func average_returnsAverageOfEntryValues() {
        let sut = Topic(entries: [
            RawEntry(value: 5.5, timestamp: .now),
            RawEntry(value: 6.5, timestamp: .now),
            RawEntry(value: -3, timestamp: .now)
        ])
        
        #expect(sut.average == 3)
    }
    
    @Test func highest_whenEmpty_returnsNil() {
        let sut = Topic(entries: [])
        #expect(sut.highest == nil)
    }
    
    @Test func highest_returnsHighestValue() {
        let sut = Topic(entries: [
            RawEntry(value: 5.5, timestamp: .now),
            RawEntry(value: 6.5, timestamp: .now),
            RawEntry(value: -3, timestamp: .now)
        ])
        
        #expect(sut.highest == 6.5)
    }
}
