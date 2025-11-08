//
//  TopicEntity.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 20.10.25.
//

import Foundation
import SwiftData

@Model
public final class TopicEntity {
    @Attribute(.unique) public var id: UUID = UUID()
    public var name: String = ""
    @Relationship(deleteRule: .cascade) public var entries: [EntryEntity]?
    public var palette: String
    public var sortIndex: Int = 0

    public var entryCount: Int {
        entries?.count ?? 0
    }

    public var sortedEntries: [EntryEntity] {
        entries?.sorted(by: { $0.timestamp < $1.timestamp }) ?? []
    }

    public init(id: UUID = UUID(), name: String, entries: [EntryEntity]? = [], palette: String, sortIndex: Int) {
        self.id = id
        self.name = name
        self.entries = entries
        self.palette = palette
        self.sortIndex = sortIndex
    }
}
