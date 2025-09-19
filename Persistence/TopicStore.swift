//
//  TopicStore.swift
//  Persistence
//
//  Created by LennartWisbar on 18.09.25.
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
        topics.append(topic)
        try persistenceService.create(topic)
    }

    public func update(_ topic: Topic) throws {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else {
            try add(topic)
            return
        }

        topics[index] = topic
        try persistenceService.update(topic)
    }

    public func reorder(to newOrder: [Topic]) throws {
        topics = newOrder
        try persistenceService.reorder(to: newOrder)
    }

    public func remove(_ topic: Topic) throws {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else { return }

        topics.remove(at: index)
        try persistenceService.delete(topic)
    }
}
