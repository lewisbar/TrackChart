//
//  SwiftDataTopicListViewModelTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 21.10.25.
//

import Testing
import TrackChartiOS
import SwiftData
import Persistence

@MainActor
class SwiftDataTopicListViewModelTests {
    @Test func delete() throws {
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        let (sut, context) = try makeSUT(topics: topics)
        sut.deleteTopics(at: .init([1,4]), from: topics)

        let remainingTopics = try fetchTopics(from: context)

        #expect(remainingTopics.map(\.name) == ["0", "2", "3"])
        #expect(remainingTopics.map(\.sortIndex) == [0, 1, 2])
    }

    @Test func move() throws {
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        let (sut, context) = try makeSUT(topics: topics)
        sut.moveTopics(from: .init([2, 3]), to: 1, inTopicList: topics)

        let updatedTopics = try fetchTopics(from: context)

        #expect(updatedTopics.map(\.name) == ["0", "2", "3", "1", "4"])
        #expect(updatedTopics.map(\.sortIndex) == [0, 1, 2, 3, 4])
    }

    @Test func addAndShowNewTopic() throws {
        var shownTopics = [TopicEntity?]()
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        let (sut, context) = try makeSUT(topics: topics, showTopic: { shownTopics.append($0) })

        sut.addAndShowNewTopic(existingTopics: topics)
        try context.save()

        let updatedTopics = try fetchTopics(from: context)

        #expect(updatedTopics.map(\.name) == ["0", "1", "2", "3", "4", ""])
        #expect(updatedTopics.map(\.sortIndex) == [0, 1, 2, 3, 4, 5])
        #expect(shownTopics.count == 1)
        #expect(shownTopics.first??.name == "")
        #expect(shownTopics.first??.sortIndex == 5)
        #expect(shownTopics.first??.entries == [])
    }

    @Test func cellModelsFromTopics() throws {
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        let (sut, _) = try makeSUT(topics: topics, palette: "Ocean")
        let result = sut.cellModels(from: topics)

        let expectedCellModels = topics.map { topic in
            let entries = topic.sortedEntries.map { entry in
                ChartEntry(value: entry.value, timestamp: entry.timestamp)
            }

            return CellTopic(id: topic.id, name: topic.name, entries: entries, palette: .ocean)
        }

        #expect(result.map(\.id) == expectedCellModels.map(\.id))
        #expect(result.map(\.name) == expectedCellModels.map(\.name))
        #expect(result.map(\.palette.name) == expectedCellModels.map(\.palette.name))
        #expect(result.map { $0.entries.map(\.value) } == expectedCellModels.map { $0.entries.map(\.value) })
        #expect(result.map { $0.entries.map(\.timestamp) } == expectedCellModels.map { $0.entries.map(\.timestamp) })
    }

    @Test func showTopicForCellModel() throws {
        var shownTopics = [TopicEntity?]()
        let topics = makeTopicEntities(names: ["0", "1", "2", "3", "4"])
        let (sut, _) = try makeSUT(topics: topics, showTopic: { shownTopics.append($0) })
        let selectedTopic = topics[3]
        let cellModel = CellTopic(id: selectedTopic.id, name: selectedTopic.name, entries: selectedTopic.entries?.map {
            ChartEntry(value: $0.value, timestamp: $0.timestamp)
        } ?? [], palette: .ocean)

        sut.showTopic(for: cellModel, in: topics)

        #expect(shownTopics == [selectedTopic])
    }

    // MARK: - Helpers

    private func makeSUT(
        topics: [TopicEntity],
        palette: String = "Ocean",
        showTopic: @escaping (TopicEntity?) -> Void = { _ in }
    ) throws -> (SwiftDataTopicListViewModel, ModelContext) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let context = try makeContext(with: configuration)

        try setUp(context: context, with: topics)

        let sut = SwiftDataTopicListViewModel(
            insert: context.insert,
            delete: context.delete,
            showTopic: showTopic,
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

    private func makeTopicEntities(names: [String]) -> [TopicEntity] {
        names.enumerated().map { index, name in
            TopicEntity(
                id: UUID(),
                name: name,
                entries: makeEntryEntities(from: Array(-1...Int.random(in: 3...10))),
                palette: "Ocean",
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
