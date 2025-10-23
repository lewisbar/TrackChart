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
    public let entries: [Entry]

    public init(id: UUID, name: String, entries: [Entry]) {
        self.id = id
        self.name = name
        self.entries = entries
    }
}
