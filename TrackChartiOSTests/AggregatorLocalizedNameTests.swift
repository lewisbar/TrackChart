//
//  AggregatorLocalizedNameTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 23.11.25.
//

import Testing
@testable import TrackChartiOS
import DataProcessing

struct AggregatorLocalizedNameTests {
    @Test func localizedName() {
        #expect(Aggregator.sum.localizedName == String(localized: .sum))
        #expect(Aggregator.average.localizedName == String(localized: .average))
    }
}
