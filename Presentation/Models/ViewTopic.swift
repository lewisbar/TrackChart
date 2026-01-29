//
//  ViewTopic.swift
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Foundation

public struct ViewTopic: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let details: String
    public let entries: [ViewEntry]
    public let aggregator: ViewAggregator
    public let treatsMissingAsZero: Bool
    public let sum: Double
    public let average: Double?
    public let highest: Double?
    public let lowest: Double?
    public let palette: Palette

    public init(
        id: UUID,
        name: String,
        details: String,
        entries: [ViewEntry],
        aggregator: ViewAggregator,
        treatsMissingAsZero: Bool,
        sum: Double,
        average: Double?,
        highest: Double?,
        lowest: Double?,
        palette: Palette
    ) {
        self.id = id
        self.name = name
        self.details = details
        self.entries = entries
        self.aggregator = aggregator
        self.treatsMissingAsZero = treatsMissingAsZero
        self.sum = sum
        self.average = average
        self.highest = highest
        self.lowest = lowest
        self.palette = palette
    }
}
