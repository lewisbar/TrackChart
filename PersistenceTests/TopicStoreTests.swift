//
//  TopicStoreTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Testing
import Foundation

struct Topic: Equatable {
    let id: UUID
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
        load()
    }

    func load() {
        topics = persistenceService.load()
    }

    func add(_ topic: Topic) {
        topics.append(topic)
        persistenceService.create(topic)
    }

    func update(_ topic: Topic) {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else {
            add(topic)
            return
        }

        topics[index] = topic
        persistenceService.update(topic)
    }

    func remove(_ topic: Topic) {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else { return }

        topics.remove(at: index)
        persistenceService.delete(topic)
    }
}

class TopicStoreTests {
    @Test func init_loadsTopics() {
        let topics = sampleTopics()
        let (sut, persistenceService) = makeSUT(with: topics)

        #expect(persistenceService.loadCallCount == 1)
        #expect(sut.topics == topics)
    }

    @Test func add_addsAndSavesTopic() {
        let (sut, persistenceService) = makeSUT()
        let topic1 = sampleTopic1()
        let topic2 = sampleTopic2()

        sut.add(topic1)

        #expect(sut.topics == [topic1])
        #expect(persistenceService.createdTopics == [topic1])

        sut.add(topic2)

        #expect(sut.topics == [topic1, topic2])
        #expect(persistenceService.createdTopics == [topic1, topic2])
    }

    @Test func delete_deletesAlsoFromPersistence() {
        let reducedTopics = sampleTopics()
        let topicToDelete = sampleTopic1()
        var allTopics = reducedTopics
        allTopics.insert(topicToDelete, at: 1)
        let (sut, persistenceService) = makeSUT(with: allTopics)

        sut.remove(topicToDelete)

        #expect(sut.topics == reducedTopics)
        #expect(persistenceService.deletedTopics == [topicToDelete])
    }

    @Test func delete_whenEmpty_doesNothing() {
        let topicToDelete = sampleTopic1()
        let (sut, persistenceService) = makeSUT()
        #expect(sut.topics == [])

        sut.remove(topicToDelete)

        #expect(sut.topics == [])
        #expect(persistenceService.deletedTopics == [])
    }

    @Test func delete_whenTopicDoesNotExist_doesNothing() {
        let topics = sampleTopics()
        let topicToDelete = sampleTopic1()
        let (sut, persistenceService) = makeSUT(with: topics)

        sut.remove(topicToDelete)

        #expect(sut.topics == topics)
        #expect(persistenceService.deletedTopics == [])
    }

    @Test func update_whenTopicDoesNotExist_createsNewTopic() {
        let topics = sampleTopics()
        let topicToUpdate = sampleTopic1()
        let (sut, persistenceService) = makeSUT(with: topics)

        sut.update(topicToUpdate)

        #expect(sut.topics == topics + [topicToUpdate])
        #expect(persistenceService.updatedTopics == [])
        #expect(persistenceService.createdTopics == [topicToUpdate])
    }

    @Test func update_updatesExistingTopic() {
        let topics = sampleTopics()
        let topicToUpdate = Topic(id: topics[2].id, name: "new name", entries: [8, 8, -8])
        let (sut, persistenceService) = makeSUT(with: topics)

        sut.update(topicToUpdate)

        var expectedTopics = topics
        expectedTopics[2] = topicToUpdate
        #expect(sut.topics == expectedTopics)
        #expect(persistenceService.updatedTopics == [topicToUpdate])
        #expect(persistenceService.createdTopics == [])
    }

    // MARK: - Helpers

    private func makeSUT(with topics: [Topic] = []) -> (sut: TopicStore, persistenceService: TopicPersistenceServiceSpy) {
        let persistenceService = TopicPersistenceServiceSpy()
        persistenceService.stub(topics)
        let sut = TopicStore(persistenceService: persistenceService)

        weakSUT = sut
        weakPersistenceService = persistenceService

        return (sut, persistenceService)
    }

    private func sampleTopics() -> [Topic] {
        [
            Topic(id: UUID(), name: "Topic 1", entries: [0, 3, 4, 5, 2, 3, 4, -1]),
            Topic(id: UUID(), name: "Topic 2", entries: [-3, 4, 5, 6, 3, 4, 23, -12, 0]),
            Topic(id: UUID(), name: "Topic 3", entries: [100, 200, 1000, -2000, 30, 10]),
            Topic(id: UUID(), name: "Topic 4", entries: [30]),
            Topic(id: UUID(), name: "Topic 5", entries: []),
            Topic(id: UUID(), name: "Topic 6", entries: [-12]),
        ]
    }

    private func sampleTopic1() -> Topic {
        Topic(id: UUID(), name: "a topic", entries: [1, 2, 3])
    }

    private func sampleTopic2() -> Topic {
        Topic(id: UUID(), name: "another topic", entries: [45, 67, 89, -12])
    }

    private weak var weakSUT: TopicStore?
    private weak var weakPersistenceService: TopicPersistenceServiceSpy?

    deinit {
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
        #expect(weakPersistenceService == nil, "Instance should have been deallocated. Potential memory leak.")
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
