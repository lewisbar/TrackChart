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
        let needsMigration: Bool

        init(from topic: Topic) {
            self.id = topic.id
            self.name = topic.name
            self.entries = topic.entries
            self.unsubmittedValue = topic.unsubmittedValue
            self.needsMigration = false
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            entries = try container.decode([Int].self, forKey: .entries)

            // Check if data is stored in the old version without unsubmittedValue
            if let currentValue = try container.decodeIfPresent(Int.self, forKey: .unsubmittedValue) {
                unsubmittedValue = currentValue
                needsMigration = false
            } else {
                unsubmittedValue = 0
                needsMigration = true
            }
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case entries
            case unsubmittedValue
            // needsMigration is not encoded/decoded, it’s only used at runtime
        }
    }

    public enum Error: Swift.Error, LocalizedError {
        case nonMatchingIDs([String])

        public var errorDescription: String? {
            if case let .nonMatchingIDs(ids) = self {
                return "Reordering failed because of non-matching IDs. Keeping old order.\n\nNon-matching IDs (\(ids.count)): \(ids)."
            }
            return nil
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
        let existingIDs = loadTopicIDs()
        try makeSure(thatNewIDs: reorderedIDs, matchOldIDs: existingIDs)
        userDefaults.set(reorderedIDs, forKey: topicIDsKey)
    }

    private func makeSure(thatNewIDs newIDs: [String], matchOldIDs oldIDs: [String]) throws {
        let nonMatchingIDs = Set(newIDs).symmetricDifference(Set(oldIDs))
        if !nonMatchingIDs.isEmpty { throw Error.nonMatchingIDs(Array(nonMatchingIDs)) }
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
            .map { topic -> UserDefaultsTopic in
                // Store data that came in old format back in new format
                if topic.needsMigration, let encodedData = try? JSONEncoder().encode(topic) {
                    userDefaults.set(encodedData, forKey: topicKeyForID(topic.id.uuidString))
                }
                return topic
            }
            .map { Topic(id: $0.id, name: $0.name, entries: $0.entries, unsubmittedValue: $0.unsubmittedValue) } ?? []
    }
}
