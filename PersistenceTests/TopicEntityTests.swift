//
//  TopicEntityTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 20.10.25.
//

import Testing
import SwiftData
import Persistence

@MainActor
struct TopicEntityTests {
    @Test func entryCount() throws {
        let context = try makeContext()
        let entries = makeEntryEntities()
        let topicEntity = makeTopicEntity(with: entries)
        try setUp(context: context, with: topicEntity)

        let entryCount = topicEntity.entryCount

        #expect(entryCount == entries.count)
    }

    @Test func entryCount_withNilEntries_returnsZero() throws {
        let context = try makeContext()
        let topicEntity = makeTopicEntity(with: nil)
        try setUp(context: context, with: topicEntity)

        let entryCount = topicEntity.entryCount

        #expect(entryCount == 0)
    }

    @Test func sortedEntries() throws {
        let context = try makeContext()
        let entries = makeEntryEntities()
        let topicEntity = makeTopicEntity(with: entries)
        try setUp(context: context, with: topicEntity)

        let sortedEntries = topicEntity.sortedEntries

        #expect(sortedEntries.map(\.value) == entries.sorted(by: { $0.timestamp < $1.timestamp }).map(\.value))
        #expect(sortedEntries.map(\.timestamp) == entries.sorted(by: { $0.timestamp < $1.timestamp }).map(\.timestamp))
    }

    @Test func sortedEntries_withNilEntries_returnsEmpty() throws {
        let context = try makeContext()
        let topicEntity = makeTopicEntity(with: nil)
        try setUp(context: context, with: topicEntity)

        let sortedEntries = topicEntity.sortedEntries

        #expect(sortedEntries.isEmpty)
    }

    // MARK: - Helpers

    private func makeContext() throws -> ModelContext {
        let schema = Schema([TopicEntity.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        return ModelContext(container)
    }

    private func makeEntryEntities() -> [EntryEntity] {
        [
            EntryEntity(value: 0, timestamp: .now.advanced(by: -120)),
            EntryEntity(value: -4.3, timestamp: .now.advanced(by: -100)),
            EntryEntity(value: 100, timestamp: .now.advanced(by: 0)),
            EntryEntity(value: -2000, timestamp: .now.advanced(by: -60)),
            EntryEntity(value: 10, timestamp: .now.advanced(by: -40))
        ]
    }

    private func makeTopicEntity(with entries: [EntryEntity]?) -> TopicEntity {
        TopicEntity(id: UUID(), name: "Topic 1", entries: entries, palette: "ocean", sortIndex: 7)
    }

    private func setUp(context: ModelContext, with topicEntity: TopicEntity) throws {
        context.insert(topicEntity)
        try context.save()
    }
}
