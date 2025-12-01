//
//  TopicEntityMappingTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 02.12.25.
//

import Testing
import Presentation
import Persistence

struct TopicEntityMappingTests {
    @Test func viewTopic() {
        let sut = TopicEntity(
            id: UUID(),
            name: "a topic",
            entries: [
                EntryEntity(value: 1, timestamp: .now.advanced(by: -400)),
                EntryEntity(value: -1, timestamp: .now.advanced(by: -300)),
                EntryEntity(value: 10, timestamp: .now.advanced(by: -200)),
            ],
            palette: "Ocean",
            aggregator: "Sum",
            treatsMissingAsZero: false,
            sortIndex: 0
        )

        let result = sut.viewTopic

        #expect(result.id == sut.id)
        #expect(result.name == sut.name)
        #expect(result.entries == sut.sortedEntries.map {
            ViewEntry(id: $0.id, value: $0.value, timestamp: $0.timestamp)
        })
        #expect(result.palette == .ocean)
        #expect(result.aggregator == .sum)
        #expect(result.treatsMissingAsZero == sut.treatsMissingAsZero)
    }

    @Test func settingsViewTopic() {
        let sut = TopicEntity(
            id: UUID(),
            name: "a topic",
            entries: [
                EntryEntity(value: 1, timestamp: .now.advanced(by: -400)),
                EntryEntity(value: -1, timestamp: .now.advanced(by: -300)),
                EntryEntity(value: 10, timestamp: .now.advanced(by: -200)),
            ],
            palette: "Lavender Field",
            aggregator: "Sum",
            treatsMissingAsZero: false,
            sortIndex: 0
        )

        let result = sut.settingsViewTopic

        #expect(result.name == sut.name)
        #expect(result.palette == .lavenderField)
        #expect(result.aggregator == .sum)
        #expect(result.treatsMissingAsZero == sut.treatsMissingAsZero)
    }

    @Test func minorMappings() {
        let sut = TopicEntity(
            id: UUID(),
            name: "a topic",
            entries: [
                EntryEntity(value: 1, timestamp: .now.advanced(by: -400)),
                EntryEntity(value: -1, timestamp: .now.advanced(by: -300)),
                EntryEntity(value: 10, timestamp: .now.advanced(by: -200)),
            ],
            palette: "Fire",
            aggregator: "Average",
            treatsMissingAsZero: false,
            sortIndex: 0
        )

        #expect(sut.viewEntries == sut.sortedEntries.map {
            ViewEntry(id: $0.id, value: $0.value, timestamp: $0.timestamp)
        })
        #expect(sut.viewAggregator == .average)
        #expect(sut.viewPalette == .fire)
    }
}
