//
//  PersistentTopicStoreTests.swift
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Testing
import Domain

class PersistentTopicStoreTests {
    @Test func init_doesNotLoadTopics() {
        let topics = sampleTopics()
        let (sut, persistenceService) = makeSUT(with: topics)

        #expect(persistenceService.loadCallCount == 0)
        #expect(sut.topics.isEmpty)
    }

    @Test func add_addsAndSavesTopic() throws {
        let (sut, persistenceService) = makeSUT()
        let topic1 = sampleTopic1()
        let topic2 = sampleTopic2()

        try sut.add(topic1)

        #expect(sut.topics == [topic1])
        #expect(persistenceService.createdTopics == [topic1])

        try sut.add(topic2)

        #expect(sut.topics == [topic1, topic2])
        #expect(persistenceService.createdTopics == [topic1, topic2])
    }

    @Test func add_throwsError() throws {
        let error = anyNSError()
        let (sut, _) = makeSUT(error: error)
        let topic = sampleTopic1()

        #expect(throws: type(of: error)) {
            try sut.add(topic)
        }

        #expect(sut.topics == [])
    }

    @Test func delete_deletesAlsoFromPersistence() throws {
        let reducedTopics = sampleTopics()
        let topicToDelete = sampleTopic1()
        var allTopics = reducedTopics
        allTopics.insert(topicToDelete, at: 1)
        let (sut, persistenceService) = makeSUT(with: allTopics)
        try sut.load()

        try sut.remove(topicToDelete)

        #expect(sut.topics == reducedTopics)
        #expect(persistenceService.deletedTopics == [topicToDelete])
    }

    @Test func delete_whenEmpty_doesNothing() throws {
        let topicToDelete = sampleTopic1()
        let (sut, persistenceService) = makeSUT()
        #expect(sut.topics.isEmpty)

        try sut.remove(topicToDelete)

        #expect(sut.topics.isEmpty)
        #expect(persistenceService.deletedTopics.isEmpty)
    }

    @Test func delete_whenTopicDoesNotExist_doesNothing() throws {
        let topics = sampleTopics()
        let topicToDelete = sampleTopic1()
        let (sut, persistenceService) = makeSUT(with: topics)
        try sut.load()

        try sut.remove(topicToDelete)

        #expect(sut.topics == topics)
        #expect(persistenceService.deletedTopics.isEmpty)
    }

    @Test func delete_onError_doesNotDelete() throws {
        let reducedTopics = sampleTopics()
        let topicToDelete = sampleTopic1()
        var allTopics = reducedTopics
        allTopics.insert(topicToDelete, at: 1)
        let error = anyNSError()
        let (sut, persistenceService) = makeSUT(with: allTopics)
        try sut.load()
        persistenceService.error = error

        #expect(throws: type(of: error)) {
            try sut.remove(topicToDelete)
        }

        #expect(sut.topics == allTopics)
        #expect(persistenceService.deletedTopics.isEmpty)
    }

    @Test func update_whenTopicDoesNotExist_createsNewTopic() throws {
        let topics = sampleTopics()
        let topicToUpdate = sampleTopic1()
        let (sut, persistenceService) = makeSUT(with: topics)
        try sut.load()

        try sut.update(topicToUpdate)

        #expect(sut.topics == topics + [topicToUpdate])
        #expect(persistenceService.updatedTopics.isEmpty)
        #expect(persistenceService.createdTopics == [topicToUpdate])
    }

    @Test func update_updatesExistingTopic() throws {
        let topics = sampleTopics()
        let topicToUpdate = Topic(id: topics[2].id, name: "new name", entries: entries(from: [8, 8, -8]), unsubmittedValue: 0)
        let (sut, persistenceService) = makeSUT(with: topics)
        try sut.load()

        try sut.update(topicToUpdate)

        var expectedTopics = topics
        expectedTopics[2] = topicToUpdate
        #expect(sut.topics == expectedTopics)
        #expect(persistenceService.updatedTopics == [topicToUpdate])
        #expect(persistenceService.createdTopics.isEmpty)
    }

    @Test func update_onError_doesNotUpdate() throws {
        let originalTopics = sampleTopics()
        let topicToUpdate = Topic(id: originalTopics[2].id, name: "new name", entries: entries(from: [8, 8, -8]), unsubmittedValue: 12)
        let (sut, persistenceService) = makeSUT(with: originalTopics)
        try sut.load()
        let error = anyNSError()
        persistenceService.error = error

        #expect(throws: type(of: error)) {
            try sut.update(topicToUpdate)
        }

        #expect(sut.topics == originalTopics)
        #expect(persistenceService.updatedTopics.isEmpty)
        #expect(persistenceService.createdTopics.isEmpty)
    }

    @Test func updateOrder_updatesOrderOfIDs() throws {
        let originalTopics = sampleTopics()
        let reorderedTopics = originalTopics.shuffled()
        let (sut, persistenceService) = makeSUT(with: originalTopics)
        try sut.load()

        try sut.reorder(to: reorderedTopics)

        #expect(sut.topics == reorderedTopics)
        #expect(persistenceService.reorderedTopicLists == [reorderedTopics])
    }

    @Test func updateOrder_onError_doesNotUpdate() throws {
        let originalTopics = sampleTopics()
        let reorderedTopics = originalTopics.shuffled()
        let (sut, persistenceService) = makeSUT(with: originalTopics)
        try sut.load()
        let error = anyNSError()
        persistenceService.error = error

        #expect(throws: type(of: error)) {
            try sut.reorder(to: reorderedTopics)
        }

        #expect(sut.topics == originalTopics)
        #expect(persistenceService.reorderedTopicLists.isEmpty)
    }

    @Test func topicForID_returnsCorrectTopicWithoutCallingPersistenceService() throws {
        let topics = sampleTopics()
        let pickedTopic = topics[3]
        let (sut, persistenceService) = makeSUT(with: topics)
        try sut.load()
        #expect(persistenceService.loadCallCount == 1)

        let requestedTopic = sut.topic(for: pickedTopic.id)

        #expect(requestedTopic == pickedTopic)
        #expect(persistenceService.loadCallCount == 1)
    }

    @Test func isObservable() async throws {
        let (sut, _) = makeSUT()
        let tracker = ObservationTracker()

        withObservationTracking {
            _ = sut.topics
        } onChange: {
            Task { await tracker.setTriggered() }
        }

        let newTopic = sampleTopic1()
        try sut.add(newTopic)

        try await Task.sleep(for: .milliseconds(10))
        let triggered = await tracker.getTriggered()
        #expect(triggered, "Expected observation to be triggered after adding value")
        #expect(sut.topics == [newTopic])
    }

    // MARK: - Helpers

    private func makeSUT(with topics: [Topic] = [], error: Error? = nil) -> (sut: PersistentTopicStore, persistenceService: TopicPersistenceServiceSpy) {
        let persistenceService = TopicPersistenceServiceSpy(topics: topics, error: error)
        let sut = PersistentTopicStore(persistenceService: persistenceService)

        weakSUT = sut
        weakPersistenceService = persistenceService

        return (sut, persistenceService)
    }

    private func sampleTopics() -> [Topic] {
        [
            Topic(id: UUID(), name: "Topic 1", entries: entries(from: [0, 3, 4, 5, 2, 3, 4, -1]), unsubmittedValue: 1),
            Topic(id: UUID(), name: "Topic 2", entries: entries(from: [-3, 4, 5, 6, 3, 4, 23, -12, 0]), unsubmittedValue: 10),
            Topic(id: UUID(), name: "Topic 3", entries: entries(from: [100, 200, 1000, -2000, 30, 10]), unsubmittedValue: 100),
            Topic(id: UUID(), name: "Topic 4", entries: entries(from: [30]), unsubmittedValue: -1),
            Topic(id: UUID(), name: "Topic 5", entries: entries(from: []), unsubmittedValue: -10),
            Topic(id: UUID(), name: "Topic 6", entries: entries(from: [-12]), unsubmittedValue: -100),
        ]
    }

    private func sampleTopic1() -> Topic {
        Topic(id: UUID(), name: "a topic", entries: entries(from: [1, 2, 3]), unsubmittedValue: 18)
    }

    private func sampleTopic2() -> Topic {
        Topic(id: UUID(), name: "another topic", entries: entries(from: [45, 67, 89, -12]), unsubmittedValue: -18)
    }

    private func entries(from values: [Int]) -> [Entry] {
        values.map {
            Entry(value: Double($0), timestamp: Date().advanced(by: -100))
        }
    }

    private weak var weakSUT: PersistentTopicStore?
    private weak var weakPersistenceService: TopicPersistenceServiceSpy?

    deinit {
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
        #expect(weakPersistenceService == nil, "Instance should have been deallocated. Potential memory leak.")
    }

    private func anyNSError() -> NSError {
        NSError(domain: "test", code: 0)
    }
}

private class TopicPersistenceServiceSpy: TopicPersistenceService {
    var createdTopics = [Topic]()
    var updatedTopics = [Topic]()
    var deletedTopics = [Topic]()
    var reorderedTopicLists = [[Topic]]()
    var loadCallCount = 0
    var stubbedTopics: [Topic]
    var error: Error?

    init(topics: [Topic], error: Error?) {
        self.stubbedTopics = topics
        self.error = error
    }

    func create(_ topic: Topic) throws {
        if let error { throw error }
        createdTopics.append(topic)
    }
    
    func update(_ topic: Topic) throws {
        if let error { throw error }
        updatedTopics.append(topic)
    }
    
    func delete(_ topic: Topic) throws {
        if let error { throw error }
        deletedTopics.append(topic)
    }

    func reorder(to newOrder: [Topic]) throws {
        if let error { throw error }
        reorderedTopicLists.append(newOrder)
    }

    func load() throws -> [Topic] {
        if let error { throw error }
        loadCallCount += 1
        return stubbedTopics
    }
}

private actor ObservationTracker {
    var triggered = false
    func setTriggered() { triggered = true }
    func getTriggered() -> Bool { triggered }
}
