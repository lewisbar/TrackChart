//
//  SwiftDataTopicViewModelTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 21.10.25.
//

import Testing
import Foundation
import SwiftData
import Persistence
import DataProcessing
import Presentation

@MainActor
class SwiftDataTopicViewModelTests {
    @Test func entriesForTopic() throws {
        let topics = makeTopicEntities(names: ["0", "1", "2"])

        let context = try setupContext(withTopics: topics)
        let selectedTopic = topics[2]

        let result = SwiftDataTopicViewModel.entries(for: selectedTopic)

        #expect(result.map(\.value) == selectedTopic.sortedEntries.map(\.value))
        #expect(result.map(\.timestamp) == selectedTopic.sortedEntries.map(\.timestamp))
    }

    @Test func submitNewValue()  throws {
        let topics = makeTopicEntities(names: ["0", "1", "2"])

        let context = try setupContext(withTopics: topics)
        let selectedTopic = topics[1]
        let selectedEntries = selectedTopic.sortedEntries

        SwiftDataTopicViewModel.submit(newValue: 2.5, timestamp: .now, to: selectedTopic)

        let updatedTopics = try fetchTopics(from: context)

        #expect(updatedTopics[1].entries?.count == selectedEntries.count + 1)

        let updatedEntryValues = updatedTopics[1].sortedEntries.map(\.value)
        #expect(updatedEntryValues == selectedEntries.map(\.value) + [2.5])
    }

    // MARK: - Helpers

    private func setupContext(
        withTopics topics: [TopicEntity],
        showTopic: @escaping (TopicEntity?) -> Void = { _ in }
    ) throws -> ModelContext {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let context = try makeContext(with: configuration)

        try setUp(context: context, with: topics)

        return context
    }

    private func makeContext(with configuration: ModelConfiguration) throws -> ModelContext {
        let schema = Schema([TopicEntity.self])
        let container = try ModelContainer(for: schema, configurations: configuration)
        return ModelContext(container)
    }

    private func fetchTopics(from context: ModelContext) throws -> [TopicEntity] {
        let fetchDescriptor = FetchDescriptor<TopicEntity>(sortBy: [SortDescriptor(\.sortIndex)])
        return try context.fetch(fetchDescriptor)
    }

    private func makeTopicEntities(names: [String], palette: Palette = .ocean, aggregator: Aggregator = .sum) -> [TopicEntity] {
        names.enumerated().map { index, name in
            TopicEntity(
                id: UUID(),
                name: name,
                entries: makeEntryEntities(from: Array(-1...Int.random(in: 3...10)).shuffled()),
                palette: palette.name,
                aggregator: aggregator.name,
                sortIndex: index
            )
        }
    }

    private func makeEntryEntities(from values: [Int]) -> [EntryEntity] {
        values.map(Double.init).enumerated().map { index, value in
            let timestamp = Double(index * 86_400 - 86_400 * values.count)
            return EntryEntity(value: value, timestamp: .now.advanced(by: timestamp))
        }
    }

    private func setUp(context: ModelContext, with topicEntities: [TopicEntity]) throws {
        for topicEntity in topicEntities {
            context.insert(topicEntity)
        }
        try context.save()
    }
}
