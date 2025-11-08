//
//  EntryEntity.swift
//  Persistence
//
//  Created by Lennart Wisbar on 20.10.25.
//

import SwiftData

@Model
public final class EntryEntity {
    public var value: Double = 0
    public var timestamp: Date = Date.now
    public var topic: TopicEntity?

    public init(value: Double, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
    }
}
