//
//  SwiftDataEntryListViewModelTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 03.12.25.
//

import Testing
import Presentation
import Persistence

struct SwiftDataEntryListViewModelTests {
    @Test func init_doesNotSync() {
        let sut = SwiftDataEntryListViewModel()
        
        #expect(sut.viewEntries.isEmpty)
    }

    @Test func sync() {
        let topic = makeTopicWithThreeEntries()
        let sut = SwiftDataEntryListViewModel()
        #expect(sut.viewEntries.isEmpty)

        sut.sync(from: topic)

        #expect(sut.viewEntries == topic.sortedEntries.map(\.viewEntry).reversed())
    }

    @Test func addEntry_updatesTopicAndSyncs() {
        let topic = makeTopicWithThreeEntries()
        let sut = SwiftDataEntryListViewModel()
        sut.sync(from: topic)
        let entryToAdd = ViewEntry(id: UUID(), value: 100, timestamp: .now.advanced(by: -100))

        sut.addEntry(entryToAdd, to: topic)

        #expect(topic.entries?.count == 4)
        #expect(topic.sortedEntries.contains(where: {
            $0.id == entryToAdd.id &&
            $0.value == entryToAdd.value &&
            $0.timestamp == entryToAdd.timestamp
        }))

        #expect(sut.viewEntries == topic.sortedEntries.map(\.viewEntry).reversed())
    }

    @Test func updateEntry_updatesTopicAndSyncs() {
        let topic = makeTopicWithThreeEntries()
        let sut = SwiftDataEntryListViewModel()
        sut.sync(from: topic)
        let entryToUpdate = ViewEntry(id: topic.sortedEntries[1].id, value: 100, timestamp: .now.advanced(by: -100))

        sut.updateEntry(entryToUpdate, for: topic)

        #expect(topic.entries?.count == 3)
        let updatedEntry = topic.entries?.first(where: { $0.id == entryToUpdate.id })
        #expect(updatedEntry?.value == entryToUpdate.value)
        #expect(updatedEntry?.timestamp == entryToUpdate.timestamp)

        #expect(sut.viewEntries == topic.sortedEntries.map(\.viewEntry).reversed())
    }

    @Test func updateEntry_whenEntryDoesNotExist_doesNothing() {
        let topic = makeTopicWithThreeEntries()
        let sut = SwiftDataEntryListViewModel()
        sut.sync(from: topic)
        let entryToUpdate = ViewEntry(id: UUID(), value: 100, timestamp: .now.advanced(by: -100))

        sut.updateEntry(entryToUpdate, for: topic)

        #expect(topic.entries?.count == 3)
        let updatedEntry = topic.entries?.first(where: { $0.id == entryToUpdate.id })
        #expect(updatedEntry == nil)  // Nothing was updated

        #expect(sut.viewEntries == topic.sortedEntries.map(\.viewEntry).reversed())  // Still in sync
    }

    @Test func deleteEntries_updatesTopicAndSyncs() {
        let topic = makeTopicWithThreeEntries()
        let sut = SwiftDataEntryListViewModel()
        sut.sync(from: topic)
        let expectedRemainingEntry = topic.sortedEntries[1]

        sut.deleteEntries(at: IndexSet([0, 2]), from: topic)

        #expect(topic.entries?.count == 1)
        #expect(topic.sortedEntries == [expectedRemainingEntry])

        #expect(sut.viewEntries == topic.sortedEntries.map(\.viewEntry).reversed())
    }

    @Test func deleteEntries_ignoresInvalidOffsets() {
        let topic = makeTopicWithThreeEntries()
        let sut = SwiftDataEntryListViewModel()
        sut.sync(from: topic)
        let expectedRemainingEntries = Array(topic.sortedEntries.prefix(2))

        sut.deleteEntries(at: IndexSet([0, 3]), from: topic)

        #expect(topic.entries?.count == 2)
        #expect(topic.sortedEntries == expectedRemainingEntries)

        #expect(sut.viewEntries == topic.sortedEntries.map(\.viewEntry).reversed())
    }

    // MARK: - Helpers

    private func makeTopicWithThreeEntries() -> TopicEntity {
        TopicEntity(
            id: UUID(),
            name: "a topic",
            details: "some details",
            entries: [
                EntryEntity(value: 1, timestamp: .now.advanced(by: -400)),
                EntryEntity(value: 2, timestamp: .now.advanced(by: -300)),
                EntryEntity(value: 3, timestamp: .now.advanced(by: -200)),
            ],
            palette: "Lavender Field",
            aggregator: "Average",
            treatsMissingAsZero: false,
            sortIndex: 0
        )
    }
}
