//
//  Entry.swift
//  DataProcessing
//
//  Created by Lennart Wisbar on 07.11.25.
//

import Foundation

public struct Entry: Hashable, Codable {
    public let value: Double
    public let timestamp: Date

    public init(value: Double, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
    }
}
