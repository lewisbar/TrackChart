//
//  TopicEntity.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 20.10.25.
//

import Foundation
import SwiftData
import Domain

@Model
public final class TopicEntity {
    @Attribute(.unique) public var id: UUID = UUID()
    public var name: String = ""
    @Relationship(deleteRule: .cascade) public var entries: [EntryEntity]?
    public var sortIndex: Int = 0

    public var entryCount: Int {
        entries?.count ?? 0
    }

    public init(id: UUID = UUID(), name: String, entries: [EntryEntity]? = nil, sortIndex: Int) {
        self.id = id
        self.name = name
        self.entries = entries
        self.sortIndex = sortIndex
    }

    public var topic: Topic {
        Topic(
            id: id,
            name: name,
            entries: entries?.sorted(by: { $0.timestamp < $1.timestamp }).map(\.entry) ?? []
        )
    }
}
