//
//  Topic.swift
//
//  Created by Lennart Wisbar on 17.10.25.
//

import Foundation
import SwiftData

@Model
final class Topic {
    var name: String = ""
    @Relationship(deleteRule: .cascade) var entries: [Entry]?
    var unsubmittedValue: Double = 0
    var sortIndex: Int = 0

    var entryCount: Int {
        entries?.count ?? 0
    }

    init(name: String, entries: [Entry]? = nil, unsubmittedValue: Double, sortIndex: Int) {
        self.name = name
        self.entries = entries
        self.unsubmittedValue = unsubmittedValue
        self.sortIndex = sortIndex
    }
}
