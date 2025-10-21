//
//  SwiftDataTopicView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 20.10.25.
//

import SwiftUI
import Persistence

/// Wrapper to decouple the actual View from SwiftData
struct SwiftDataTopicView: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var topic: TopicEntity
    let viewModel: SwiftDataTopicViewModel

    var body: some View {
        TopicView(
            name: $topic.name,
            unsubmittedValue: $topic.unsubmittedValue,
            entries: viewModel.entries(for: topic),
            submitNewValue: { viewModel.submit(newValue: $0, to: topic, in: modelContext) },
            deleteLastValue: { viewModel.deleteLastValue(from: topic, in: modelContext)}
        )
    }
}
