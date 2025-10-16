//
//  NavigationTopic.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 23.09.25.
//

import Foundation

public struct NavigationTopic: Hashable, Codable {
    public let id: UUID
    public let name: String
    public let entries: [NavigationEntry]
    public let unsubmittedValue: Double

    public init(id: UUID, name: String, entries: [NavigationEntry], unsubmittedValue: Double) {
        self.id = id
        self.name = name
        self.entries = entries
        self.unsubmittedValue = unsubmittedValue
    }

    public init(from topic: Topic) {
        self.id = topic.id
        self.name = topic.name
        self.entries = topic.entries.map(NavigationEntry.init)
        self.unsubmittedValue = topic.unsubmittedValue
    }

    public var topic: Topic {
        Topic(id: id, name: name, entries: entries.map(\.entry), unsubmittedValue: unsubmittedValue)
    }
}

public struct NavigationEntry: Hashable, Codable {
    public let value: Double
    public let timestamp: Date

    public init(value: Double, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
    }

    public init(from entry: Entry) {
        self.value = entry.value
        self.timestamp = entry.timestamp
    }

    public var entry: Entry {
        Entry(value: value, timestamp: timestamp)
    }
}
