//
//  SwiftDataTopicListViewModelTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 21.10.25.
//

import Testing
import SwiftData
import Persistence
import DataProcessing
import Presentation

@MainActor
class SwiftDataTopicListViewModelTests {
    @Test func delete() throws {
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        let (sut, context) = try makeSUT(topics: topics)

        sut.deleteTopics(at: IndexSet([1,4]), from: topics)

        let remainingTopics = try fetchTopics(from: context)
        #expect(remainingTopics.map(\TopicEntity.name) == ["0", "2", "3"])
        #expect(remainingTopics.map(\TopicEntity.sortIndex) == [0, 1, 2])
    }

    @Test func move() throws {
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        let (sut, context) = try makeSUT(topics: topics)

        sut.moveTopics(from: IndexSet([2, 3]), to: 1, inTopicList: topics)

        let updatedTopics = try fetchTopics(from: context)
        #expect(updatedTopics.map(\TopicEntity.name) == ["0", "2", "3", "1", "4"])
        #expect(updatedTopics.map(\TopicEntity.sortIndex) == [0, 1, 2, 3, 4])
    }

    @Test func createTopic() throws {
        var shownTopics = [TopicEntity?]()
        let originalTopics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        var newTopicSortIndex: Int?
        let (sut, context) = try makeSUT(topics: originalTopics, showTopic: { shownTopics.append($0) }, newTopic: { newTopicSortIndex = $0 })

        sut.createTopic(existingTopics: originalTopics)
        try context.save()

        let updatedTopics = try fetchTopics(from: context)
        #expect(updatedTopics == originalTopics)
        #expect(shownTopics.count == 0)
        #expect(newTopicSortIndex == 5)
    }

    @Test func cellModelsFromTopics() throws {
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"], aggregator: .sum, treatsMissingAsZero: true)
        let (sut, _) = try makeSUT(topics: topics, palette: "Ocean")
        
        let result = sut.cellModels(from: topics)

        let expectedCellModels = topics.map { topic in
            let entries = topic.sortedEntries.map { entry in
                ViewEntry(id: entry.id, value: entry.value, timestamp: entry.timestamp)
            }

            return ViewTopic(id: topic.id, name: topic.name, details: topic.details, entries: entries, aggregator: .sum, treatsMissingAsZero: true, palette: .ocean)
        }

        #expect(result.map(\.id) == expectedCellModels.map(\.id))
        #expect(result.map(\.name) == expectedCellModels.map(\.name))
        #expect(result.map(\.palette.name) == expectedCellModels.map(\.palette.name))
        #expect(result.map { $0.entries.map(\.value) } == expectedCellModels.map { $0.entries.map(\.value) })
        #expect(result.map { $0.entries.map(\.timestamp) } == expectedCellModels.map { $0.entries.map(\.timestamp) })
        #expect(result.map(\.aggregator) == expectedCellModels.map(\.aggregator))
        #expect(result.map(\.treatsMissingAsZero) == expectedCellModels.map(\.treatsMissingAsZero))
    }

    @Test func showTopicForCellModel() throws {
        var shownTopics = [TopicEntity?]()
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        let (sut, _) = try makeSUT(topics: topics, showTopic: { shownTopics.append($0) })
        let selectedTopic = topics[3]
        let cellModel = ViewTopic(id: selectedTopic.id, name: selectedTopic.name, details: selectedTopic.details, entries: selectedTopic.entries?.map {
            ViewEntry(id: $0.id, value: $0.value, timestamp: $0.timestamp)
        } ?? [], aggregator: .average, treatsMissingAsZero: false, palette: .ocean)

        sut.showTopic(for: cellModel, in: topics)

        #expect(shownTopics == [selectedTopic])
    }

    // MARK: - Helpers

    private func makeSUT(
        topics: [TopicEntity],
        palette: String = "Ocean",
        showTopic: @escaping (TopicEntity?) -> Void = { _ in },
        newTopic: @escaping (Int) -> Void = { _ in }
    ) throws -> (SwiftDataTopicListViewModel, ModelContext) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let context = try makeContext(with: configuration)

        try setUp(context: context, with: topics)

        let sut = SwiftDataTopicListViewModel(
            insert: context.insert,
            delete: context.delete,
            showTopic: showTopic,
            newTopic: newTopic,
            randomPalette: { palette }
        )

        weakSUT = sut

        return (sut, context)
    }

    private weak var weakSUT: SwiftDataTopicListViewModel?

    deinit {
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
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

    private func makeTopicEntities(names: [String], aggregator: Aggregator = .sum, treatsMissingAsZero: Bool = false) -> [TopicEntity] {
        names.enumerated().map { index, name in
            TopicEntity(
                id: UUID(),
                name: name,
                details: "Some details about \(name)",
                entries: makeEntryEntities(from: Array(-1...Int.random(in: 3...10))),
                palette: "Ocean",
                aggregator: aggregator.name,
                treatsMissingAsZero: treatsMissingAsZero,
                sortIndex: index
            )
        }
    }

    private func makeEntryEntities(from values: [Int]) -> [EntryEntity] {
        values.map(Double.init).enumerated().map { index, value in
            EntryEntity(value: value, timestamp: .now.advanced(by: -value))
        }
    }

    private func setUp(context: ModelContext, with topicEntities: [TopicEntity]) throws {
        for topicEntity in topicEntities {
            context.insert(topicEntity)
        }
        try context.save()
    }
}
