//
//  TopicStore.swift
//  Domain
//
//  Created by Lennart Wisbar on 27.09.25.
//

import Foundation

public protocol TopicStore {
    var topics: [Topic] { get }
    func topic(for id: UUID) -> Topic?
    func load() throws
    func add(_ topic: Topic) throws
    func update(_ topic: Topic) throws
    func reorder(to newOrder: [Topic]) throws
    func remove(_ topic: Topic) throws
    func submit(_ newValue: Int, to topic: Topic) throws
    func removeLastValue(from topic: Topic) throws
    func changeName(of topic: Topic, to newName: String) throws
}
