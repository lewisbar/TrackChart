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
        let uniqueURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".sqlite")
        let configuration = ModelConfiguration(url: uniqueURL)
        try? FileManager.default.removeItem(at: configuration.url)
        let context = try makeContext(with: configuration)
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        try setUp(context: context, with: topics)
        let sut = SwiftDataTopicListViewModel(showTopic: { _ in })

        sut.deleteTopics(at: .init([1, 4]), from: topics, in: context)

        let newContext = try makeContext(with: configuration)
        let fetchDescriptor = FetchDescriptor<TopicEntity>(sortBy: [SortDescriptor(\.sortIndex)])
        let remainingTopics = try newContext.fetch(fetchDescriptor)
        #expect(remainingTopics.map(\.name) == ["0", "2", "3"])
        #expect(remainingTopics.map(\.sortIndex) == [0, 1, 2])
        try FileManager.default.removeItem(at: configuration.url)
    }

    @Test func move() throws {
        let uniqueURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".sqlite")
        let configuration = ModelConfiguration(url: uniqueURL)
        try? FileManager.default.removeItem(at: configuration.url)
        let context = try makeContext(with: configuration)
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        try setUp(context: context, with: topics)
        let sut = SwiftDataTopicListViewModel(showTopic: { _ in })

        sut.moveTopics(from: .init([2, 3]), to: 1, inTopicList: topics, modelContext: context)

        let newContext = try makeContext(with: configuration)
        let fetchDescriptor = FetchDescriptor<TopicEntity>(sortBy: [SortDescriptor(\.sortIndex)])
        let remainingTopics = try newContext.fetch(fetchDescriptor)
        #expect(remainingTopics.map(\.name) == ["0", "2", "3", "1", "4"])
        #expect(remainingTopics.map(\.sortIndex) == [0, 1, 2, 3, 4])
        try FileManager.default.removeItem(at: configuration.url)
    }

    // MARK: - Helpers

    private func makeContext(with configuration: ModelConfiguration) throws -> ModelContext {
        let schema = Schema([TopicEntity.self])
        let container = try ModelContainer(for: schema, configurations: configuration)
        return ModelContext(container)
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
