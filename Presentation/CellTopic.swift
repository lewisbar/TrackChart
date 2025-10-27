//
//  CellTopic.swift
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Foundation

public struct CellTopic: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let entries: [ChartEntry]
    public let palette: Palette

    public var info: String {
        let infoPostfix = entries.count == 1 ? "entry" : "entries"
        return "\(entries.count) \(infoPostfix)"
    }

    public init(id: UUID, name: String, entries: [ChartEntry], palette: Palette) {
        self.id = id
        self.name = name
        self.entries = entries
        self.palette = palette
    }
}

public struct ChartEntry: Hashable, Codable {
    public let value: Double
    public let timestamp: Date

    public init(value: Double, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
    }
}
