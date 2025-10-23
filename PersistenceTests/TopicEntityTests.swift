//
//  TopicEntityTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 20.10.25.
//

import Testing
import SwiftData
import Persistence
import Domain

struct TopicEntityTests {
    @Test func mapToDomainModel() throws {
        let context = try makeContext()
        let entries = makeEntryEntities()
        let topicEntity = makeTopicEntity(with: entries)
        try setUp(context: context, with: topicEntity)

        let expectedEntries = entries.sorted(by: { $0.timestamp < $1.timestamp }).map { Entry(value: $0.value, timestamp: $0.timestamp) }
        let expectedTopic = Topic(id: topicEntity.id, name: topicEntity.name, entries: expectedEntries)

        let result = topicEntity.topic

        #expect(result == expectedTopic)
        #expect(result.entries == expectedEntries)
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

    private func makeTopicEntity(with entries: [EntryEntity]) -> TopicEntity {
        TopicEntity(id: UUID(), name: "Topic 1", entries: entries, sortIndex: 7)
    }

    private func setUp(context: ModelContext, with topicEntity: TopicEntity) throws {
        context.insert(topicEntity)
        try context.save()
    }
}
