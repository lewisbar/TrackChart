//
//  SwiftDataTopicViewModelTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 21.10.25.
//

import Testing
import Persistence
import SwiftData

struct SwiftDataTopicViewModelTests {
    @Test func entriesForTopic() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let context = try makeContext(with: configuration)
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        try setUp(context: context, with: topics)
        let selectedTopic = topics[3]
        let sut = SwiftDataTopicViewModel()

        let result = sut.entries(for: selectedTopic)

        #expect(result == selectedTopic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).map(\.value))
    }

    @Test func submitNewValue() throws {
        try withCleanContext(topicNames: ["0", "1", "2"]) { context, topics, sut in
            let selectedTopic = topics[1]
            let selectedEntries = selectedTopic.entries ?? []
            
            sut.submit(newValue: 2.5, to: selectedTopic, in: context)

            let newContext = ModelContext(context.container)
            let updatedTopics = try fetchTopics(from: newContext)

            #expect(updatedTopics[1].entries?.count == selectedEntries.count + 1)
            let lastEntry = updatedTopics[1].entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).last
            #expect(lastEntry?.value == 2.5)
            #expect(lastEntry?.sortIndex == selectedEntries.count)
        }
    }

    @Test func deleteLastValue() throws {
        try withCleanContext(topicNames: ["0", "1", "2"]) { context, topics, sut in
            let selectedTopic = topics[1]
            let selectedEntries = selectedTopic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }) ?? []

            sut.deleteLastValue(from: selectedTopic, in: context)

            let newContext = ModelContext(context.container)
            let updatedTopics = try fetchTopics(from: newContext)

            #expect(updatedTopics[1].entries?.count == selectedEntries.count - 1)
            let lastEntry = updatedTopics[1].entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).last
            #expect(lastEntry?.value == selectedEntries.dropLast().last?.value)
            #expect(lastEntry?.sortIndex == selectedEntries.count - 2)
        }
    }

    @Test func deleteLastValue_whenValuesAreEmpty_doesNotCauseProblems() throws {
        try withCleanContext(topicNames: ["0", "1", "2"]) { context, topics, sut in
            let selectedTopic = topics[1]
            selectedTopic.entries?.removeAll()
            try context.save()

            sut.deleteLastValue(from: selectedTopic, in: context)

            let newContext = ModelContext(context.container)
            let updatedTopics = try fetchTopics(from: newContext)

            #expect(updatedTopics[1].entries == [])
        }
    }

    // MARK: - Helpers

    /// Runs a test with a fresh SwiftData persistent context, cleaning up the store before and after.
    private func withCleanContext<T>(
        topicNames: [String],
        testBody: (ModelContext, [TopicEntity], SwiftDataTopicViewModel) throws -> T
    ) throws -> T {
        let uniqueURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".sqlite")

        try? FileManager.default.removeItem(at: uniqueURL)

        let configuration = ModelConfiguration(url: uniqueURL)
        let context = try makeContext(with: configuration)

        let topics = makeTopicEntities(names: topicNames)
        try setUp(context: context, with: topics)

        let sut = SwiftDataTopicViewModel()

        defer {
            try? FileManager.default.removeItem(at: uniqueURL)
        }

        return try testBody(context, topics, sut)
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

    private func makeTopicEntities(names: [String]) -> [TopicEntity] {
        names.enumerated().map { index, name in
            TopicEntity(
                id: UUID(),
                name: name,
                entries: makeEntryEntities(from: Array(-1...Int.random(in: 3...10))),
                unsubmittedValue: 5,
                sortIndex: index
            )
        }
    }

    private func makeEntryEntities(from values: [Int]) -> [EntryEntity] {
        values.map(Double.init).enumerated().map { index, value in
            EntryEntity(value: value, timestamp: .now.advanced(by: -value), sortIndex: index)
        }
    }

    private func setUp(context: ModelContext, with topicEntities: [TopicEntity]) throws {
        for topicEntity in topicEntities {
            context.insert(topicEntity)
        }
        try context.save()
    }
}
