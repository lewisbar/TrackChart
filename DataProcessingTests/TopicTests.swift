//
//  TopicTests.swift
//  DataProcessingTests
//
//  Created by Lennart Wisbar on 28.01.26.
//

import Testing
import DataProcessing

public struct Topic {
    public let entries: [RawEntry]
    
    public var sum: Double {
        0
    }
}

struct TopicTests {
    @Test func sum_whenEmpty_returnsZero() {
        let sut = Topic(entries: [])
        #expect(sut.sum == 0)
    }
}
