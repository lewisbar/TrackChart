//
//  ValuePersistenceService.swift
//  Persistence
//
//  Created by Lennart Wisbar on 16.09.25.
//

public protocol ValuePersistenceService {
    func load() -> [Int]
    func save(_ values: [Int])
}
