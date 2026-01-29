//
//  TopicListView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI
import Presentation

struct TopicListView: View {
    let topics: [ViewTopic]
    let deleteTopics: (IndexSet) -> Void
    let moveTopics: (IndexSet, Int) -> Void
    let showTopic: (ViewTopic) -> Void
    let createNewTopic: () -> Void

    var body: some View {
        ZStack {
            list
            plusButton
        }
    }

    private var list: some View {
        List {
            if topics.isEmpty { addTopicHint }

            ForEach(topics) { topic in
                TopicCell(topic: topic, showTopic: { showTopic(topic) })
                    .listRowSeparator(.hidden)
            }
            .onDelete(perform: deleteTopics)
            .onMove(perform: moveTopics)
        }
        .padding(.top, -16)
        .safeAreaInset(edge: .bottom) {
            // Make room for the plus button
            Color.clear.frame(height: 36)
        }
    }

    private var plusButton: some View {
        VStack {
            Spacer()
            CircleButton(action: createNewTopic, image: Image(systemName: "plus"), color: .blue)
                .padding(.bottom)
        }
        .accessibilityHint(.addANewTopic)
    }

    private var addTopicHint: some View {
        Text(tutorial)
            .foregroundColor(.secondary)
            .padding()
            .listRowSeparator(.hidden)
    }

    private let tutorial = String(localized: .tapPlusButtonToAddTopic)
}

#Preview {
    let topics = [
        ViewTopic(id: UUID(), name: "Topic 1", details: "Some details", entries: [
            ViewEntry(id: UUID(), value: 2.1, timestamp: .now.advanced(by: -300)),
            ViewEntry(id: UUID(), value: 4, timestamp: .now.advanced(by: -200)),
            ViewEntry(id: UUID(), value: 3, timestamp: .now.advanced(by: -100))
        ], aggregator: .sum, treatsMissingAsZero: true, sum: 200, average: 12, highest: 120, lowest: -10, palette: .fire),
        ViewTopic(id: UUID(), name: "Topic 2", details: "Some details", entries: [
            ViewEntry(id: UUID(), value: 1, timestamp: .now.advanced(by: -300)),
            ViewEntry(id: UUID(), value: -4, timestamp: .now.advanced(by: -200)),
            ViewEntry(id: UUID(), value: 30, timestamp: .now.advanced(by: -100))
        ], aggregator: .sum, treatsMissingAsZero: false, sum: 200, average: 12, highest: 120, lowest: -10, palette: .forest),
        ViewTopic(id: UUID(), name: "Topic 3", details: "Some details", entries: [
            ViewEntry(id: UUID(), value: 2, timestamp: .now.advanced(by: -300)),
            ViewEntry(id: UUID(), value: 40, timestamp: .now.advanced(by: -200)),
            ViewEntry(id: UUID(), value: -13, timestamp: .now.advanced(by: -100))
        ], aggregator: .sum, treatsMissingAsZero: false, sum: 200, average: 12, highest: 120, lowest: -10, palette: .sunset),
    ]
    
    TopicListView(topics: topics + topics, deleteTopics: { _ in }, moveTopics: { _, _ in }, showTopic: { _ in }, createNewTopic: {})
}
