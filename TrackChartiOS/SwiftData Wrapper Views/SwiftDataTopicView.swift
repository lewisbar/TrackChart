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
            palette: paletteBinding,
            entries: viewModel.entries(for: topic),
            submitNewValue: { viewModel.submit(newValue: $0, to: topic) },
            deleteLastValue: { viewModel.deleteLastValue(from: topic)}
        )
        .onChange(of: topic.name) { _, _ in viewModel.nameChanged() }
    }

    private var paletteBinding: Binding<Palette> {
        Binding<Palette>(
            get: { .palette(named: topic.palette) },
            set: { viewModel.changePalette(to: $0, for: topic) }
        )
    }
}
