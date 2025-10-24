//
//  CellTopic.swift
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Foundation
import Domain

public struct CellTopic: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let info: String
    public let entries: [ChartEntry]

    public init(id: UUID, name: String, info: String, entries: [ChartEntry]) {
        self.id = id
        self.name = name
        self.info = info
        self.entries = entries
    }

    public init(from topic: Topic) {
        let infoPostfix = topic.entries.count == 1 ? "entry" : "entries"

        self.id = topic.id
        self.name = topic.name
        self.info = "\(topic.entries.count) \(infoPostfix)"
        self.entries = topic.entries.map(ChartEntry.init)
    }
}

public struct ChartEntry: Hashable, Codable {
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
