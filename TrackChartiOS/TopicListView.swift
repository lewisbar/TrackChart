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
                SwiftDataTopicCell(topic: topic, showTopic: showTopic)
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

#Preview {
    let container: ModelContainer = {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Topic.self, configurations: configuration)
            let context = container.mainContext


            let topic1 = Topic(name: "Topic 1", entries: [
                Entry(value: 4, timestamp: .now, sortIndex: 0),
                Entry(value: -5, timestamp: .now, sortIndex: 1),
                Entry(value: 0, timestamp: .now, sortIndex: 2),
                Entry(value: 4, timestamp: .now, sortIndex: 3),
                Entry(value: 14, timestamp: .now, sortIndex: 4),
            ], unsubmittedValue: 0, sortIndex: 0)
            let topic2 = Topic(name: "Topic 2", entries: [
                Entry(value: -4, timestamp: .now, sortIndex: 0),
                Entry(value: 50, timestamp: .now, sortIndex: 1),
                Entry(value: 100, timestamp: .now, sortIndex: 2),
                Entry(value: -44, timestamp: .now, sortIndex: 3),
                Entry(value: 4, timestamp: .now, sortIndex: 4),
            ], unsubmittedValue: 4, sortIndex: 1)
            let topic3 = Topic(name: "Topic 3", entries: [
                Entry(value: 40, timestamp: .now, sortIndex: 0),
                Entry(value: 50, timestamp: .now, sortIndex: 1),
                Entry(value: 10, timestamp: .now, sortIndex: 2),
                Entry(value: 20, timestamp: .now, sortIndex: 3),
                Entry(value: 30, timestamp: .now, sortIndex: 4),
            ], unsubmittedValue: -1, sortIndex: 2)

            context.insert(topic1)
            context.insert(topic2)
            context.insert(topic3)

            try context.save()

            return container
        } catch {
            fatalError("Failed to create container: \(error.localizedDescription)")
        }
    }()

    TopicListView(showTopic: { _ in })            .modelContainer(container)
}
