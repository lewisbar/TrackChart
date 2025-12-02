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
            addEntry: { new in
                topic.submit(newValue: new.value, timestamp: new.timestamp)
                syncFromModel()
            },
            entries: viewEntries,
            updateEntry: { updated in
                topic.updateEntry(withID: updated.id, value: updated.value, timestamp: updated.timestamp)
                syncFromModel()
            },
            deleteEntries: { offsets in
                topic.deleteEntries(atOffsets: offsets, order: .reverse)
                syncFromModel()
            }
        )
        .onAppear(perform: syncFromModel)
        .onChange(of: topic.entryCount) { _, _ in
            syncFromModel()
        }
    }

    private func syncFromModel() {
        viewEntries = topic.viewEntries.reversed()
    }
}
