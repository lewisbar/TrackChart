//
//  SwiftDataTopicView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 20.10.25.
//

import SwiftUI
import Persistence

/// Wrapper to decouple the actual View from SwiftData
struct SwiftDataTopicView<Settings: View>: View {
    @Bindable var topic: TopicEntity
    let viewModel: SwiftDataTopicViewModel
    let settingsView: () -> Settings

    var body: some View {
        TopicView(
            name: $topic.name,
            palette: paletteBinding,
            entries: viewModel.entries(for: topic),
            submitNewValue: { viewModel.submit(newValue: $0, to: topic) },
            deleteLastValue: { viewModel.deleteLastValue(from: topic)},
            settingsView: settingsView
        )
    }

    private var paletteBinding: Binding<Palette> {
        Binding<Palette>(
            get: { .palette(named: topic.palette) },
            set: { viewModel.changePalette(to: $0, for: topic) }
        )
    }
}
