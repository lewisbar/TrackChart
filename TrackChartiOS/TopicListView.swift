//
//  TopicListView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI
import Presentation

struct TopicListView: View {
    @Bindable var model: TopicListViewModel
    let showTopic: (UUID) -> Void
    let createTopic: () -> Void

    var body: some View {
        TopicListViewContent(topics: $model.topics, showTopic: showTopic, createTopic: createTopic)
    }
}

private struct TopicListViewContent: View {
    @Binding var topics: [TopicCellModel]
    let showTopic: (UUID) -> Void
    let createTopic: () -> Void

    var body: some View {
        ZStack {
            list(of: topics)
            plusButton
        }
    }

    private func list(of topics: [TopicCellModel]) -> some View {
        List($topics, editActions: .all) { $topic in
            TopicCell(topic: topic, showTopic: showTopic)
                .listRowSeparator(.hidden)
        }
    }

    private var plusButton: some View {
        VStack {
            Spacer()
            CircleButton(action: createTopic, image: Image(systemName: "plus"), color: .blue)
                .padding(.bottom)
        }
    }
}

#Preview {
    @Previewable @State var topics = [
        TopicCellModel(
            id: UUID(),
            name: "Daily Pages Read",
            info: "7 entries",
            entries: [1, 2, 4, 8, 16, -1, -2].map { TopicCellEntry(value: $0, timestamp: Date()) }
        ),

        TopicCellModel(
            id: UUID(),
            name: "Daily Pages Read",
            info: "7 entries",
            entries: [].map { TopicCellEntry(value: $0, timestamp: Date()) }
        ),

        TopicCellModel(
            id: UUID(),
            name: "Daily Pages Read",
            info: "7 entries",
            entries: [1].map { TopicCellEntry(value: $0, timestamp: Date()) }
        )
    ]

    TopicListViewContent(topics: $topics, showTopic: { _ in }, createTopic: {})
}
