//
//  SwiftDataEntryListViewModel.swift
//  Presentation
//
//  Created by Lennart Wisbar on 03.12.25.
//

import Foundation
import Persistence

@Observable
public class SwiftDataEntryListViewModel {
    public var viewEntries: [ViewEntry] = []

    public init() {}

    public func addEntry(_ newEntry: ViewEntry, to topic: TopicEntity) {
        topic.submit(id: newEntry.id, newValue: newEntry.value, timestamp: newEntry.timestamp)
        sync(from: topic)
    }

    public func updateEntry(_ updatedEntry: ViewEntry, for topic: TopicEntity) {
        topic.updateEntry(withID: updatedEntry.id, value: updatedEntry.value, timestamp: updatedEntry.timestamp)
        sync(from: topic)
    }

    public func deleteEntries(at offsets: IndexSet, from topic: TopicEntity) {
        topic.deleteEntries(atOffsets: offsets, order: .reverse)
        sync(from: topic)
    }

    public func sync(from topic: TopicEntity) {
        viewEntries = topic.viewEntries.reversed()
    }
}
