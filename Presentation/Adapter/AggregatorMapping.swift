//
//  AggregatorMapping.swift
//  Presentation
//
//  Created by Lennart Wisbar on 02.12.25.
//

import DataProcessing

public extension Aggregator {
    var viewAggregator: ViewAggregator {
        switch self {
        case .sum: .sum
        case .average: .average
        }
    }
}

public extension ViewAggregator {
    var name: String {
        aggregator.name
    }

    var aggregator: Aggregator {
        self == .sum ? .sum : .average
    }
}
