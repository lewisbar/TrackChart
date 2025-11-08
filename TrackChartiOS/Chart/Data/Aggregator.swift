//
//  Aggregator.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 07.11.25.
//

import Foundation

public enum Aggregator: Sendable {
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
}
