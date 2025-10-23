//
//  SwiftDataTopicViewModelTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 21.10.25.
//

import Testing
import Persistence
import SwiftData
import Presentation

@MainActor
class SwiftDataTopicViewModelTests {
    @Test func entriesForTopic() async throws {
        try await withCleanContext(topicNames: ["0", "1", "2", "3", "4"]) { context, topics, sut, errors in
            let selectedTopic = topics[2]

            let result = sut.entries(for: selectedTopic)

            #expect(result.map(\.entry) == selectedTopic.entries?.sorted(by: { $0.timestamp < $1.timestamp }).map(\.entry))
        }
    }

    @Test func submitNewValue() async throws {
        try await withCleanContext(topicNames: ["0", "1", "2"]) { context, topics, sut, errors in
            let selectedTopic = topics[1]
            let selectedEntries = selectedTopic.entries?.sorted(by: { $0.timestamp < $1.timestamp }) ?? []

            sut.submit(newValue: 2.5, to: selectedTopic)

            let newContext = ModelContext(context.container)
            let updatedTopics = try fetchTopics(from: newContext)

            #expect(updatedTopics[1].entries?.count == selectedEntries.count + 1)

            let updatedEntryValues = updatedTopics[1].entries?.sorted(by: { $0.timestamp < $1.timestamp }).map(\.value)
            #expect(updatedEntryValues == selectedEntries.map(\.value) + [2.5])
        }
    }

    @Test func deleteLastValue() async throws {
        try await withCleanContext(topicNames: ["0", "1", "2"]) { context, topics, sut, errors in
            let selectedTopic = topics[1]
            let selectedEntries = selectedTopic.entries?.sorted(by: { $0.timestamp < $1.timestamp }) ?? []

            sut.deleteLastValue(from: selectedTopic)

            let newContext = ModelContext(context.container)
            let updatedTopics = try fetchTopics(from: newContext)

            #expect(updatedTopics[1].entries?.count == selectedEntries.count - 1)
            let lastEntry = updatedTopics[1].entries?.sorted(by: { $0.timestamp < $1.timestamp }).last
            #expect(lastEntry?.value == selectedEntries.dropLast().last?.value)
        }
    }

    @Test func deleteLastValue_whenValuesAreEmpty_doesNotCauseProblems() async throws {
        try await withCleanContext(topicNames: ["0", "1", "2"]) { context, topics, sut, errors in
            let selectedTopic = topics[1]
            selectedTopic.entries?.removeAll()
            try context.save()

            sut.deleteLastValue(from: selectedTopic)

            let newContext = ModelContext(context.container)
            let updatedTopics = try fetchTopics(from: newContext)

            #expect(updatedTopics[1].entries == [])
        }
    }

    @Test func renameTopic_doesNotPersistUnlessNameChangedIsCalled_andThenDebounceSaves() async throws {
        try await withCleanContext(topicNames: ["0", "1", "2"]) { context, topics, sut, errors in
            let selectedTopic = topics[1]

            // Change name for the first time; will not be persisted without nameChanged call
            selectedTopic.name = "New Name 1"
            #expect(context.hasChanges)

            // Create new context to show changes have not been persisted
            let newContext1 = ModelContext(context.container)
            let updatedTopics1 = try fetchTopics(from: newContext1)

            #expect(!updatedTopics1.contains(where: { $0.name == "New Name 1"}))
            #expect(!newContext1.hasChanges)

            // Change name again, this time calling nameChanged afterwards
            selectedTopic.name = "New Name 2"
            #expect(context.hasChanges)

            await sut.nameChanged()?.value

            // After the nameChanged call, changes are persistent and therefore visible also in a new context
            let newContext2 = ModelContext(context.container)
            let updatedTopics2 = try fetchTopics(from: newContext2)

            #expect(updatedTopics2.contains(where: { $0.name == "New Name 2" }))
            #expect(!newContext2.hasChanges)
        }
    }

    // MARK: - Helpers

    /// Runs a test with a fresh SwiftData persistent context, cleaning up the store before and after.
    private func withCleanContext<T: Sendable>(
        topicNames: [String],
        testBody: @MainActor (ModelContext, [TopicEntity], SwiftDataTopicViewModel, [Error]) async throws -> T
    ) async throws -> T {
        let uniqueURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".sqlite")

        try? FileManager.default.removeItem(at: uniqueURL)

        let configuration = ModelConfiguration(url: uniqueURL)
        let context = try makeContext(with: configuration)

        let topics = makeTopicEntities(names: topicNames)
        try setUp(context: context, with: topics)

        var capturedErrors = [Error]()

        // Testing with the real saver because we need a ModelContainer anyway whenever working with @Models
        let saver = SwiftDataSaver(contextHasChanges: { context.hasChanges }, saveToContext: context.save, sendError: { capturedErrors.append($0) })
        let sut = SwiftDataTopicViewModel(
            save: saver.save,
            debounceSave: saver.debounceSave,
            debounceSaveDelay: 0
        )

        weakSUT = sut
        weakSaver = saver

        defer {
            try? FileManager.default.removeItem(at: uniqueURL)
        }

        return try await testBody(context, topics, sut, capturedErrors)
    }

    private weak var weakSUT: SwiftDataTopicViewModel?
    private weak var weakSaver: SwiftDataSaver?

    deinit {
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
        #expect(weakSaver == nil, "Instance should have been deallocated. Potential memory leak.")
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
                entries: makeEntryEntities(from: Array(-1...Int.random(in: 3...10)).shuffled()),
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
