//
//  TopicEntityMappingTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 02.12.25.
//

import Testing
import Presentation
import Persistence
import DataProcessing

struct TopicEntityMappingTests {
    @Test func viewTopic() {
        let sut = TopicEntity(
            id: UUID(),
            name: "a topic",
            details: "some details",
            entries: [
                EntryEntity(value: 1, timestamp: .now.advanced(by: -400)),
                EntryEntity(value: -2, timestamp: .now.advanced(by: -300)),
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
        #expect(result.details == sut.details)
        #expect(result.entries == sut.sortedEntries.map {
            ViewEntry(id: $0.id, value: $0.value, timestamp: $0.timestamp)
        })
        #expect(result.aggregator == .sum)
        #expect(result.treatsMissingAsZero == sut.treatsMissingAsZero)
        #expect(result.sum == 9)
        #expect(result.average == 3)
        #expect(result.highest == 10)
        #expect(result.lowest == -2)
        #expect(result.palette == .ocean)
    }

    @Test func settingsTopic() {
        let sut = TopicEntity(
            id: UUID(),
            name: "a topic",
            details: "some details",
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

        let result = sut.settingsTopic

        #expect(result.name == sut.name)
        #expect(result.details == sut.details)
        #expect(result.palette == .lavenderField)
        #expect(result.aggregator == .sum)
        #expect(result.treatsMissingAsZero == sut.treatsMissingAsZero)
    }
    
    @Test func processingTopic() {
        let sut = TopicEntity(
            id: UUID(),
            name: "a topic",
            details: "some details",
            entries: [
                EntryEntity(value: 1, timestamp: .now.advanced(by: -400)),
                EntryEntity(value: -2, timestamp: .now.advanced(by: -300)),
                EntryEntity(value: 10, timestamp: .now.advanced(by: -200)),
            ],
            palette: "Lavender Field",
            aggregator: "Sum",
            treatsMissingAsZero: false,
            sortIndex: 0
        )
        
        let result = sut.processingTopic
        
        #expect(result.entries.count == 3)
        #expect(result.entries[0] == Entry(value: 1, timestamp: sut.sortedEntries[0].timestamp))
        #expect(result.entries[1] == Entry(value: -2, timestamp: sut.sortedEntries[1].timestamp))
        #expect(result.entries[2] == Entry(value: 10, timestamp: sut.sortedEntries[2].timestamp))
        #expect(result.sum == 9)
        #expect(result.average == 3)
        #expect(result.highest == 10)
        #expect(result.lowest == -2)
    }

    @Test func minorMappings() {
        let sut = TopicEntity(
            id: UUID(),
            name: "a topic",
            details: "some details",
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

    @Test func apply() {
        let sut = TopicEntity(
            id: UUID(),
            name: "a topic",
            details: "some details",
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

        let settingsTopic = SettingsTopic(name: "new name", details: "new details", palette: .lavenderField, aggregator: .average, treatsMissingAsZero: true)

        sut.apply(settingsTopic)

        #expect(sut.name == settingsTopic.name)
        #expect(sut.details == settingsTopic.details)
        #expect(sut.palette == settingsTopic.palette.name)
        #expect(sut.aggregator == settingsTopic.aggregator.name)
        #expect(sut.treatsMissingAsZero == settingsTopic.treatsMissingAsZero)
    }

    @Test func initFromSettingsTopic() {
        let settingsTopic = SettingsTopic(name: "a topic", details: "some details", palette: .arcticIce, aggregator: .average, treatsMissingAsZero: true)
        let sortIndex = 11

        let sut = TopicEntity(from: settingsTopic, at: sortIndex)

        #expect(sut.name == settingsTopic.name)
        #expect(sut.details == settingsTopic.details)
        #expect(sut.palette == settingsTopic.palette.name)
        #expect(sut.aggregator == settingsTopic.aggregator.name)
        #expect(sut.treatsMissingAsZero == settingsTopic.treatsMissingAsZero)
        #expect(sut.sortIndex == sortIndex)

    }
}
