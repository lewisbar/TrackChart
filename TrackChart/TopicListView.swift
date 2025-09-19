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
    @State private var isAddTopicViewPresented = false
    @State private var newTopicName = "New Topic"

    init(topics: [TopicCellModel], createTopic: @escaping (String) -> Void) {
        self.topics = topics
        self.createTopic = createTopic
    }

    var body: some View {
        ZStack {
            List(topics) { topic in
                TopicCell(topic: topic)
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
    TopicListView(topics: [
        TopicCellModel(id: UUID(), name: "Daily Pages Read", info: "15 entries"),
        TopicCellModel(id: UUID(), name: "Pushups", info: "230 entries"),
        TopicCellModel(id: UUID(), name: "Hours Studied", info: "32 entries")
    ], createTopic: { _ in })
}
