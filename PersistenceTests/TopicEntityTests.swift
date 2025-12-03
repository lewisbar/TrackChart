//
//  TopicEntityTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 20.10.25.
//

import Testing
import SwiftData
import Persistence

@MainActor
struct TopicEntityTests {
    @Test func entryCount() throws {
        let context = try makeContext()
        let entries = makeFiveEntryEntities()
        let topicEntity = makeTopicEntity(with: entries)
        try setUp(context: context, with: topicEntity)

        let entryCount = topicEntity.entryCount

        #expect(entryCount == entries.count)
    }

    @Test func entryCount_withNilEntries_returnsZero() throws {
        let context = try makeContext()
        let topicEntity = makeTopicEntity(with: nil)
        try setUp(context: context, with: topicEntity)

        let entryCount = topicEntity.entryCount

        #expect(entryCount == 0)
    }

    @Test func sortedEntries() throws {
        let context = try makeContext()
        let entries = makeFiveEntryEntities()
        let topicEntity = makeTopicEntity(with: entries)
        try setUp(context: context, with: topicEntity)

        let sortedEntries = topicEntity.sortedEntries

        #expect(sortedEntries.map(\.value) == entries.sorted(by: { $0.timestamp < $1.timestamp }).map(\.value))
        #expect(sortedEntries.map(\.timestamp) == entries.sorted(by: { $0.timestamp < $1.timestamp }).map(\.timestamp))
    }

    @Test func sortedEntries_withNilEntries_returnsEmpty() throws {
        let context = try makeContext()
        let topicEntity = makeTopicEntity(with: nil)
        try setUp(context: context, with: topicEntity)

        let sortedEntries = topicEntity.sortedEntries

        #expect(sortedEntries.isEmpty)
    }

    @Test func submitNewValue() throws {
        let context = try makeContext()
        let entries = makeFiveEntryEntities()
        let topicEntity = makeTopicEntity(with: entries)
        try setUp(context: context, with: topicEntity)

        let newID = UUID()
        let newValue = -1.2
        let newTimestamp = Date(timeIntervalSinceReferenceDate: 0)
        topicEntity.submit(id: newID, newValue: newValue, timestamp: newTimestamp)

        #expect(topicEntity.entries?.count == 6)
        #expect(topicEntity.sortedEntries.first?.id == newID)
        #expect(topicEntity.sortedEntries.first?.value == newValue)
        #expect(topicEntity.sortedEntries.first?.timestamp == newTimestamp)
    }

    @Test func updateEntry() throws {
        let context = try makeContext()
        let entries = makeFiveEntryEntities()
        let topicEntity = makeTopicEntity(with: entries)
        try setUp(context: context, with: topicEntity)

        let entryToEdit = topicEntity.sortedEntries[1]
        let newValue = -1.2
        let newTimestamp = Date(timeIntervalSinceReferenceDate: 0)
        topicEntity.updateEntry(withID: entryToEdit.id, value: newValue, timestamp: newTimestamp)

        #expect(topicEntity.entries?.count == 5)
        let updatedEntry = topicEntity.entries?.first(where: { $0.id == entryToEdit.id })
        #expect(updatedEntry?.value == newValue)
        #expect(updatedEntry?.timestamp == newTimestamp)
    }

    @Test func updateEntry_withNonExistentID_doesNothing() throws {
        let context = try makeContext()
        let entries = makeFiveEntryEntities()
        let topicEntity = makeTopicEntity(with: entries)
        try setUp(context: context, with: topicEntity)

        let newValue = -1.2
        let newTimestamp = Date(timeIntervalSinceReferenceDate: 0)
        let nonExistentID = UUID()
        topicEntity.updateEntry(withID: nonExistentID, value: newValue, timestamp: newTimestamp)

        #expect(topicEntity.entries?.count == 5)
        let updatedEntry = topicEntity.entries?.first(where: { $0.id == nonExistentID })
        #expect(updatedEntry == nil)
    }

    @Test func deleteEntries_withForwardOrder() throws {
        let context = try makeContext()
        let entries = makeFiveEntryEntities()
        let topicEntity = makeTopicEntity(with: entries)
        try setUp(context: context, with: topicEntity)
        let ids = topicEntity.sortedEntries.map(\.id)
        let expectedRemainingIDs = [0, 2, 4].map { ids[$0] }

        topicEntity.deleteEntries(atOffsets: IndexSet([1, 3]), order: .forward)

        #expect(topicEntity.entries?.count == 3)
        #expect(topicEntity.sortedEntries.map(\.id) == expectedRemainingIDs)
    }

    @Test func deleteEntries_withReverseOrder() throws {
        let context = try makeContext()
        let entries = makeFiveEntryEntities()
        let topicEntity = makeTopicEntity(with: entries)
        try setUp(context: context, with: topicEntity)
        let ids = topicEntity.sortedEntries.map(\.id)
        let expectedRemainingIDs = [0, 2, 3].map { ids[$0] }

        topicEntity.deleteEntries(atOffsets: IndexSet([0, 3]), order: .reverse)

        #expect(topicEntity.entries?.count == 3)
        #expect(topicEntity.sortedEntries.map(\.id) == expectedRemainingIDs)
    }

    @Test func deleteEntries_withOutOfBoundsOffset_ignoresInvalidOffsets() throws {
        let context = try makeContext()
        let entries = makeFiveEntryEntities()
        let topicEntity = makeTopicEntity(with: entries)
        try setUp(context: context, with: topicEntity)
        let ids = topicEntity.sortedEntries.map(\.id)
        let expectedRemainingIDs = [0, 2, 3, 4].map { ids[$0] }

        topicEntity.deleteEntries(atOffsets: IndexSet([1, 5]), order: .forward)

        #expect(topicEntity.entries?.count == 4)
        #expect(topicEntity.sortedEntries.map(\.id) == expectedRemainingIDs)
    }

    // MARK: - Helpers

    private func makeContext() throws -> ModelContext {
        let schema = Schema([TopicEntity.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        return ModelContext(container)
    }

    private func makeFiveEntryEntities() -> [EntryEntity] {
        [
            EntryEntity(value: 0, timestamp: .now.advanced(by: -120)),
            EntryEntity(value: -4.3, timestamp: .now.advanced(by: -100)),
            EntryEntity(value: 100, timestamp: .now.advanced(by: 0)),
            EntryEntity(value: -2000, timestamp: .now.advanced(by: -60)),
            EntryEntity(value: 10, timestamp: .now.advanced(by: -40))
        ]
    }

    private func makeTopicEntity(with entries: [EntryEntity]?) -> TopicEntity {
        TopicEntity(id: UUID(), name: "Topic 1", entries: entries, palette: "Ocean", sortIndex: 7)
    }

    private func setUp(context: ModelContext, with topicEntity: TopicEntity) throws {
        context.insert(topicEntity)
        try context.save()
    }
}
