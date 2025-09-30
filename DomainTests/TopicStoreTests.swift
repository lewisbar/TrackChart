//
//  TopicStoreTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Testing
import Domain

class TopicStoreTests {
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
        let topicToUpdate = Topic(id: topics[2].id, name: "new name", entries: [8, 8, -8])
        let (sut, persistenceService) = makeSUT(with: topics)
        try sut.load()

        try sut.update(topicToUpdate)

        var expectedTopics = topics
        expectedTopics[2] = topicToUpdate
        #expect(sut.topics == expectedTopics)
        #expect(persistenceService.updatedTopics == [topicToUpdate])
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

    @Test func submitNewValueToTopic() throws {
        let topics = sampleTopics()
        let selectedTopic = topics[3]
        let newValue = -14
        let (sut, persistenceService) = makeSUT(with: topics)
        try sut.load()

        try sut.submit(newValue, to: selectedTopic)

        let updatedTopic = sut.topic(for: selectedTopic.id)
        #expect(updatedTopic?.entries == selectedTopic.entries + [newValue])
        #expect(persistenceService.updatedTopics == [updatedTopic])
    }

    @Test func removeLastValueFromTopic() throws {
        let topics = sampleTopics()
        let selectedTopic = topics[2]
        let (sut, persistenceService) = makeSUT(with: topics)
        try sut.load()

        try sut.removeLastValue(from: selectedTopic)

        let updatedTopic = sut.topic(for: selectedTopic.id)
        #expect(updatedTopic?.entries == selectedTopic.entries.dropLast())
        #expect(persistenceService.updatedTopics == [updatedTopic])
    }

    @Test func changeTopicName() throws {
        let topics = sampleTopics()
        let selectedTopic = topics[2]
        let newName = "New Topic Name"
        let (sut, persistenceService) = makeSUT(with: topics)
        try sut.load()

        try sut.rename(selectedTopic, to: newName)

        let updatedTopic = sut.topic(for: selectedTopic.id)
        #expect(updatedTopic?.name == newName)
        #expect(persistenceService.updatedTopics == [updatedTopic])
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
    var reorderedTopicLists = [[Topic]]()
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

    func reorder(to newOrder: [Topic]) throws {
        reorderedTopicLists.append(newOrder)
    }

    func load() -> [Topic] {
        loadCallCount += 1
        return stubbedTopics
    }

    func stub(_ topics: [Topic]) {
        stubbedTopics = topics
    }
}

private actor ObservationTracker {
    var triggered = false
    func setTriggered() { triggered = true }
    func getTriggered() -> Bool { triggered }
}
