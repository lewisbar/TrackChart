//
//  ListEntry.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 13.11.25.
//

import Foundation

public struct ListEntry: Identifiable, Hashable {
    public let id: UUID
    public let value: Double
    public let timestamp: Date

    public init(id: UUID, value: Double, timestamp: Date) {
        self.id = id
        self.value = value
        self.timestamp = timestamp
    }
}
