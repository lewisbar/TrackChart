//
//  SwiftDataTopicView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 20.10.25.
//

import SwiftUI
import Persistence
import DataProcessing

/// Wrapper to decouple the actual View from SwiftData
struct SwiftDataTopicView<Settings: View>: View {
    @Bindable var topic: TopicEntity
    let viewModel: SwiftDataTopicViewModel
    let settingsView: () -> Settings
    let showEntryList: () -> Void

    var body: some View {
        TopicView(
            name: $topic.name,
            palette: paletteBinding,
            aggregator: aggregatorBinding,
            entries: viewModel.entries(for: topic),
            submitNewValue: { viewModel.submit(newValue: $0, timestamp: $1, to: topic) },
            settingsView: settingsView,
            showEntryList: showEntryList
        )
    }

    private var paletteBinding: Binding<Palette> {
        Binding<Palette>(
            get: { .palette(named: topic.palette) },
            set: { viewModel.changePalette(to: $0, for: topic) }
        )
    }

    private var aggregatorBinding: Binding<Aggregator> {
        Binding<Aggregator>(
            get: { .aggregator(named: topic.aggregator) },
            set: { viewModel.changeAggregator(to: $0, for: topic) }
        )
    }
}
