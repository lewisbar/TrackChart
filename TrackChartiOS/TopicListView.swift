//
//  TopicListView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI
import Presentation

struct TopicListView: View {
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
                .card()
                .listRowSeparator(.hidden)
                .frame(maxHeight: 150)
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
        TopicCellModel(id: UUID(), name: "Daily Pages Read", info: "15 entries"),
        TopicCellModel(id: UUID(), name: "Pushups", info: "230 entries"),
        TopicCellModel(id: UUID(), name: "Hours Studied", info: "32 entries")
    ]

    TopicListView(topics: $topics, showTopic: { _ in }, createTopic: {})
}
