//
//  TopicStore.swift
//  Persistence
//
//  Created by LennartWisbar on 18.09.25.
//

public class TopicStore {
    public var topics: [Topic] = []
    private let persistenceService: TopicPersistenceService

    public init(persistenceService: TopicPersistenceService) {
        self.persistenceService = persistenceService
        load()
    }

    public func load() {
        topics = persistenceService.load()
    }

    public func add(_ topic: Topic) {
        topics.append(topic)
        persistenceService.create(topic)
    }

    public func update(_ topic: Topic) {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else {
            add(topic)
            return
        }

        topics[index] = topic
        persistenceService.update(topic)
    }

    public func remove(_ topic: Topic) {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else { return }

        topics.remove(at: index)
        persistenceService.delete(topic)
    }
}
