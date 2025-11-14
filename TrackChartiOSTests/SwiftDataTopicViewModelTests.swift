//
//  SwiftDataTopicViewModelTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 21.10.25.
//

import Testing
@testable import TrackChartiOS
import SwiftData
import Persistence

@MainActor
class SwiftDataTopicViewModelTests {
    @Test func entriesForTopic() throws {
        let topics = makeTopicEntities(names: ["0", "1", "2"])

        let (sut, _) = try makeSUT(topics: topics)
        let selectedTopic = topics[2]

        let result = sut.entries(for: selectedTopic)

        #expect(result.map(\.value) == selectedTopic.sortedEntries.map(\.value))
        #expect(result.map(\.timestamp) == selectedTopic.sortedEntries.map(\.timestamp))
    }

    @Test func submitNewValue()  throws {
        let topics = makeTopicEntities(names: ["0", "1", "2"])

        let (sut, context) = try makeSUT(topics: topics)
        let selectedTopic = topics[1]
        let selectedEntries = selectedTopic.sortedEntries

        sut.submit(newValue: 2.5, timestamp: .now, to: selectedTopic)

        let updatedTopics = try fetchTopics(from: context)

        #expect(updatedTopics[1].entries?.count == selectedEntries.count + 1)

        let updatedEntryValues = updatedTopics[1].sortedEntries.map(\.value)
        #expect(updatedEntryValues == selectedEntries.map(\.value) + [2.5])
    }

    @Test func deleteLastValue() throws {
        let topics = makeTopicEntities(names: ["0", "1", "2"])

        let (sut, context) = try makeSUT(topics: topics)
        let selectedTopic = topics[1]
        let selectedEntries = selectedTopic.sortedEntries

        sut.deleteLastValue(from: selectedTopic)

        let updatedTopics = try fetchTopics(from: context)

        #expect(updatedTopics[1].entries?.count == selectedEntries.count - 1)
        let lastEntry = updatedTopics[1].sortedEntries.last
        #expect(lastEntry?.value == selectedEntries.dropLast().last?.value)
    }

    @Test func deleteLastValue_whenValuesAreEmpty_doesNotCauseProblems() throws {
        let topics = makeTopicEntities(names: ["0", "1", "2"], palette: .ocean)

        let (sut, context) = try makeSUT(topics: topics)
            let selectedTopic = topics[1]
            selectedTopic.entries?.removeAll()

            sut.deleteLastValue(from: selectedTopic)

            let updatedTopics = try fetchTopics(from: context)

            #expect(updatedTopics[1].entries == [])
    }

    @Test func changePalette() throws {
        let topics = makeTopicEntities(names: ["0", "1", "2"], palette: .ocean)
        let (sut, context) = try makeSUT(topics: topics)
        let selectedTopic = topics[1]

        sut.changePalette(to: .forest, for: selectedTopic)

        let updatedTopics = try fetchTopics(from: context)

        #expect(updatedTopics[1].palette == "Forest")
    }

    // MARK: - Helpers

    private func makeSUT(
        topics: [TopicEntity],
        showTopic: @escaping (TopicEntity?) -> Void = { _ in }
    ) throws -> (SwiftDataTopicViewModel, ModelContext) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let context = try makeContext(with: configuration)

        try setUp(context: context, with: topics)

        let sut = SwiftDataTopicViewModel()

        weakSUT = sut

        return (sut, context)
    }

    private weak var weakSUT: SwiftDataTopicViewModel?

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

    private func makeTopicEntities(names: [String], palette: Palette = .ocean) -> [TopicEntity] {
        names.enumerated().map { index, name in
            TopicEntity(
                id: UUID(),
                name: name,
                entries: makeEntryEntities(from: Array(-1...Int.random(in: 3...10)).shuffled()),
                palette: palette.name,
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
