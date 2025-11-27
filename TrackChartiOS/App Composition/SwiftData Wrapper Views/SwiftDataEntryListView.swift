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
            addEntry: { SwiftDataEntryListViewModel.addEntry($0, to: topic) },
            entries: SwiftDataEntryListViewModel.listEntries(for: topic),
            updateEntry: { SwiftDataEntryListViewModel.updateEntry($0, of: topic) },
            deleteEntries: { SwiftDataEntryListViewModel.deleteEntries(atOffsets: $0, from: topic) }
        )
    }
}
