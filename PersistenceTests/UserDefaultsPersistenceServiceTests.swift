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

struct UserDefaultsPersistenceServiceTests {
    @Test func init_doesNotSave() {
        let key = #file
        let userDefaults = UserDefaults(suiteName: #function)!

        let _ = UserDefaultsPersistenceService(key: key, userDefaults: userDefaults)
        let storedData = userDefaults.array(forKey: key)

        #expect(storedData == nil)
    }

    @Test func save_savesData() {
        let key = #file
        let suiteName = #function
        let userDefaults = UserDefaults(suiteName: suiteName)!
        let values = [2, 1, 4, 6, 3]

        let sut = UserDefaultsPersistenceService(key: key, userDefaults: userDefaults)
        #expect(userDefaults.array(forKey: key) == nil)

        sut.save(values)

        #expect(userDefaults.array(forKey: key) as? [Int] == values)

        userDefaults.removePersistentDomain(forName: #function)
    }
}
