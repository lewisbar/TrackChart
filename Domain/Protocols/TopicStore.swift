//
//  TopicStore.swift
//  Domain
//
//  Created by Lennart Wisbar on 15.10.25.
//

public typealias TopicStore = TopicLoading & TopicReading & TopicWriting & TopicReordering

public protocol TopicLoading {
    func load() throws
}

public protocol TopicReading {
    var topics: [Topic] { get set }
    func topic(for id: UUID) -> Topic?
}

public protocol TopicWriting {
    func add(_ topic: Topic) throws
    func update(_ topic: Topic) throws
    func remove(_ topic: Topic) throws
}

public protocol TopicReordering {
    func reorder(to newOrder: [Topic]) throws
}
