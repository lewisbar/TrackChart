//
//  UserDefaultsPersistenceServiceTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 16.09.25.
//

import Testing
import Foundation

class UserDefaultsPersistenceService {
    private let userDefaults: UserDefaults
    private let key: String

    init(key: String, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.userDefaults = userDefaults
    }

    func save(_ values: [Int]) {
        userDefaults.set(values, forKey: key)
    }

    func load() -> [Int] {
        userDefaults.array(forKey: key) as? [Int] ?? []
    }
}

@Suite(.serialized)
class UserDefaultsPersistenceServiceTests {
    // MARK: - Setup

    let suiteName = UUID().uuidString
    let userDefaults: UserDefaults

    private let testKey = #file
    private weak var weakSUT: UserDefaultsPersistenceService?

    init() {
        userDefaults = UserDefaults(suiteName: suiteName)!
        cleanUp()
    }

    deinit {
        cleanUp()
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
    }

    // MARK: - Actual Tests

    @Test func init_doesNotSave() {
        let _ = makeSUT()
        #expect(storedData() == nil)
    }

    @Test func save_savesData() {
        let values = [2, 1, 4, 6, 3]
        let sut = makeSUT()
        #expect(storedData() == nil)

        sut.save(values)

        #expect(storedData() as? [Int] == values)
    }

    @Test func load_whenNothingIsStored_returnsEmpty() {
        let sut = makeSUT()

        let loadedValues = sut.load()

        #expect(loadedValues == [])
    }

    @Test func load_whenSomethingIsStored_returnsStoredValues() {
        let values = [2, 1, 4, 6, 3]
        let sut = makeSUT()
        sut.save(values)

        let loadedValues = sut.load()

        #expect(loadedValues == values)
    }

    @Test func save_whenSomethingIsStored_overwrites() {
        let values1 = [2, 1, 4, 6, 3]
        let values2 = [10, 20, 400]
        let sut = makeSUT()
        
        sut.save(values1)
        sut.save(values2)

        let loadedValues = sut.load()

        #expect(loadedValues == values2)
    }

    // MARK: - Helpers

    private func makeSUT(suiteName: String = #function) -> UserDefaultsPersistenceService {
        let sut = UserDefaultsPersistenceService(key: testKey, userDefaults: userDefaults)
        weakSUT = sut
        return sut
    }

    private func storedData() -> [Any]? {
        userDefaults.array(forKey: testKey)
    }

    private func cleanUp() {
        userDefaults.removePersistentDomain(forName: suiteName)
    }
}
