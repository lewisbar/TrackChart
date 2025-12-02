//
//  AggregatorMappingTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 02.12.25.
//

import Testing
import Presentation
import DataProcessing

struct AggregatorMappingTests {
    @Test func viewAggregatorFromAggregator() {
        #expect(Aggregator.sum.viewAggregator == .sum)
        #expect(Aggregator.average.viewAggregator == .average)
    }

    @Test func aggregatorFromViewAggregator() {
        #expect(ViewAggregator.sum.aggregator == .sum)
        #expect(ViewAggregator.average.aggregator == .average)
    }

    @Test func viewAggregatorName() {
        #expect(ViewAggregator.sum.name == Aggregator.sum.name)
        #expect(ViewAggregator.average.name == Aggregator.average.name)
    }
}
