//
//  TopicListView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI

struct TopicListView: View {
    let topics: [CellTopic]
    let deleteTopics: (IndexSet) -> Void
    let moveTopics: (IndexSet, Int) -> Void
    let showTopic: (CellTopic) -> Void
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
        CellTopic(id: UUID(), name: "Topic 1", entries: [
            .init(value: 2.1, timestamp: .now.advanced(by: -300)),
            .init(value: 4, timestamp: .now.advanced(by: -200)),
            .init(value: 3, timestamp: .now.advanced(by: -100))
        ], aggregator: .sum, treatsMissingAsZero: true, palette: .fire),
        CellTopic(id: UUID(), name: "Topic 2", entries: [
            .init(value: 1, timestamp: .now.advanced(by: -300)),
            .init(value: -4, timestamp: .now.advanced(by: -200)),
            .init(value: 30, timestamp: .now.advanced(by: -100))
        ], aggregator: .sum, treatsMissingAsZero: false, palette: .forest),
        CellTopic(id: UUID(), name: "Topic 3", entries: [
            .init(value: 2, timestamp: .now.advanced(by: -300)),
            .init(value: 40, timestamp: .now.advanced(by: -200)),
            .init(value: -13, timestamp: .now.advanced(by: -100))
        ], aggregator: .sum, treatsMissingAsZero: false, palette: .sunset),
    ]
    
    TopicListView(topics: topics + topics, deleteTopics: { _ in }, moveTopics: { _, _ in }, showTopic: { _ in }, createNewTopic: {})
}
