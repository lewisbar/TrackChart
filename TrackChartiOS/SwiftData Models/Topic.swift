//
//  Topic.swift
//
//  Created by Lennart Wisbar on 17.10.25.
//

import Foundation
import SwiftData

@Model
final class Topic {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    @Relationship(deleteRule: .cascade) var entries: [Entry]?
    var unsubmittedValue: Double = 0
    var sortIndex: Int = 0

    var entryCount: Int {
        entries?.count ?? 0
    }

    init(id: UUID = UUID(), name: String, unsubmittedValue: Double, sortIndex: Int) {
        self.id = id
        self.name = name
        self.unsubmittedValue = unsubmittedValue
        self.sortIndex = sortIndex
    }
}
