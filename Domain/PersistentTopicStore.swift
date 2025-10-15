//
//  PersistentTopicStore.swift
//  Domain
//
//  Created by Lennart Wisbar on 18.09.25.
//

@Observable
public class PersistentTopicStore: TopicStore {
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
}
