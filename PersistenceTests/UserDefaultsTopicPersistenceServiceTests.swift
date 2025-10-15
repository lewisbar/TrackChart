//
//  UserDefaultsTopicPersistenceServiceTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Testing
import Persistence
import Domain

@Suite(.serialized)
class UserDefaultsTopicPersistenceServiceTests {
    // MARK: - Setup

    let suiteName = UUID().uuidString
    let userDefaults: UserDefaults

    private let testKey = #file
    private weak var weakSUT: UserDefaultsTopicPersistenceService?

    init() {
        userDefaults = UserDefaults(suiteName: suiteName)!
        cleanUp()
    }

    deinit {
        cleanUp()
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
    }

    // MARK: - Actual Tests

    @Test func init_doesNotTakeAnyAction() {
        let _ = makeSUT()
        #expect(storedTopicIDs() == nil)
    }

    @Test func create_createsTopic() throws {
        let id = UUID()
        let topic = Topic(id: id, name: "a topic", entries: [2, 1, 4, 6, 3], unsubmittedValue: 0)
        let sut = makeSUT()
        #expect(storedTopicIDs() == nil)

        try sut.create(topic)

        #expect(storedTopicIDs()?.count == 1)
        #expect(storedTopic(for: id) != nil)
    }

    @Test func create_whenIDAlreadyExists_overwrites() throws {
        let id = UUID()
        let firstTopic = Topic(id: id, name: "a topic", entries: [2, 1, 4, 6, 3], unsubmittedValue: 5)
        let topicWithSameID = Topic(id: id, name: "another topic", entries: [-2, -3, -50], unsubmittedValue: 100)
        let sut = makeSUT()
        #expect(storedTopicIDs() == nil)

        try sut.create(firstTopic)
        try sut.create(topicWithSameID)

        let loadedTopics = try sut.load()

        #expect(loadedTopics == [topicWithSameID])
    }

    @Test func load_whenNothingIsStored_returnsEmpty() throws {
        let sut = makeSUT()

        let loadedTopics = try sut.load()

        #expect(loadedTopics == [])
    }

    @Test func load_returnsStoredTopics() throws {
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [2, 1, 4, 6, 3], unsubmittedValue: 1)
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-31, 7, -4, 0], unsubmittedValue: -2)
        let sut = makeSUT()
        #expect(storedTopicIDs() == nil)

        try sut.create(topic1)
        try sut.create(topic2)

        let loadedTopics = try sut.load()
        #expect(loadedTopics == [topic1, topic2])
    }

    @Test func update_whenTopicDoesNotExist_creates() throws {
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [2, 1, 4, 6, 3], unsubmittedValue: 12)
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-31, 7, -4, 0], unsubmittedValue: 14)
        let sut = makeSUT()
        #expect(storedTopicIDs() == nil)

        try sut.create(topic1)
        try sut.update(topic2)

        let loadedTopics = try sut.load()

        #expect(loadedTopics == [topic1, topic2])
        let storedIDs = storedTopicIDs()?.compactMap { $0 as? String } ?? []
        #expect(storedIDs.contains(topic1.id.uuidString))
    }

    @Test func update_updatesCorrectTopic() throws {
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [2, 1, 4, 6, 3], unsubmittedValue: 3)
        let updatedTopic1 = Topic(id: topic1.id, name: "an updated topic", entries: [2, 1, 4, 6, 3], unsubmittedValue: 0)
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-31, 7, -4, 0], unsubmittedValue: 12)
        let updatedTopic2 = Topic(id: topic2.id, name: "another topic", entries: [-31, 7, -4, 0, 100], unsubmittedValue: -100)
        let sut = makeSUT()
        #expect(storedTopicIDs() == nil)

        try sut.create(topic1)
        try sut.create(topic2)

        let firstLoadedTopics = try sut.load()
        #expect(firstLoadedTopics == [topic1, topic2])

        try sut.update(updatedTopic1)
        try sut.update(updatedTopic2)

        let updatedLoadedTopics = try sut.load()
        #expect(updatedLoadedTopics == [updatedTopic1, updatedTopic2])
    }

    @Test func reorder_updatesIDList() throws {
        let topic1 = Topic(id: UUID(), name: "Topic 1", entries: [2, 1, 4, 6, 3], unsubmittedValue: 1)
        let topic2 = Topic(id: UUID(), name: "Topic 2", entries: [-31, 7, -4, 0], unsubmittedValue: 2)
        let topic3 = Topic(id: UUID(), name: "Topic 3", entries: [31, -7, 4, 1000, 11], unsubmittedValue: 3)
        let sut = makeSUT()
        #expect(storedTopicIDs() == nil)

        try sut.create(topic1)
        try sut.create(topic2)
        try sut.create(topic3)

        let firstLoadedTopics = try sut.load()
        #expect(firstLoadedTopics == [topic1, topic2, topic3])

        let newOrder = [topic3, topic1, topic2]
        try sut.reorder(to: newOrder)

        let updatedLoadedTopics = try sut.load()
        #expect(updatedLoadedTopics == newOrder)
    }

    @Test func reorder_withNonMatchingIDs_throwsError() throws {
        let topic1 = Topic(id: UUID(), name: "Topic 1", entries: [2, 1, 4, 6, 3], unsubmittedValue: 1)
        let topic2 = Topic(id: UUID(), name: "Topic 2", entries: [-31, 7, -4, 0], unsubmittedValue: 2)
        let topic3 = Topic(id: UUID(), name: "Topic 3", entries: [31, -7, 4, 1000, 11], unsubmittedValue: 3)
        let sut = makeSUT()
        #expect(storedTopicIDs() == nil)

        try sut.create(topic1)
        try sut.create(topic2)
        try sut.create(topic3)

        let firstLoadedTopics = try sut.load()
        let originalOrder = [topic1, topic2, topic3]
        #expect(firstLoadedTopics == originalOrder)

        let newOrderWithMissingTopic = [topic3, topic1]
        #expect(throws: UserDefaultsTopicPersistenceService.Error.self) {
            try sut.reorder(to: newOrderWithMissingTopic)
        }

        let secondLoadedTopics = try sut.load()
        #expect(secondLoadedTopics == originalOrder)

        let extraTopic = Topic(id: UUID(), name: "Topic 4", entries: [2], unsubmittedValue: 0)
        let newOrderWithExtraTopic = [topic1, topic3, topic2, extraTopic]

        #expect(throws: UserDefaultsTopicPersistenceService.Error.self) {
            try sut.reorder(to: newOrderWithExtraTopic)
        }

        let thirdLoadedTopics = try sut.load()
        #expect(thirdLoadedTopics == originalOrder)
    }

    @Test func delete_deletesTopic() throws {
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [2, 1, 4, 6, 3], unsubmittedValue: 2)
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-31, 7, -4, 0], unsubmittedValue: -1)
        let sut = makeSUT()
        #expect(storedTopicIDs() == nil)

        try sut.create(topic1)
        try sut.create(topic2)

        let firstLoadedTopics = try sut.load()
        #expect(firstLoadedTopics == [topic1, topic2])

        try sut.delete(topic1)

        let reducedLoadedTopics = try sut.load()
        #expect(reducedLoadedTopics == [topic2])
    }

    @Test func delete_nonExistentTopic_doesNothing() throws {
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [2, 1, 4, 6, 3], unsubmittedValue: 12)
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-31, 7, -4, 0], unsubmittedValue: 21)
        let sut = makeSUT()
        #expect(storedTopicIDs() == nil)

        try sut.create(topic1)

        let firstLoadedTopics = try sut.load()
        #expect(firstLoadedTopics == [topic1])

        try sut.delete(topic2)

        let reducedLoadedTopics = try sut.load()
        #expect(reducedLoadedTopics == [topic1])
    }

    // MARK: - Helpers

    private func makeSUT(suiteName: String = #function) -> UserDefaultsTopicPersistenceService {
        let sut = UserDefaultsTopicPersistenceService(topicIDsKey: testKey, topicKeyForID: topicKey, userDefaults: userDefaults)
        weakSUT = sut
        return sut
    }

    private func topicKey(for id: String) -> String {
        #file + "topic_\(id)"
    }

    private func storedTopicIDs() -> [Any]? {
        userDefaults.array(forKey: testKey)
    }

    private func storedTopic(for id: UUID) -> Any? {
        userDefaults.object(forKey: topicKey(for: id.uuidString))
    }

    private func cleanUp() {
        userDefaults.removePersistentDomain(forName: suiteName)
    }
}
