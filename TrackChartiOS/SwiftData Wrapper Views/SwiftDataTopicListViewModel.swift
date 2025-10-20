//
//  SwiftDataTopicListViewModel.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 20.10.25.
//

import Foundation
import SwiftData
import Persistence
import Presentation

class SwiftDataTopicListViewModel {
    private let showTopic: (TopicEntity?) -> Void

    init(showTopic: @escaping (TopicEntity?) -> Void) {
        self.showTopic = showTopic
    }

    func deleteTopics(at indexSet: IndexSet, from topics: [TopicEntity], in modelContext: ModelContext) {
        for index in indexSet {
            let topic = topics[index]
            modelContext.delete(topic)
            cleanUpSortIndices(in: topics)
        }
    }

    private func cleanUpSortIndices(in topics: [TopicEntity]) {
        for (index, topic) in topics.enumerated() {
            topic.sortIndex = index
        }
    }

    func moveTopics(from indexSet: IndexSet, to destination: Int, inTopicList topics: [TopicEntity], modelContext: ModelContext) {
        var tempTopics = topics.sorted(by: { $0.sortIndex < $1.sortIndex })
        tempTopics.move(fromOffsets: indexSet, toOffset: destination)
        for (index, topic) in tempTopics.enumerated() {
            topic.sortIndex = index
        }
        try? modelContext.save()
    }

    func addAndShowNewTopic(to topics: [TopicEntity], in modelContext: ModelContext) {
        let topic = TopicEntity(name: "", unsubmittedValue: 0, sortIndex: topics.count)
        modelContext.insert(topic)
        showTopic(topic)
    }

    func cellModels(from topics: [TopicEntity]) -> [TopicCellModel] {
        topics.map(\.topic).map(TopicCellModel.init)
    }

    func showTopic(for cellModel: TopicCellModel, in topics: [TopicEntity]) {
        showTopic(topics.first(where: { $0.id == cellModel.id }))
    }
}
