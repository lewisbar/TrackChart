//
//  TopicListView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI

struct TopicListView: View {
    let topics: [TopicCellModel]
    let createTopic: (String) -> Void
    let deleteTopic: (TopicCellModel) -> Void
    @State private var isAddTopicViewPresented = false
    @State private var newTopicName = "New Topic"

    init(
        topics: [TopicCellModel],
        createTopic: @escaping (String) -> Void,
        deleteTopic: @escaping (TopicCellModel) -> Void
    ) {
        self.topics = topics
        self.createTopic = createTopic
        self.deleteTopic = deleteTopic
    }

    var body: some View {
        ZStack {
            List(topics) { topic in
                TopicCell(topic: topic)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(
                            role: .destructive,
                            action: { deleteTopic(topic) },
                            label: { Label("Delete", systemImage: "trash") }
                        )
                    }
            }
            CircleButton(
                action: { isAddTopicViewPresented = true },
                image: Image(systemName: "plus"),
                color: .blue
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom)
        }
        .sheet(isPresented: $isAddTopicViewPresented, content: createTopicSheet)
    }

    private func createTopicSheet() -> some View {
        HStack {
            TextField("Enter a name for your topic", text: $newTopicName)
            CircleButton(
                action: {
                    createTopic(newTopicName)
                    isAddTopicViewPresented = false
                },
                image: Image(systemName: "checkmark"),
                color: .green
            )
        }
    }
}

#Preview {
    @Previewable @State var topics = [
        TopicCellModel(id: UUID(), name: "Daily Pages Read", info: "15 entries"),
        TopicCellModel(id: UUID(), name: "Pushups", info: "230 entries"),
        TopicCellModel(id: UUID(), name: "Hours Studied", info: "32 entries")
    ]

    TopicListView(
        topics: topics,
        createTopic: { topics.append(TopicCellModel(id: UUID(), name: $0, info: "0 entries")) },
        deleteTopic: { topic in topics.removeAll(where: { $0.id == topic.id }) }
    )
}
