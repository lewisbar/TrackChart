//
//  ViewTopic.swift
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Foundation

public struct ViewTopic: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let entries: [ViewEntry]
    public let aggregator: ViewAggregator
    public let treatsMissingAsZero: Bool
    public let palette: Palette

    public init(id: UUID, name: String, entries: [ViewEntry], aggregator: ViewAggregator, treatsMissingAsZero: Bool, palette: Palette) {
        self.id = id
        self.name = name
        self.entries = entries
        self.aggregator = aggregator
        self.treatsMissingAsZero = treatsMissingAsZero
        self.palette = palette
    }
}
