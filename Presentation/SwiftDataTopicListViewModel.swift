//
//  SwiftDataTopicListViewModel.swift
//  Persistence
//
//  Created by Lennart Wisbar on 20.10.25.
//

import SwiftUI
import SwiftData
import Persistence
import DataProcessing

@MainActor
public class SwiftDataTopicListViewModel {
    private let insert: (TopicEntity) -> Void
    private let delete: (TopicEntity) -> Void
    private let showTopic: (TopicEntity?) -> Void
    private let newTopic: (_ sortIndex: Int) -> Void
    private let randomPalette: () -> String

    public init(
        insert: @escaping (TopicEntity) -> Void,
        delete: @escaping (TopicEntity) -> Void,
        showTopic: @escaping (TopicEntity?) -> Void,
        newTopic: @escaping (_ sortIndex: Int) -> Void,
        randomPalette: @escaping () -> String
    ) {
        self.insert = insert
        self.delete = delete
        self.showTopic = showTopic
        self.newTopic = newTopic
        self.randomPalette = randomPalette
    }

    public func deleteTopics(at indexSet: IndexSet, from topics: [TopicEntity]) {
        for index in indexSet {
            let topic = topics[index]
            delete(topic)
        }
        cleanUpDeletedSortIndices(indexSet, in: topics)
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

    public func moveTopics(from indexSet: IndexSet, to destination: Int, inTopicList topics: [TopicEntity]) {
        var tempTopics = topics.sorted(by: { $0.sortIndex < $1.sortIndex })
        tempTopics.move(fromOffsets: indexSet, toOffset: destination)
        for (index, topic) in tempTopics.enumerated() {
            topic.sortIndex = index
        }
    }

    public func cellModels(from topics: [TopicEntity]) -> [CellTopic] {
        topics.map { topic in
            let entries = topic.sortedEntries.map {
                ChartEntry(value: $0.value, timestamp: $0.timestamp)
            }

            return CellTopic(
                id: topic.id,
                name: topic.name,
                entries: entries,
                aggregator: Aggregator.aggregator(named: topic.aggregator),
                treatsMissingAsZero: topic.treatsMissingAsZero,
                palette: .palette(named: topic.palette)
            )
        }
    }

    public func showTopic(for cellModel: CellTopic, in topics: [TopicEntity]) {
        showTopic(topics.first(where: { $0.id == cellModel.id }))
    }

    public func createTopic(existingTopics topics: [TopicEntity]) {
        newTopic(topics.count)
    }
}
