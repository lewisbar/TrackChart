//
//  Entry.swift
//  Domain
//
//  Created by Lennart Wisbar on 21.10.25.
//

public struct Entry: Equatable {
    public let value: Double
    public let timestamp: Date

    public init(value: Double, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
    }
}
