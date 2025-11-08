//
//  AggregatorTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 07.11.25.
//

import Testing
import TrackChartiOS

struct AggregatorTests {
    @Test func sum() {
        #expect(Aggregator.sum.aggregate([-1.5, 0, 12.5, 5]) == 16.0)
    }

    @Test func sum_whenEmpty_returnsZero() {
        #expect(Aggregator.sum.aggregate([]) == 0)
    }

    @Test func average() {
        #expect(Aggregator.average.aggregate([-1.5, 0, 12.5, 5]) == 4.0)
    }

    @Test func average_whenEmpty_returnsZero() {
        #expect(Aggregator.average.aggregate([]) == 0)
    }
}
