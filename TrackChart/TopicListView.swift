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
            list(of: topics)
            plusButton
        }
        .sheet(isPresented: $isAddTopicViewPresented, content: newTopicSheet)
    }

    private func list(of topics: [TopicCellModel]) -> some View {
        List(topics) { topic in
            TopicCell(topic: topic)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) { deleteButton(for: topic) }
        }
    }

    private func deleteButton(for topic: TopicCellModel) -> some View {
        Button(
            role: .destructive,
            action: { deleteTopic(topic) },
            label: { Label("Delete", systemImage: "trash") }
        )
    }

    private var plusButton: some View {
        CircleButton(
            action: { isAddTopicViewPresented = true },
            image: Image(systemName: "plus"),
            color: .blue
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom)
    }

    private func newTopicSheet() -> some View {
        HStack {
            TextField("Enter a name for your topic", text: $newTopicName)
            submitButton
        }
    }

    private var submitButton: some View {
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
