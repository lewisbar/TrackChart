//
//  TopicListView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI

struct TopicListView: View {
    @Binding var topics: [TopicCellModel]
    let startTopicCreation: () -> Void

    var body: some View {
        ZStack {
            list(of: topics)
            plusButton
        }
    }

    private func list(of topics: [TopicCellModel]) -> some View {
        List($topics, editActions: .all) { $topic in
            TopicCell(topic: topic)
        }
    }

    private var plusButton: some View {
        CircleButton(
            action: startTopicCreation,
            image: Image(systemName: "plus"),
            color: .blue
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom)
    }
}

#Preview {
    @Previewable @State var topics = [
        TopicCellModel(id: UUID(), name: "Daily Pages Read", info: "15 entries"),
        TopicCellModel(id: UUID(), name: "Pushups", info: "230 entries"),
        TopicCellModel(id: UUID(), name: "Hours Studied", info: "32 entries")
    ]

    TopicListView(
        topics: $topics,
        startTopicCreation: { topics.append(TopicCellModel(id: UUID(), name: "New Topic", info: "0 entries")) }
    )
}
