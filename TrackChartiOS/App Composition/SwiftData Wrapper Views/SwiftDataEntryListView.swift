//
//  SwiftDataEntryListView.swift
//  TrackChartiOS
//
//  Created by LennartWisbar on 14.11.25.
//

import SwiftUI
import Persistence

struct SwiftDataEntryListView: View {
    @Bindable var topic: TopicEntity
    let viewModel: SwiftDataEntryListViewModel

    var body: some View {
        EntryListView(
            topicName: topic.name,
            entries: viewModel.listEntries(for: topic),
            updateEntry: { viewModel.updateEntry($0, of: topic) },
            deleteEntries: { viewModel.deleteEntries(atOffsets: $0, from: topic) }
        )
    }
}
