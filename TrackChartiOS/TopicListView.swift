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
        TopicCellModel(id: UUID(), name: "Daily Pages Read", info: "15 entries", entries: [1, 2, 4, 8, 1]),
        TopicCellModel(id: UUID(), name: "Pushups", info: "230 entries", entries: [4, 5, 2, -4, -5, -2, 9, 7, 4, 0]),
        TopicCellModel(id: UUID(), name: "Hours Studied", info: "0 entries", entries: [])
    ]

    TopicListViewContent(topics: $topics, showTopic: { _ in }, createTopic: {})
}
