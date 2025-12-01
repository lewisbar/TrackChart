//
//  ViewEntry.swift
//  Presentation
//
//  Created by Lennart Wisbar on 01.12.25.
//

import Foundation

public struct ViewEntry: Identifiable, Hashable {
    public let id: UUID
    public let value: Double
    public let timestamp: Date

    public init(id: UUID, value: Double, timestamp: Date) {
        self.id = id
        self.value = value
        self.timestamp = timestamp
    }
}
