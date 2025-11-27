//
//  SwiftDataTopicView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 20.10.25.
//

import SwiftUI
import Persistence
import DataProcessing
import Presentation

/// Wrapper to decouple the actual View from SwiftData
struct SwiftDataTopicView<Settings: View>: View {
    @Bindable var topic: TopicEntity
    let settingsView: () -> Settings
    let showEntryList: () -> Void

    var body: some View {
        TopicView(
            topic: TopicViewTopic(
                name: topic.name,
                palette: .palette(named: topic.palette),
                entries: SwiftDataTopicViewModel.entries(for: topic),
                aggregator: .aggregator(named: topic.aggregator),
                treatsMissingAsZero: topic.treatsMissingAsZero
            ),
            submitNewValue: { SwiftDataTopicViewModel.submit(newValue: $0, timestamp: $1, to: topic) },
            settingsView: settingsView,
            showEntryList: showEntryList
        )
    }
}
