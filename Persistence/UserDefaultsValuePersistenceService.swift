//
//  UserDefaultsValuePersistenceService.swift
//  Persistence
//
//  Created by Lennart Wisbar on 16.09.25.
//

import Domain

public class UserDefaultsValuePersistenceService: ValuePersistenceService {
    private let userDefaults: UserDefaults
    private let key: String

    public init(key: String, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.userDefaults = userDefaults
    }

    public func save(_ values: [Int]) {
        userDefaults.set(values, forKey: key)
    }

    public func load() -> [Int] {
        userDefaults.array(forKey: key) as? [Int] ?? []
    }
}
