//
//  TopicTests.swift
//  DataProcessingTests
//
//  Created by Lennart Wisbar on 28.01.26.
//

import Testing
import Foundation
import DataProcessing

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
    
    @Test func lowest_whenEmpty_returnsNil() {
        let sut = topic(from: [])
        #expect(sut.lowest == nil)
    }
    
    @Test func lowest_returnsLowestValue() {
        let sut = topic(from: [5.5, 6.5, -3])
        #expect(sut.lowest == -3)
    }
    
    // MARK: - Helpers
    
    private func topic(from values: [Double]) -> Topic {
        let entries = values.map {
            Entry(value: $0, timestamp: .now)
        }
        return Topic(entries: entries)
    }
}
