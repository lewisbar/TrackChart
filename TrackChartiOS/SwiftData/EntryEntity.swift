//
//  EntryEntity.swift
//
//  Created by Lennart Wisbar on 17.10.25.
//

import Foundation
import SwiftData
import Domain

@Model
final class EntryEntity {
    var value: Double = 0
    var timestamp: Date = Date.now
    var sortIndex: Int = 0
    var topic: TopicEntity?

    init(value: Double, timestamp: Date, sortIndex: Int) {
        self.value = value
        self.timestamp = timestamp
        self.sortIndex = sortIndex
    }

    var entry: Entry {
        Entry(value: value, timestamp: timestamp)
    }
}
