//
//  SwiftDataTopicListViewModel.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 20.10.25.
//

import SwiftUI
import SwiftData
import Presentation

public class SwiftDataTopicListViewModel {
    private let showTopic: (TopicEntity?) -> Void

    public init(showTopic: @escaping (TopicEntity?) -> Void) {
        self.showTopic = showTopic
    }

    public func deleteTopics(at indexSet: IndexSet, from topics: [TopicEntity], in modelContext: ModelContext) {
        for index in indexSet {
            let topic = topics[index]
            modelContext.delete(topic)
        }
        cleanUpDeletedSortIndices(indexSet, in: topics)
        try? modelContext.save()
    }

    private func cleanUpDeletedSortIndices(_ indexSet: IndexSet, in topics: [TopicEntity]) {
        let remainingTopics = topics
            .enumerated()
            .filter { !indexSet.contains($0.offset) }
            .map { $0.element }

        for (newIndex, topic) in remainingTopics.enumerated() {
            topic.sortIndex = newIndex
        }
    }

    public func moveTopics(from indexSet: IndexSet, to destination: Int, inTopicList topics: [TopicEntity], modelContext: ModelContext) {
        var tempTopics = topics.sorted(by: { $0.sortIndex < $1.sortIndex })
        tempTopics.move(fromOffsets: indexSet, toOffset: destination)
        for (index, topic) in tempTopics.enumerated() {
            topic.sortIndex = index
        }
        try? modelContext.save()
    }

    public func addAndShowNewTopic(existingTopics topics: [TopicEntity], in modelContext: ModelContext) {
        let topic = TopicEntity(name: "", unsubmittedValue: 0, sortIndex: topics.count)
        modelContext.insert(topic)
        try? modelContext.save()
        showTopic(topic)
    }

    public func cellModels(from topics: [TopicEntity]) -> [TopicCellModel] {
        topics.map(\.topic).map(TopicCellModel.init)
    }

    public func showTopic(for cellModel: TopicCellModel, in topics: [TopicEntity]) {
        showTopic(topics.first(where: { $0.id == cellModel.id }))
    }
}
