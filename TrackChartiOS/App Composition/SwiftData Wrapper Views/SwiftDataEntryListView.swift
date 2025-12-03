//
//  SwiftDataEntryListView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 14.11.25.
//

import SwiftUI
import Persistence
import Presentation

struct SwiftDataEntryListView: View {
    @Bindable var topic: TopicEntity
    @State private var viewEntries: [ViewEntry] = []

    var body: some View {
        EntryListView(
            topicName: topic.name,
            addEntry: addEntry,
            entries: viewEntries,
            updateEntry: updateEntry,
            deleteEntries: deleteEntries
        )
        .onAppear(perform: syncFromModel)
        .onChange(of: topic.entryCount) { _, _ in
            syncFromModel()
        }
    }

    private func addEntry(_ newEntry: ViewEntry) {
        topic.submit(newValue: newEntry.value, timestamp: newEntry.timestamp)
        syncFromModel()
    }

    private func updateEntry(_ updatedEntry: ViewEntry) {
        topic.updateEntry(withID: updatedEntry.id, value: updatedEntry.value, timestamp: updatedEntry.timestamp)
        syncFromModel()
    }

    private func deleteEntries(at offsets: IndexSet) {
        topic.deleteEntries(atOffsets: offsets, order: .reverse)
        syncFromModel()
    }

    private func syncFromModel() {
        viewEntries = topic.viewEntries.reversed()
    }
}
