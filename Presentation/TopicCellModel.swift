//
//  TopicCellModel.swift
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Foundation
import Domain

public struct TopicCellModel: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let info: String
    public let entries: [Int]

    public init(id: UUID, name: String, info: String, entries: [Int]) {
        self.id = id
        self.name = name
        self.info = info
        self.entries = entries
    }

    public init(from topic: Topic) {
        let infoPostfix = topic.entries.count == 1 ? "entry" : "entries"

        self.id = topic.id
        self.name = topic.name
        self.info = "\(topic.entries.count) \(infoPostfix)"
        self.entries = topic.entries
    }
}
