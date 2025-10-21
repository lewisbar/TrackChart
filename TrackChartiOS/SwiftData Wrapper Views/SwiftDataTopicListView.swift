//
//  SwiftDataTopicListView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 20.10.25.
//

import SwiftUI
import SwiftData
import Persistence

/// Wrapper to decouple the actual View from SwiftData
struct SwiftDataTopicListView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \TopicEntity.sortIndex) var topics: [TopicEntity]
    let viewModel: SwiftDataTopicListViewModel

    var body: some View {
        TopicListView(
            topics: viewModel.cellModels(from: topics),
            deleteTopics: { viewModel.deleteTopics(at: $0, from: topics, in: modelContext) },
            moveTopics: { viewModel.moveTopics(from: $0, to: $1, inTopicList: topics, modelContext: modelContext) },
            showTopic: { viewModel.showTopic(for: $0, in: topics) },
            createNewTopic: { viewModel.addAndShowNewTopic(existingTopics: topics, in: modelContext) }
        )
    }
}
