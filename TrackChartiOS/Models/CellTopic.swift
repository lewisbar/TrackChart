//
//  CellTopic.swift
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Foundation
import DataProcessing

public struct CellTopic: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let entries: [ChartEntry]
    public let aggregator: Aggregator
    public let palette: Palette

    public init(id: UUID, name: String, entries: [ChartEntry], aggregator: Aggregator, palette: Palette) {
        self.id = id
        self.name = name
        self.entries = entries
        self.aggregator = aggregator
        self.palette = palette
    }
}
