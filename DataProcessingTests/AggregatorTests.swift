//
//  AggregatorTests.swift
//  DataProcessingTests
//
//  Created by Lennart Wisbar on 07.11.25.
//

import Testing
import DataProcessing

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

    @Test func name() {
        #expect(Aggregator.sum.name == "Sum")
        #expect(Aggregator.average.name == "Average")
    }

    @Test func aggregatorNamed() {
        #expect(Aggregator.aggregator(named: "Sum") == .sum)
        #expect(Aggregator.aggregator(named: "Average") == .average)
    }

    @Test func aggregatorNamed_nonExistentName_defaultsToSum() {
        #expect(Aggregator.aggregator(named: "sum") == .sum)
        #expect(Aggregator.aggregator(named: "average") == .sum)
        #expect(Aggregator.aggregator(named: "another invalid name") == .sum)
    }
}
