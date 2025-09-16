//
//  UserDefaultsPersistenceServiceTests.swift
//  PersistenceTests
//
//  Created by LennartWisbar on 16.09.25.
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
}

@Suite(.serialized)
class UserDefaultsPersistenceServiceTests {
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
