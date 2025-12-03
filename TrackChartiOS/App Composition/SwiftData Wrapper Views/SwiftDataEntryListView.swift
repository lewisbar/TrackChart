//
//  SwiftDataEntryListView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 14.11.25.
//

import SwiftUI
import Persistence
import Presentation

/// Wrapper to decouple the actual View from SwiftData
struct SwiftDataEntryListView: View {
    @Bindable var topic: TopicEntity
    let viewModel: SwiftDataEntryListViewModel

    var body: some View {
        EntryListView(
            topicName: topic.name,
            addEntry: { viewModel.addEntry($0, to: topic) },
            entries: viewModel.viewEntries,
            updateEntry: { viewModel.updateEntry($0, for: topic) },
            deleteEntries: { viewModel.deleteEntries(at: $0, from: topic) }
        )
        .onAppear { viewModel.sync(from: topic) }
        .onChange(of: topic.entryCount) { _, _ in
            viewModel.sync(from: topic)
        }
    }
}
