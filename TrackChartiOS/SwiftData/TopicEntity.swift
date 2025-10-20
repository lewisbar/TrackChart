//
//  TopicEntity.swift
//
//  Created by Lennart Wisbar on 17.10.25.
//

import Foundation
import SwiftData
import Domain

@Model
final class TopicEntity {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    @Relationship(deleteRule: .cascade) var entries: [EntryEntity]?
    var unsubmittedValue: Double = 0
    var sortIndex: Int = 0

    var entryCount: Int {
        entries?.count ?? 0
    }

    init(id: UUID = UUID(), name: String, entries: [EntryEntity]? = nil, unsubmittedValue: Double, sortIndex: Int) {
        self.id = id
        self.name = name
        self.entries = entries
        self.unsubmittedValue = unsubmittedValue
        self.sortIndex = sortIndex
    }

    var topic: Topic {
        Topic(
            id: id,
            name: name,
            entries: entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).map(\.entry) ?? [],
            unsubmittedValue: unsubmittedValue
        )
    }
}
