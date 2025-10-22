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
    public let unsubmittedValue: Double

    public init(id: UUID, name: String, entries: [Entry], unsubmittedValue: Double) {
        self.id = id
        self.name = name
        self.entries = entries
        self.unsubmittedValue = unsubmittedValue
    }
}
