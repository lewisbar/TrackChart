//
//  SwiftDataTopicPersistenceServiceTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 16.10.25.
//

import Testing
import SwiftData
import Foundation
import Domain

@Model
private class TopicEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var entries: [EntryEntity]
    var unsubmittedValue: Double
    var sortIndex: Int

    init(id: UUID, name: String, entries: [EntryEntity], unsubmittedValue: Double, sortIndex: Int) {
        self.id = id
        self.name = name
        self.entries = entries
        self.unsubmittedValue = unsubmittedValue
        self.sortIndex = sortIndex
    }

    init(from topic: Topic) {
        self.id = topic.id
        self.name = topic.name
        self.entries = topic.entries.map(EntryEntity.init)
        self.unsubmittedValue = topic.unsubmittedValue
        self.sortIndex = 0  // TODO: Handle index logic
    }

    var topic: Topic {
        Topic(id: id, name: name, entries: entries.map(\.entry), unsubmittedValue: unsubmittedValue)
    }
}

@Model
private class EntryEntity {
    var value: Double
    var timestamp: Date
    var sortIndex: Int

    init(value: Double, timestamp: Date, sortIndex: Int) {
        self.value = value
        self.timestamp = timestamp
        self.sortIndex = sortIndex
    }

    init(from entry: Entry) {
        self.value = entry.value
        self.timestamp = entry.timestamp
        self.sortIndex = 0  // TODO: Handle index logic
    }

    var entry: Entry {
        Entry(value: value, timestamp: timestamp)
    }
}

class SwiftDataTopicPersistenceService {
    private var sortedTopics = [Topic]()
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func create(_ topic: Topic) throws {
        let entity = TopicEntity(from: topic)
        context.insert(entity)
        try context.save()
        sortedTopics.append(topic)
    }

    func load() throws -> [Topic] {
        let descriptor = FetchDescriptor<TopicEntity>(sortBy: [SortDescriptor(\.sortIndex)])
        let entities = try context.fetch(descriptor)
        return entities.map(\.topic)
    }
}

class SwiftDataTopicPersistenceServiceTests {
    @Test func create_storesTopic() throws {
        let container = try ModelContainer(
            for: TopicEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let sut = SwiftDataTopicPersistenceService(context: context)
        let topic = Topic(id: UUID(), name: "topic", entries: [
            Entry(value: 2.3, timestamp: Date())
        ], unsubmittedValue: 4.1)

        try sut.create(topic)

        let loadedTopics = try sut.load()
        #expect(loadedTopics == [topic])
    }
}
