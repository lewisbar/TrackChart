//
//  SwiftDataTopicViewModel.swift
//  Persistence
//
//  Created by Lennart Wisbar on 21.10.25.
//

import SwiftData

public class SwiftDataTopicViewModel {
    public init() {}

    public func entries(for topic: TopicEntity) -> [Double] {
        topic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).map(\.value) ?? []
    }

    public func submit(newValue: Double, to topic: TopicEntity, in modelContext: ModelContext) {
        let newEntry = EntryEntity(value: newValue, timestamp: .now, sortIndex: topic.entryCount)
        topic.entries?.append(newEntry)
        try? modelContext.save()
    }

    public func deleteLastValue(from topic: TopicEntity, in modelContext: ModelContext) {
        topic.entries = topic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).dropLast()
        try? modelContext.save()
    }
}
