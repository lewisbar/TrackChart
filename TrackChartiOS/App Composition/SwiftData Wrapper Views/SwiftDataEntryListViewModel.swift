//
//  SwiftDataEntryListViewModel.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 14.11.25.
//

import Persistence

class SwiftDataEntryListViewModel {
    func listEntries(for topic: TopicEntity) -> [ListEntry] {
        topic.sortedEntries.reversed().map(ListEntry.init)
    }

    func updateEntry(_ listEntry: ListEntry, of topic: TopicEntity) {
        let entryEntity = topic.entries?.first(where: { $0.id == listEntry.id })
        entryEntity?.value = listEntry.value
        entryEntity?.timestamp = listEntry.timestamp
    }

    func deleteEntries(atOffsets offsets: IndexSet, from topic: TopicEntity) {
        let ids = topic.sortedEntries.reversed().map(\.id)
        let idsToDelete = offsets.map { ids[$0] }
        for id in idsToDelete {
            topic.entries?.removeAll(where: { $0.id == id })
        }
    }
}

private extension ListEntry {
    init(from entryEntity: EntryEntity) {
        self = ListEntry(id: entryEntity.id, value: entryEntity.value, timestamp: entryEntity.timestamp)
    }
}
