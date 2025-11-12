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
            ForEach(topics) { topic in
                TopicCell(topic: topic, showTopic: { showTopic(topic) })
                    .listRowSeparator(.hidden)
            }
            .onDelete(perform: deleteTopics)
            .onMove(perform: moveTopics)
            Spacer()
        }
    }

    private var plusButton: some View {
        VStack {
            Spacer()
            CircleButton(action: createNewTopic, image: Image(systemName: "plus"), color: .blue)
                .padding(.bottom)
        }
        .accessibilityHint("Add a new topic")
    }
}

#Preview {
    let topics = [
        CellTopic(id: UUID(), name: "Topic 1", entries: [
            .init(value: 2.1, timestamp: .now),
            .init(value: 4, timestamp: .now),
            .init(value: 3, timestamp: .now)
        ], palette: .fire),
        CellTopic(id: UUID(), name: "Topic 2", entries: [
            .init(value: 1, timestamp: .now),
            .init(value: -4, timestamp: .now),
            .init(value: 30, timestamp: .now)
        ], palette: .forest),
        CellTopic(id: UUID(), name: "Topic 3", entries: [
            .init(value: 2, timestamp: .now),
            .init(value: 40, timestamp: .now),
            .init(value: -13, timestamp: .now)
        ], palette: .sunset),
    ]
    
    TopicListView(topics: topics, deleteTopics: { _ in }, moveTopics: { _, _ in }, showTopic: { _ in }, createNewTopic: {})
}
