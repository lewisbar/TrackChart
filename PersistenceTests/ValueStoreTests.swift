//
//  ValueStoreTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 16.09.25.
//

import Testing
import Persistence

class ValueStoreTests {
    @Test func add_appendsValue() {
        let (sut, _) = makeSUT()
        #expect(sut.values == [])

        sut.add(4)
        #expect(sut.values == [4])

        sut.add(2)
        #expect(sut.values == [4, 2])
    }

    @Test func removeLastValue_removesIt() {
        let (sut, _) = makeSUT()
        #expect(sut.values == [])

        sut.add(4)
        #expect(sut.values == [4])

        sut.add(2)
        #expect(sut.values == [4, 2])

        sut.removeLastValue()
        #expect(sut.values == [4])

        sut.removeLastValue()
        #expect(sut.values == [])
    }

    @Test func removeLastValue_whenEmpty_doesNotCrash() {
        let (sut, _) = makeSUT()
        #expect(sut.values == [])

        sut.removeLastValue()
        #expect(sut.values == [])
    }

    @Test func init_loadsValues() {
        let stubbedValues = [3, 7, 9, 1]
        let (sut, persistenceService) = makeSUT(withValues: stubbedValues)

        #expect(persistenceService.loadCallCount == 1)
        #expect(sut.values == stubbedValues)
        #expect(persistenceService.savedValues.count == 0)
    }

    @Test func add_savesValues() {
        let (sut, persistenceService) = makeSUT()
        #expect(persistenceService.savedValues.count == 0)

        sut.add(5)

        #expect(persistenceService.savedValues == [[5]])
    }

    @Test func removeLastValue_savesValues() {
        let (sut, persistenceService) = makeSUT(withValues: [1, 2, 4])
        #expect(persistenceService.savedValues.count == 0)

        sut.removeLastValue()

        #expect(persistenceService.savedValues == [[1, 2]])
    }

    @Test func isObservable() async throws {
        let (sut, _) = makeSUT()
        let tracker = ObservationTracker()

        withObservationTracking {
            _ = sut.values
        } onChange: {
            Task { await tracker.setTriggered() }
        }

        sut.add(5)

        try await Task.sleep(for: .milliseconds(10))
        let triggered = await tracker.getTriggered()
        #expect(triggered, "Expected observation to be triggered after adding value")
        #expect(sut.values == [5], "Expected values to be [5], got \(sut.values)")
    }

    // MARK: - Helpers

    private func makeSUT(withValues stubbedValues: [Int] = []) -> (sut: ValueStore, persistenceService: PersistenceServiceSpy) {
        let persistenceService = PersistenceServiceSpy()
        persistenceService.values = stubbedValues
        let sut = ValueStore(persistenceService: persistenceService)

        weakSUT = sut
        weakPersistenceService = persistenceService

        return (sut, persistenceService)
    }

    private weak var weakSUT: ValueStore?
    private weak var weakPersistenceService: PersistenceServiceSpy?

    deinit {
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
        #expect(weakPersistenceService == nil, "Instance should have been deallocated. Potential memory leak.")
    }
}

private class PersistenceServiceSpy: SingleTopicPersistenceService {
    private(set) var loadCallCount = 0
    private(set) var savedValues = [[Int]]()

    var values: [Int] = []

    func load() -> [Int] {
        loadCallCount += 1
        return values
    }
    
    func save(_ values: [Int]) {
        savedValues.append(values)
    }
}

private actor ObservationTracker {
    var triggered = false
    func setTriggered() { triggered = true }
    func getTriggered() -> Bool { triggered }
}
