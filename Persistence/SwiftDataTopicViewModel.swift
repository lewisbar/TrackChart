//
//  SwiftDataTopicViewModel.swift
//  Persistence
//
//  Created by Lennart Wisbar on 21.10.25.
//

import SwiftData

@MainActor
public class SwiftDataTopicViewModel {
    private let secondsToWaitBeforeSaving: Double
    private var saveTask: Task<Void, Never>?

    public init(secondsToWaitBeforeSaving: Double = 0.5) {
        self.secondsToWaitBeforeSaving = secondsToWaitBeforeSaving
    }

    public func entries(for topic: TopicEntity) -> [Double] {
        topic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).map(\.value) ?? []
    }

    public func submit(newValue: Double, to topic: TopicEntity, in modelContext: ModelContext) {
        let newEntry = EntryEntity(value: newValue, timestamp: .now, sortIndex: topic.entryCount)
        topic.entries?.append(newEntry)
        try? modelContext.save()
    }

    public func deleteLastValue(from topic: TopicEntity, in modelContext: ModelContext) {
        if !(topic.entries?.isEmpty ?? false) {
            topic.entries = topic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).dropLast()
            try? modelContext.save()
        }
    }

    public func debounceSave(in modelContext: ModelContext) {
        guard modelContext.hasChanges else { return }
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(secondsToWaitBeforeSaving * 1_000_000_000))
            guard modelContext.hasChanges else { return }
            try? modelContext.save()
        }
    }
}
