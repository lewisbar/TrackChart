//
//  SwiftDataEntryListViewModelTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 14.11.25.
//

import Testing
import SwiftData
import Persistence
@testable import TrackChartiOS

class SwiftDataEntryListViewModel {
    func listEntries(for topic: TopicEntity) -> [ListEntry] {
        topic.sortedEntries.map(ListEntry.init)
    }

    func updateEntry(_ listEntry: ListEntry, of topic: TopicEntity) {
        let entryEntity = topic.entries?.first(where: { $0.id == listEntry.id })
        entryEntity?.value = listEntry.value
        entryEntity?.timestamp = listEntry.timestamp
    }
}

private extension ListEntry {
    init(from entryEntity: EntryEntity) {
        self = ListEntry(id: entryEntity.id, value: entryEntity.value, timestamp: entryEntity.timestamp)
    }
}

class SwiftDataEntryListViewModelTests {
    @Test func listEntriesForTopic() throws {
        let entries = [
            EntryEntity(value: 2.4, timestamp: Date(timeIntervalSinceReferenceDate: 100)),
            EntryEntity(value: -2.4, timestamp: Date(timeIntervalSinceReferenceDate: 200)),
            EntryEntity(value: -4, timestamp: Date(timeIntervalSinceReferenceDate: 300)),
            EntryEntity(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 400))
        ]
        let (sut, topic) = try makeSUT(entries: entries)

        let result = sut.listEntries(for: topic)

        #expect(result == entries.sorted(by: { $0.timestamp < $1.timestamp }).map { ListEntry(id: $0.id, value: $0.value, timestamp: $0.timestamp) })
    }

    @Test func updateEntry() throws {
        let entries = [
            EntryEntity(value: 2.4, timestamp: Date(timeIntervalSinceReferenceDate: 100)),
            EntryEntity(value: -2.4, timestamp: Date(timeIntervalSinceReferenceDate: 200)),
            EntryEntity(value: -4, timestamp: Date(timeIntervalSinceReferenceDate: 300)),
            EntryEntity(value: 4, timestamp: Date(timeIntervalSinceReferenceDate: 400))
        ]
        let (sut, topic) = try makeSUT(entries: entries)

        let newValue = -3.5
        let newTimestamp = Date(timeIntervalSinceReferenceDate: 201)
        let updatedEntry = ListEntry(id: entries[1].id, value: newValue, timestamp: newTimestamp)

        sut.updateEntry(updatedEntry, of: topic)

        #expect(topic.sortedEntries[1].value == newValue)
        #expect(topic.sortedEntries[1].timestamp == newTimestamp)
    }

    // MARK: - Helpers

    private func makeSUT(entries: [EntryEntity]) throws -> (SwiftDataEntryListViewModel, TopicEntity) {
        let sut = SwiftDataEntryListViewModel()
        let topic = TopicEntity(name: "Topic 1", entries: entries, palette: Palette.ocean.name, sortIndex: 0)
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let context = try makeContext(with: config)
        try setUp(context: context, with: [topic])

        weakSUT = sut

        return (sut, topic)
    }

    private weak var weakSUT: SwiftDataEntryListViewModel?

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
