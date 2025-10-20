//
//  SwiftDataTopicView.swift
//  TrackChartiOS
//
//  Created by LennartWisbar on 20.10.25.
//

import SwiftUI

struct SwiftDataTopicView: View {
    @Bindable var topic: Topic

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
        let newEntry = Entry(value: value, timestamp: .now, sortIndex: topic.entryCount)
        topic.entries?.append(newEntry)
    }

    private func deleteLastValue() {
        if !(topic.entries?.isEmpty ?? false) {
            topic.entries = topic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).dropLast()
        }
    }
}
