//
//  StoreTests.swift
//  StoreTests
//
//  Created by Lennart Wisbar on 16.09.25.
//

import Testing
import Store

protocol PersistenceService {
    func load() -> [Int]
    func save()
}

class Store {
    private(set) var values: [Int]
    private let persistenceService: PersistenceService?

    init(persistenceService: PersistenceService? = nil) {
        self.persistenceService = persistenceService
        values = persistenceService?.load() ?? []
    }

    func add(_ value: Int) {
        values.append(value)
        persistenceService?.save()
    }

    func removeLastValue() {
        guard !values.isEmpty else { return }
        values.removeLast()
    }
}

struct StoreTests {
    @Test func startsEmpty() {
        let sut = Store()
        #expect(sut.values == [])
    }

    @Test func add_appendsValue() {
        let sut = Store()
        #expect(sut.values == [])

        sut.add(4)
        #expect(sut.values == [4])

        sut.add(2)
        #expect(sut.values == [4, 2])
    }

    @Test func removeLastValue_removesIt() {
        let sut = Store()
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
        let sut = Store()
        #expect(sut.values == [])

        sut.removeLastValue()
        #expect(sut.values == [])
    }

    @Test func init_loadsValues() {
        let stubbedValues = [3, 7, 9, 1]
        let persistenceService = PersistenceServiceSpy()
        persistenceService.values = stubbedValues
        let sut = Store(persistenceService: persistenceService)

        #expect(sut.values == stubbedValues)
        #expect(persistenceService.loadCallCount == 1)
        #expect(persistenceService.saveCallCount == 0)
    }

    @Test func add_savesValues() {
        let stubbedValues = [3, 7, 9, 1]
        let persistenceService = PersistenceServiceSpy()
        persistenceService.values = stubbedValues
        let sut = Store(persistenceService: persistenceService)
        #expect(sut.values == stubbedValues)
        #expect(persistenceService.loadCallCount == 1)
        #expect(persistenceService.saveCallCount == 0)

        sut.add(5)

        #expect(sut.values == stubbedValues + [5])
        #expect(persistenceService.loadCallCount == 1)
        #expect(persistenceService.saveCallCount == 1)
    }
}

// MARK: - Helpers

private class PersistenceServiceSpy: PersistenceService {
    private(set) var loadCallCount = 0
    private(set) var saveCallCount = 0

    var values: [Int] = []

    func load() -> [Int] {
        loadCallCount += 1
        return values
    }
    
    func save() {
        saveCallCount += 1
    }
}
