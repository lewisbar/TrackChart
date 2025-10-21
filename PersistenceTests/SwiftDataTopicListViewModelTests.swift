//
//  SwiftDataTopicListViewModelTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 21.10.25.
//

import Testing
import SwiftData
import Persistence
import Presentation

struct SwiftDataTopicListViewModelTests {
    @Test func delete() throws {
        try withCleanContext(topicNames: ["0", "1", "2", "3", "4"]) { context, topics, sut in
            sut.deleteTopics(at: .init([1,4]), from: topics, in: context)

            let newContext = ModelContext(context.container)
            let remainingTopics = try fetchTopics(from: newContext)

            #expect(remainingTopics.map(\.name) == ["0", "2", "3"])
            #expect(remainingTopics.map(\.sortIndex) == [0, 1, 2])
        }
    }

    @Test func move() throws {
        try withCleanContext(topicNames: ["0", "1", "2", "3", "4"]) { context, topics, sut in
            sut.moveTopics(from: .init([2, 3]), to: 1, inTopicList: topics, modelContext: context)

            let newContext = ModelContext(context.container)
            let remainingTopics = try fetchTopics(from: newContext)

            #expect(remainingTopics.map(\.name) == ["0", "2", "3", "1", "4"])
            #expect(remainingTopics.map(\.sortIndex) == [0, 1, 2, 3, 4])
        }
    }

    @Test func addAndShowNewTopic() throws {
        var shownTopics = [TopicEntity?]()

        try withCleanContext(topicNames: ["0", "1", "2", "3", "4"], showTopic: { shownTopics.append($0) }) { context, topics, sut in
            sut.addAndShowNewTopic(existingTopics: topics, in: context)

            let newContext = ModelContext(context.container)
            let remainingTopics = try fetchTopics(from: newContext)

            #expect(remainingTopics.map(\.name) == ["0", "1", "2", "3", "4", ""])
            #expect(remainingTopics.map(\.sortIndex) == [0, 1, 2, 3, 4, 5])
            #expect(shownTopics.count == 1)
            #expect(shownTopics.first??.name == "")
            #expect(shownTopics.first??.unsubmittedValue == 0)
            #expect(shownTopics.first??.sortIndex == 5)
            #expect(shownTopics.first??.entries == [])
        }
    }

    @Test func cellModelsFromTopics() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let context = try makeContext(with: configuration)
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        try setUp(context: context, with: topics)
        let sut = SwiftDataTopicListViewModel(showTopic: { _ in })

        let result = sut.cellModels(from: topics)

        let expectedCellModels = topics.map { topic in
            let entries = topic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).map { entry in
                TopicCellEntry(value: entry.value, timestamp: entry.timestamp)
            } ?? []

            return TopicCellModel(id: topic.id, name: topic.name, info: "\(topic.entryCount) entries", entries: entries)
        }

        #expect(result == expectedCellModels)
    }

    @Test func showTopicForCellModel() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let context = try makeContext(with: configuration)
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        try setUp(context: context, with: topics)
        var shownTopics = [TopicEntity?]()
        let sut = SwiftDataTopicListViewModel(showTopic: { shownTopics.append($0) })
        let selectedTopic = topics[3]
        let cellModel = TopicCellModel(id: selectedTopic.id, name: selectedTopic.name, info: "\(selectedTopic.entryCount) entries", entries: selectedTopic.entries?.map {
            TopicCellEntry(value: $0.value, timestamp: $0.timestamp)
        } ?? [])

        sut.showTopic(for: cellModel, in: topics)

        #expect(shownTopics == [selectedTopic])
    }

    // MARK: - Helpers

    /// Runs a test with a fresh SwiftData persistent context, cleaning up the store before and after.
    private func withCleanContext<T>(
        topicNames: [String],
        showTopic: @escaping (TopicEntity?) -> Void = { _ in },
        testBody: (ModelContext, [TopicEntity], SwiftDataTopicListViewModel) throws -> T
    ) throws -> T {
        let uniqueURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".sqlite")

        try? FileManager.default.removeItem(at: uniqueURL)

        let configuration = ModelConfiguration(url: uniqueURL)
        let context = try makeContext(with: configuration)

        let topics = makeTopicEntities(names: topicNames)
        try setUp(context: context, with: topics)

        let sut = SwiftDataTopicListViewModel(showTopic: showTopic)

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
