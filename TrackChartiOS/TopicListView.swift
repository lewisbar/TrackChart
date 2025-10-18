//
//  TopicListView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI
import Presentation
import SwiftData

struct TopicListView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Topic.sortIndex) var topics: [Topic]
    let showTopic: (Topic) -> Void

    var body: some View {
        ZStack {
            list
            plusButton
        }
    }

    private var list: some View {
        List {
            ForEach(topics) { topic in
                TopicCell(topic: topic, showTopic: showTopic)
                    .listRowSeparator(.hidden)
            }
            .onDelete(perform: deleteTopics)
            .onMove(perform: moveTopics)
        }
    }

    func deleteTopics(at indexSet: IndexSet) {
        for index in indexSet {
            let topic = topics[index]
            modelContext.delete(topic)
        }
    }

    func moveTopics(from indexSet: IndexSet, to destination: Int) {
        var tempTopics = topics.sorted(by: { $0.sortIndex < $1.sortIndex })
        tempTopics.move(fromOffsets: indexSet, toOffset: destination)
        for (index, topic) in tempTopics.enumerated() {
            topic.sortIndex = index
        }
        try? self.modelContext.save()
    }

    private var plusButton: some View {
        VStack {
            Spacer()
            CircleButton(action: createNewTopic, image: Image(systemName: "plus"), color: .blue)
                .padding(.bottom)
        }
    }

    private func createNewTopic() {
        let topic = Topic(name: "", unsubmittedValue: 0, sortIndex: topics.count)
        modelContext.insert(topic)
        showTopic(topic)
    }
}

//#Preview {
//    @Previewable @State var topics = [
//        TopicCellModel(
//            id: UUID(),
//            name: "Daily Pages Read",
//            info: "7 entries",
//            entries: [1, 2, 4, 8, 16, -1, -2].map { TopicCellEntry(value: $0, timestamp: Date()) }
//        ),
//
//        TopicCellModel(
//            id: UUID(),
//            name: "Daily Pages Read",
//            info: "7 entries",
//            entries: [].map { TopicCellEntry(value: $0, timestamp: Date()) }
//        ),
//
//        TopicCellModel(
//            id: UUID(),
//            name: "Daily Pages Read",
//            info: "7 entries",
//            entries: [1].map { TopicCellEntry(value: $0, timestamp: Date()) }
//        )
//    ]
//
//    TopicListView(topics: topics, showTopic: { _ in }, createTopic: {})
//}
