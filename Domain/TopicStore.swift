//
//  TopicStore.swift
//  Domain
//
//  Created by Lennart Wisbar on 18.09.25.
//

@Observable
public class TopicStore {
    public var topics: [Topic] = []
    private let persistenceService: TopicPersistenceService

    public init(persistenceService: TopicPersistenceService) {
        self.persistenceService = persistenceService
    }

    public func load() throws {
        topics = try persistenceService.load()
    }

    public func add(_ topic: Topic) throws {
        try persistenceService.create(topic)
        topics.append(topic)
    }

    public func update(_ topic: Topic) throws {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else {
            try add(topic)
            return
        }

        try persistenceService.update(topic)
        topics[index] = topic
    }

    public func reorder(to newOrder: [Topic]) throws {
        try persistenceService.reorder(to: newOrder)
        topics = newOrder
    }

    public func remove(_ topic: Topic) throws {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else { return }

        try persistenceService.delete(topic)
        topics.remove(at: index)
    }

    public func topic(for id: UUID) -> Topic? {
        topics.first(where: { $0.id == id })
    }

    public func submit(_ newValue: Int, to topic: Topic) throws {
        let updatedTopic = Topic(id: topic.id, name: topic.name, entries: topic.entries + [newValue], unsubmittedValue: topic.unsubmittedValue)
        try update(updatedTopic)
    }

    public func removeLastValue(from topic: Topic) throws {
        let updatedTopic = Topic(id: topic.id, name: topic.name, entries: topic.entries.dropLast(), unsubmittedValue: topic.unsubmittedValue)
        try update(updatedTopic)
    }

    public func rename(_ topic: Topic, to newName: String) throws {
        let updatedTopic = Topic(id: topic.id, name: newName, entries: topic.entries, unsubmittedValue: topic.unsubmittedValue)
        try update(updatedTopic)
    }
}
