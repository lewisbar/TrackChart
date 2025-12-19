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
    public var id: UUID = UUID()
    public var name: String = ""
    public var details: String = ""
    @Relationship(deleteRule: .cascade, inverse: \EntryEntity.topic) public var entries: [EntryEntity]?
    public var palette: String = "Ocean"
    public var aggregator: String = "Sum"
    public var treatsMissingAsZero: Bool = false
    public var sortIndex: Int = 0

    public var entryCount: Int {
        entries?.count ?? 0
    }

    public var sortedEntries: [EntryEntity] {
        entries?.sorted(by: { $0.timestamp < $1.timestamp }) ?? []
    }

    public init(
        id: UUID = UUID(),
        name: String,
        details: String = "",
        entries: [EntryEntity]? = [],
        palette: String,
        aggregator: String = "Sum",
        treatsMissingAsZero: Bool = false,
        sortIndex: Int
    ) {
        self.id = id
        self.name = name
        self.details = details
        self.entries = entries
        self.palette = palette
        self.aggregator = aggregator
        self.treatsMissingAsZero = treatsMissingAsZero
        self.sortIndex = sortIndex
    }

    public func submit(id: UUID, newValue: Double, timestamp: Date) {
        let newEntry = EntryEntity(id: id, value: newValue, timestamp: timestamp)
        entries?.append(newEntry)
    }

    public func updateEntry(withID id: UUID, value: Double, timestamp: Date) {
        let entry = entries?.first(where: { $0.id == id })
        entry?.value = value
        entry?.timestamp = timestamp
    }

    public func deleteEntries(atOffsets offsets: IndexSet, order: SortOrder) {
        let ids = (order == .forward ? sortedEntries : sortedEntries.reversed()).map(\.id)
        let idsToDelete = offsets.filter { $0 < ids.count }.map { ids[$0] }
        for id in idsToDelete {
            entries?.removeAll(where: { $0.id == id })
        }
    }
}
