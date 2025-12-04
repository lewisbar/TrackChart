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
    let settingsView: () -> Settings
    let showEntryList: () -> Void

    var body: some View {
        TopicView(
            topic: topic.viewTopic,
            submitNewValue: { topic.submit(id: UUID(), newValue: $0, timestamp: $1) },
            settingsView: settingsView,
            showEntryList: showEntryList
        )
    }
}
