//
//  CellTopicTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 20.10.25.
//

import Testing
import Foundation
import TrackChartiOS

struct CellTopicTests {
    @Test func info_withMultipleEntries_usesPlural() {
        let sut = CellTopic(
            id: UUID(),
            name: "a topic",
            entries: [
                .init(value: 1, timestamp: .now.advanced(by: -1)),
                .init(value: 2, timestamp: .now)
            ],
            palette: .ocean
        )

        #expect(sut.info == "2 entries")
    }

    @Test func info_withSingleEntry_usesSingular() {
        let sut = CellTopic(
            id: UUID(),
            name: "a topic",
            entries: [
                .init(value: 1, timestamp: .now)
            ],
            palette: .ocean
        )

        #expect(sut.info == "1 entry")
    }

    @Test func info_withoutEntries_usesPlural() {
        let sut = CellTopic(
            id: UUID(),
            name: "a topic",
            entries: [],
            palette: .ocean
        )

        #expect(sut.info == "0 entries")
    }
}
