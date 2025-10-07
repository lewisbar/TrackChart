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

    public init(id: UUID, name: String, info: String) {
        self.id = id
        self.name = name
        self.info = info
    }

    public init(from topic: Topic) {
        self.id = topic.id
        self.name = topic.name
        self.info = "\(topic.entries.count) entries"
    }
}
