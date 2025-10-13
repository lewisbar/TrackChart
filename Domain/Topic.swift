//
//  Topic.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Foundation

public struct Topic: Equatable {
    public let id: UUID
    public let name: String
    public let entries: [Int]
    public let unsubmittedValue: Int

    public init(id: UUID, name: String, entries: [Int], unsubmittedValue: Int = 0) {
        self.id = id
        self.name = name
        self.entries = entries
        self.unsubmittedValue = unsubmittedValue
    }
}
