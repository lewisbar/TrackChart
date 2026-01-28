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
    
    public var average: Double {
        0
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
            RawEntry(value: 0.6, timestamp: .now),
            RawEntry(value: -4.1, timestamp: .now)
        ])
        
        #expect(sut.sum == 2)
    }
    
    @Test func average_whenEmpty_returnsZero() {
        let sut = Topic(entries: [])
        #expect(sut.average == 0)
    }
}
