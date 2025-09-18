//
//  UserDefaultsTopicPersistenceServiceTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Testing
import Foundation
import Persistence

public class UserDefaultsTopicPersistenceService: TopicPersistenceService {
    private struct UserDefaultsTopic: Codable {
        let id: UUID
        let name: String
        let entries: [Int]

        init(from topic: Topic) {
            self.id = topic.id
            self.name = topic.name
            self.entries = topic.entries
        }

        var key: String { Self.key(for: id.uuidString) }

        static func key(for id: String) -> String {
            "topic_\(id)"
        }
    }

    private let userDefaults: UserDefaults
    private let topicIDsKey: String

    public init(topicIDsKey: String, userDefaults: UserDefaults = .standard) {
        self.topicIDsKey = topicIDsKey
        self.userDefaults = userDefaults
    }

    public func create(_ topic: Topic) throws {
        let topic = UserDefaultsTopic(from: topic)
        try save(topic)
        addToIDList(topic.id.uuidString)
    }

    private func save(_ topic: UserDefaultsTopic) throws {
        let data = try JSONEncoder().encode(topic)
        userDefaults.set(data, forKey: topic.key)
    }

    private func addToIDList(_ id: String) {
        let existingIDs = loadTopicIDs()

        if !existingIDs.contains(id) {
            save(existingIDs + [id])
        }
    }

    private func loadTopicIDs() -> [String] {
        userDefaults.array(forKey: topicIDsKey) as? [String] ?? []
    }

    private func save(_ topicIDs: [String]) {
        userDefaults.set(topicIDs, forKey: topicIDsKey)
    }

    public func update(_ topic: Topic) throws {
        try create(topic)
    }

    public func delete(_ topic: Topic) throws {
        let topic = UserDefaultsTopic(from: topic)
        userDefaults.removeObject(forKey: topic.key)
    }

    public func load() throws -> [Topic] {
        try userDefaults
            .array(forKey: topicIDsKey)?
            .compactMap { $0 as? String }
            .compactMap { userDefaults.data(forKey: UserDefaultsTopic.key(for: $0)) }
            .compactMap { try JSONDecoder().decode(UserDefaultsTopic.self, from: $0) }
            .map { Topic(id: $0.id, name: $0.name, entries: $0.entries) } ?? []
    }
}

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
        let topic = Topic(id: id, name: "a topic", entries: [2, 1, 4, 6, 3])
        let sut = makeSUT()
        #expect(storedTopicIDs() == nil)

        try sut.create(topic)

        #expect(storedTopicIDs()?.count == 1)
        #expect(storedTopic(for: id) != nil)
    }

    @Test func create_whenIDAlreadyExists_overwrites() throws {
        let id = UUID()
        let firstTopic = Topic(id: id, name: "a topic", entries: [2, 1, 4, 6, 3])
        let topicWithSameID = Topic(id: id, name: "another topic", entries: [-2, -3, -50])
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
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [2, 1, 4, 6, 3])
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-31, 7, -4, 0])
        let sut = makeSUT()
        #expect(storedTopicIDs() == nil)

        try sut.create(topic1)
        try sut.create(topic2)

        let loadedTopics = try sut.load()
        #expect(loadedTopics == [topic1, topic2])
    }

    @Test func update_whenTopicDoesNotExist_creates() throws {
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [2, 1, 4, 6, 3])
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-31, 7, -4, 0])
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
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [2, 1, 4, 6, 3])
        let updatedTopic1 = Topic(id: topic1.id, name: "an updated topic", entries: [2, 1, 4, 6, 3])
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-31, 7, -4, 0])
        let updatedTopic2 = Topic(id: topic2.id, name: "another topic", entries: [-31, 7, -4, 0, 100])
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

    @Test func delete_deletesTopic() throws {
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [2, 1, 4, 6, 3])
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-31, 7, -4, 0])
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
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [2, 1, 4, 6, 3])
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-31, 7, -4, 0])
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
        let sut = UserDefaultsTopicPersistenceService(topicIDsKey: testKey, userDefaults: userDefaults)
        weakSUT = sut
        return sut
    }

    private func storedTopicIDs() -> [Any]? {
        userDefaults.array(forKey: testKey)
    }

    private func storedTopic(for id: UUID) -> Any? {
        userDefaults.object(forKey: "topic_\(id)")
    }

    private func cleanUp() {
        userDefaults.removePersistentDomain(forName: suiteName)
    }
}
