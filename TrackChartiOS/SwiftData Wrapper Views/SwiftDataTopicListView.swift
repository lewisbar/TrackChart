//
//  SwiftDataTopicListView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 20.10.25.
//

import SwiftUI
import SwiftData
import Persistence
import Presentation

/// Wrapper to decouple the actual View from SwiftData
struct SwiftDataTopicListView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \TopicEntity.sortIndex) var topics: [TopicEntity]
    let showTopic: (TopicEntity?) -> Void

    var body: some View {
        TopicListView(
            topics: topics.map(\.topic).map(TopicCellModel.init),
            deleteTopics: deleteTopics,
            moveTopics: moveTopics,
            showTopic: { cellModel in showTopic(topics.first(where: { $0.id == cellModel.id })) },
            createNewTopic: createNewTopic
        )
    }

    private func deleteTopics(at indexSet: IndexSet) {
        for index in indexSet {
            let topic = topics[index]
            modelContext.delete(topic)
            cleanUpSortIndices()
        }
    }

    private func cleanUpSortIndices() {
        for (index, topic) in topics.enumerated() {
            topic.sortIndex = index
        }
    }

    private func moveTopics(from indexSet: IndexSet, to destination: Int) {
        var tempTopics = topics.sorted(by: { $0.sortIndex < $1.sortIndex })
        tempTopics.move(fromOffsets: indexSet, toOffset: destination)
        for (index, topic) in tempTopics.enumerated() {
            topic.sortIndex = index
        }
        try? self.modelContext.save()
    }

    private func createNewTopic() {
        let topic = TopicEntity(name: "", unsubmittedValue: 0, sortIndex: topics.count)
        modelContext.insert(topic)
        showTopic(topic)
    }
}
