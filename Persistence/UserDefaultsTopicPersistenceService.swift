//
//  UserDefaultsTopicPersistenceService.swift
//  Persistence
//
//  Created by Lennart Wisbar on 19.09.25.
//

import Domain

public class UserDefaultsTopicPersistenceService: TopicPersistenceService {
    private struct UserDefaultsTopic: Codable {
        let id: UUID
        let name: String
        let entries: [Int]
        let unsubmittedValue: Int

        init(from topic: Topic) {
            self.id = topic.id
            self.name = topic.name
            self.entries = topic.entries
            self.unsubmittedValue = topic.unsubmittedValue
        }
    }

    private let userDefaults: UserDefaults
    private let topicIDsKey: String
    private let topicKeyForID: (String) -> String

    public init(
        topicIDsKey: String = "com.trackchart.topics.idlist",
        topicKeyForID: @escaping (String) -> String = { "com.trackchart.topics.topic_\($0)" },
        userDefaults: UserDefaults = .standard
    ) {
        self.topicIDsKey = topicIDsKey
        self.topicKeyForID = topicKeyForID
        self.userDefaults = userDefaults
    }

    public func create(_ topic: Topic) throws {
        let topic = UserDefaultsTopic(from: topic)
        try save(topic)
        addToIDList(topic.id.uuidString)
    }

    private func save(_ topic: UserDefaultsTopic) throws {
        let data = try JSONEncoder().encode(topic)
        userDefaults.set(data, forKey: key(for: topic))
    }

    private func key(for topic: UserDefaultsTopic) -> String {
        topicKeyForID(topic.id.uuidString)
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

    public func reorder(to newOrder: [Topic]) throws {
        let reorderedIDs = newOrder.map(\.id.uuidString)
        userDefaults.set(reorderedIDs, forKey: topicIDsKey)
    }

    public func delete(_ topic: Topic) throws {
        let topic = UserDefaultsTopic(from: topic)
        userDefaults.removeObject(forKey: key(for: topic))
    }

    public func load() throws -> [Topic] {
        try userDefaults
            .array(forKey: topicIDsKey)?
            .compactMap { $0 as? String }
            .compactMap { userDefaults.data(forKey: topicKeyForID($0)) }
            .compactMap { try JSONDecoder().decode(UserDefaultsTopic.self, from: $0) }
            .map { Topic(id: $0.id, name: $0.name, entries: $0.entries, unsubmittedValue: $0.unsubmittedValue) } ?? []
    }
}
