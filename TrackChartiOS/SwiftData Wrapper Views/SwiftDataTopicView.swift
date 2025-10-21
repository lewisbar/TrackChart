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
    @Bindable var topic: TopicEntity
    @Environment(\.modelContext) var modelContext

    var body: some View {
        TopicView(
            name: $topic.name,
            unsubmittedValue: $topic.unsubmittedValue,
            entries: topic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).map(\.value) ?? [],
            submitNewValue: submitNewValue,
            deleteLastValue: deleteLastValue
        )
    }

    private func submitNewValue(_ value: Double) {
        let newEntry = EntryEntity(value: value, timestamp: .now, sortIndex: topic.entryCount)
        topic.entries?.append(newEntry)
        try? modelContext.save()
    }

    private func deleteLastValue() {
        if !(topic.entries?.isEmpty ?? false) {
            topic.entries = topic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).dropLast()
            try? modelContext.save()
        }
    }
}
