//
//  ProcessedEntry.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 07.11.25.
//

import Foundation

public struct ProcessedEntry: Identifiable, Equatable {
    public let id = UUID()
    public let value: Double
    public let timestamp: Date

    public init(value: Double, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
    }
}
