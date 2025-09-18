//
//  TopicStoreTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Testing

struct Topic: Equatable {
    let name: String
    let entries: [Int]
}

protocol TopicPersistenceService {
    func create(_ topic: Topic)
    func update(_ topic: Topic)
    func delete(_ topic: Topic)
    func load() -> [Topic]
}

class TopicStore {
    var topics: [Topic] = []
    private let persistenceService: TopicPersistenceService

    init(persistenceService: TopicPersistenceService) {
        self.persistenceService = persistenceService
        self.topics = persistenceService.load()
    }

    func add(_ topic: Topic) {
        topics.append(topic)
        persistenceService.create(topic)
    }
}

struct TopicStoreTests {
    @Test func init_loadsTopics() {
        let persistenceService = TopicPersistenceServiceSpy()
        let topics = sampleTopics()
        persistenceService.stub(topics)

        let sut = TopicStore(persistenceService: persistenceService)

        #expect(persistenceService.loadCallCount == 1)
        #expect(sut.topics == topics)
    }

    @Test func add_addsAndSavesTopic() {
        let persistenceService = TopicPersistenceServiceSpy()
        let sut = TopicStore(persistenceService: persistenceService)
        let topic1 = Topic(name: "a topic", entries: [1, 2, 3])
        let topic2 = Topic(name: "another topic", entries: [45, 67, -89])

        sut.add(topic1)

        #expect(sut.topics == [topic1])
        #expect(persistenceService.createdTopics == [topic1])

        sut.add(topic2)

        #expect(sut.topics == [topic1, topic2])
        #expect(persistenceService.createdTopics == [topic1, topic2])
    }

    // MARK: - Helpers

    private func sampleTopics() -> [Topic] {
        [
            Topic(name: "Topic 1", entries: [0, 3, 4, 5, 2, 3, 4, -1]),
            Topic(name: "Topic 2", entries: [-3, 4, 5, 6, 3, 4, 23, -12, 0]),
            Topic(name: "Topic 3", entries: [100, 200, 1000, -2000, 30, 10]),
            Topic(name: "Topic 4", entries: [30]),
            Topic(name: "Topic 5", entries: []),
            Topic(name: "Topic 6", entries: [-12]),
        ]
    }
}

private class TopicPersistenceServiceSpy: TopicPersistenceService {
    var createdTopics = [Topic]()
    var updatedTopics = [Topic]()
    var deletedTopics = [Topic]()
    var loadCallCount = 0
    private(set) var stubbedTopics = [Topic]()

    func create(_ topic: Topic) {
        createdTopics.append(topic)
    }
    
    func update(_ topic: Topic) {
        updatedTopics.append(topic)
    }
    
    func delete(_ topic: Topic) {
        deletedTopics.append(topic)
    }
    
    func load() -> [Topic] {
        loadCallCount += 1
        return stubbedTopics
    }

    func stub(_ topics: [Topic]) {
        stubbedTopics = topics
    }
}
