//
//  EntryEntity.swift
//  Persistence
//
//  Created by Lennart Wisbar on 20.10.25.
//

import Foundation
import SwiftData

@Model
public final class EntryEntity {
    public var id: UUID = UUID()
    public var value: Double = 0
    public var timestamp: Date = Date.now
    public var topic: TopicEntity?

    public init(id: UUID = UUID(), value: Double, timestamp: Date) {
        self.id = id
        self.value = value
        self.timestamp = timestamp
    }
}
