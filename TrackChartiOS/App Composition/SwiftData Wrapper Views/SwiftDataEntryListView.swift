//
//  SwiftDataEntryListView.swift
//  TrackChartiOS
//
//  Created by LennartWisbar on 14.11.25.
//

import SwiftUI
import Persistence
import Presentation

struct SwiftDataEntryListView: View {
    @Bindable var topic: TopicEntity

    var body: some View {
        EntryListView(
            topicName: topic.name,
            addEntry: { topic.submit(newValue: $0.value, timestamp: $0.timestamp) },
            entries: topic.viewEntries.reversed(),
            updateEntry: { topic.updateEntry(withID: $0.id, value: $0.value, timestamp: $0.timestamp) },
            deleteEntries: { topic.deleteEntries(atOffsets: $0, order: .reverse) }
        )
    }
}
