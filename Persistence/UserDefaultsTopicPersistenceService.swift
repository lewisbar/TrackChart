//
//  UserDefaultsTopicPersistenceService.swift
//  Persistence
//
//  Created by Lennart Wisbar on 19.09.25.
//

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
