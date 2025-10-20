//
//  Entry.swift
//
//  Created by Lennart Wisbar on 17.10.25.
//

import Foundation
import SwiftData

@Model
final class Entry {
    var value: Double = 0
    var timestamp: Date = Date.now
    var sortIndex: Int = 0
    var topic: Topic?

    init(value: Double, timestamp: Date, sortIndex: Int) {
        self.value = value
        self.timestamp = timestamp
        self.sortIndex = sortIndex
    }
}
