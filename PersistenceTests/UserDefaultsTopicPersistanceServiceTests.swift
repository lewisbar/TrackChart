//
//  UserDefaultsTopicPersistanceServiceTests.swift
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
    }

    private let userDefaults: UserDefaults
    private let topicIDsKey: String

    public init(topicIDsKey: String, userDefaults: UserDefaults = .standard) {
        self.topicIDsKey = topicIDsKey
        self.userDefaults = userDefaults
    }

    public func create(_ topic: Topic) throws {
        let topic = UserDefaultsTopic(from: topic)
        let encoder = JSONEncoder()
        let data = try encoder.encode(topic)
        userDefaults.set(data, forKey: "topic_\(topic.id)")

        // Fetch or initialize the array of topic IDs
        var topicIds = userDefaults.array(forKey: topicIDsKey) as? [String] ?? []

        // Append the new ID if not already present
        let idString = topic.id.uuidString
        if !topicIds.contains(idString) {
            topicIds.append(idString)
            userDefaults.set(topicIds, forKey: topicIDsKey)
        }
    }

    public func update(_ topic: Topic) throws {

    }

    public func delete(_ topic: Topic) throws {

    }

    public func load() throws -> [Topic] {
        guard let rawIDs = userDefaults.array(forKey: topicIDsKey) else { return [] }
        let uuidStrings = rawIDs.compactMap { $0 as? String }
        let rawTopics = uuidStrings.compactMap { userDefaults.data(forKey: "topic_\($0)") }
        let userDefaultsTopics = try rawTopics.compactMap {
            try JSONDecoder().decode(UserDefaultsTopic.self, from: $0)
        }
        let topics = userDefaultsTopics.map { Topic(id: $0.id, name: $0.name, entries: $0.entries)}
        return topics
    }

    private func updateTopicIDs() {
        
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
