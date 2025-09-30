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
    public let entries: [Int]

    public init(id: UUID, name: String, entries: [Int]) {
        self.id = id
        self.name = name
        self.entries = entries
    }

    public init(from topic: Topic) {
        self.id = topic.id
        self.name = topic.name
        self.entries = topic.entries
    }

    public var topic: Topic {
        Topic(id: id, name: name, entries: entries)
    }
}
