//
//  TopicPersistenceService.swift
//  Persistence
//
//  Created by Lennart Wisbar on 18.09.25.
//

public protocol TopicPersistenceService {
    func create(_ topic: Topic)
    func update(_ topic: Topic)
    func delete(_ topic: Topic)
    func load() -> [Topic]
}
