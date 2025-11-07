//
//  Aggregator.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 07.11.25.
//

import Foundation

enum Aggregator {
    case sum
    case average

    func aggregate(_ values: [Double]) -> Double {
        switch self {
        case .sum:
            return values.reduce(0, +)
        case .average:
            return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        }
    }
}
