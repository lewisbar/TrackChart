//
//  SwiftDataTopicListViewModelTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 21.10.25.
//

import Testing
import SwiftData
import Persistence

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

    // MARK: - Helpers

    /// Runs a test with a fresh SwiftData context, cleaning up the store before and after.
    private func withCleanContext<T>(topicNames: [String], testBody: (ModelContext, [TopicEntity], SwiftDataTopicListViewModel) throws -> T) throws -> T {
        let uniqueURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".sqlite")

        try? FileManager.default.removeItem(at: uniqueURL)

        let configuration = ModelConfiguration(url: uniqueURL)
        let schema = Schema([TopicEntity.self])
        let container = try ModelContainer(for: schema, configurations: configuration)
        let context = ModelContext(container)

        let topics = makeTopicEntities(names: topicNames)
        try setUp(context: context, with: topics)

        let sut = SwiftDataTopicListViewModel(showTopic: { _ in })

        defer {
            try? FileManager.default.removeItem(at: uniqueURL)
        }

        return try testBody(context, topics, sut)
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
                entries: makeEntryEntities(from: Array(1...name.count)),
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
