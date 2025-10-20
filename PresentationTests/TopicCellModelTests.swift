//
//  TopicCellModelTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 20.10.25.
//

import Testing
import Presentation
import Domain

@Test func initFromDomain() {
    let entries = [
        Entry(value: 0.1, timestamp: .now.advanced(by: -1000)),
        Entry(value: 1, timestamp: .now.advanced(by: 0)),
        Entry(value: -1, timestamp: .now.advanced(by: 50)),
        Entry(value: 1000, timestamp: .now.advanced(by: -50)),
        Entry(value: -1000, timestamp: .now.advanced(by: -12000)),
    ]
    let topic = Topic(id: UUID(), name: "A Topic", entries: entries, unsubmittedValue: 5.5)

    let result = TopicCellModel(from: topic)

    let expectedEntries = entries.map { TopicCellEntry(value: $0.value, timestamp: $0.timestamp) }
    let expectedCellModel = TopicCellModel(id: topic.id, name: topic.name, info: "5 entries", entries: expectedEntries)

    #expect(result == expectedCellModel)
    #expect(result.entries == expectedEntries)
}
