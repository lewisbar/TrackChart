//
//  ChartDataProviderTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 27.10.25.
//

import Testing
@testable import TrackChartiOS
import Presentation

struct ChartDataProviderTests {
    @Test func raw() {
        let entry1 = ChartEntry(value: 1.1, timestamp: .now.advanced(by: -200))
        let entry2 = ChartEntry(value: -2.2, timestamp: .now.advanced(by: -100))
        let originalEntries = [entry1, entry2]
        let sut = ChartDataProvider.raw

        let processedEntries = sut.processedEntries(from: originalEntries)

        #expect(processedEntries.map(\.value) == originalEntries.map(\.value))
        #expect(processedEntries.map(\.timestamp) == originalEntries.map(\.timestamp))
    }
}
