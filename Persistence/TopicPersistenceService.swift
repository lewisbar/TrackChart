//
//  TopicPersistenceService.swift
//  Persistence
//
//  Created by Lennart Wisbar on 18.09.25.
//

public protocol TopicPersistenceService {
    func create(_ topic: Topic) throws
    func update(_ topic: Topic) throws
    func delete(_ topic: Topic) throws
    func reorder(to newOrder: [Topic]) throws
    func load() throws -> [Topic]
}
