//
//  SwiftDataTopicViewModel.swift
//  Persistence
//
//  Created by Lennart Wisbar on 21.10.25.
//

import SwiftData

@MainActor
public class SwiftDataTopicViewModel {
    private let save: () -> Void
    private let debounceSave: (_ delayInSeconds: Double) -> Task<Void, Never>?
    private let debounceSaveDelay: Double

    public init(save: @escaping () -> Void, debounceSave: @escaping (Double) -> Task<Void, Never>?, debounceSaveDelay: Double = 0.5) {
        self.save = save
        self.debounceSave = debounceSave
        self.debounceSaveDelay = debounceSaveDelay
    }

    public func entries(for topic: TopicEntity) -> [Double] {
        topic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).map(\.value) ?? []
    }

    public func submit(newValue: Double, to topic: TopicEntity) {
        let newEntry = EntryEntity(value: newValue, timestamp: .now, sortIndex: topic.entryCount)
        topic.entries?.append(newEntry)
        save()
    }

    public func deleteLastValue(from topic: TopicEntity) {
        if !(topic.entries?.isEmpty ?? false) {
            topic.entries = topic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).dropLast()
            save()
        }
    }

    @discardableResult
    public func nameChanged() -> Task<Void, Never>? {
        debounceSave(debounceSaveDelay)
    }

    @discardableResult
    public func unsubmittedValueChanged() -> Task<Void, Never>? {
        debounceSave(debounceSaveDelay)
    }
}
