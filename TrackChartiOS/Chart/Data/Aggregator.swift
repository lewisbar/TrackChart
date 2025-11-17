//
//  Aggregator.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 07.11.25.
//

import Foundation

public enum Aggregator: Sendable, CaseIterable {
    case sum
    case average

    public func aggregate(_ values: [Double]) -> Double {
        switch self {
        case .sum:
            return values.reduce(0, +)
        case .average:
            return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        }
    }

    public var name: String {
        switch self {
        case .sum: return "Sum"
        case .average: return "Average"
        }
    }

    public static func aggregator(named name: String) -> Aggregator {
        name == average.name ? .average : .sum
    }
}
