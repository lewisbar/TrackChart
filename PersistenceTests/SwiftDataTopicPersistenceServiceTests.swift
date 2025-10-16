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

    var topic: Topic {
        Topic(id: id, name: name, entries: entries.map(\.entry), unsubmittedValue: unsubmittedValue)
    }
}

@Model
private class EntryEntity {
    var value: Double
    var timestamp: Date
    var sortIndex: Int
    @Relationship(inverse: \TopicEntity.entries) var topic: TopicEntity?

    init(value: Double, timestamp: Date, sortIndex: Int) {
        self.value = value
        self.timestamp = timestamp
        self.sortIndex = sortIndex
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
        let entries = topic.entries.enumerated().map { index, entry in
            EntryEntity(value: entry.value, timestamp: entry.timestamp, sortIndex: index)
        }
        let entity = TopicEntity(id: topic.id, name: topic.name, entries: entries, unsubmittedValue: topic.unsubmittedValue, sortIndex: sortedTopics.count)

        context.insert(entity)
        try context.save()
        sortedTopics.append(topic)
    }

    func load() throws -> [Topic] {
        let descriptor = FetchDescriptor<TopicEntity>(sortBy: [SortDescriptor(\.sortIndex)])
        let entities = try context.fetch(descriptor)
        sortedTopics = entities.map(\.topic)
        return sortedTopics
    }
}

class SwiftDataTopicPersistenceServiceTests {
    @Test func createAndLoad_storesAndLoadsSingleTopic() throws {
        let sut = try makeSUT()
        let topic = topic(name: "topic")

        try sut.create(topic)

        let loadedTopics = try sut.load()
        #expect(loadedTopics == [topic])
    }

    @Test func createAndLoad_storesAndLoadsMultipleTopics_andPreservesOrder() throws {
        let sut = try makeSUT()
        let topic1 = topic(name: "topic 1")
        let topic2 = topic(name: "topic 2")
        let topic3 = topic(name: "topic 3")
        let originalOrder = [topic2, topic1, topic3]

        for topic in originalOrder {
            try sut.create(topic)
        }

        let loadedTopics = try sut.load()
        #expect(loadedTopics == originalOrder)
    }

    // MARK: - Helpers

    private func makeSUT() throws -> SwiftDataTopicPersistenceService {
        let context = try makeModelContext()
        let sut = SwiftDataTopicPersistenceService(context: context)
        weakSUT = sut
        return sut
    }

    private func makeModelContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: TopicEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    private func topic(name: String = "a topic", values: [Double] = [], unsubmittedValue: Double = 0) -> Topic {
        Topic(id: UUID(), name: name, entries: entries(from: values), unsubmittedValue: unsubmittedValue)
    }

    private func entries(from values: [Double]) -> [Entry] {
        values.map { Entry(value: $0, timestamp: Date())}
    }

    private weak var weakSUT: SwiftDataTopicPersistenceService?

    deinit {
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
    }
}
