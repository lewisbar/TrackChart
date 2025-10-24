//
//  TopicCellModelTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 20.10.25.
//

import Testing
import Presentation
import Domain

@Test func initFromDomain_withSeveralEntries_usesPluralForInfo() {
    let entries = [
        Entry(value: -1000, timestamp: .now.advanced(by: -12000)),
        Entry(value: 0.1, timestamp: .now.advanced(by: -1000)),
        Entry(value: 1000, timestamp: .now.advanced(by: -50)),
        Entry(value: 1, timestamp: .now.advanced(by: 0)),
        Entry(value: -1, timestamp: .now.advanced(by: 50)),
    ]
    let topic = Topic(id: UUID(), name: "A Topic", entries: entries)

    let result = CellTopic(from: topic)

    let expectedEntries = entries.map { ChartEntry(value: $0.value, timestamp: $0.timestamp) }
    let expectedCellModel = CellTopic(id: topic.id, name: topic.name, info: "5 entries", entries: expectedEntries)

    #expect(result == expectedCellModel)
    #expect(result.entries == expectedEntries)
}

@Test func initFromDomain_withZeroEntries_usesPluralForInfo() {
    let topic = Topic(id: UUID(), name: "A Topic", entries: [])

    let result = CellTopic(from: topic)

    let expectedCellModel = CellTopic(id: topic.id, name: topic.name, info: "0 entries", entries: [])

    #expect(result == expectedCellModel)
}

@Test func initFromDomain_withOneEntry_usesSingularForInfo() {
    let entries = [Entry(value: 0.1, timestamp: .now.advanced(by: -1000))]
    let topic = Topic(id: UUID(), name: "A Topic", entries: entries)

    let result = CellTopic(from: topic)

    let expectedEntries = entries.map { ChartEntry(value: $0.value, timestamp: $0.timestamp) }
    let expectedCellModel = CellTopic(id: topic.id, name: topic.name, info: "1 entry", entries: expectedEntries)

    #expect(result == expectedCellModel)
    #expect(result.entries == expectedEntries)
}
