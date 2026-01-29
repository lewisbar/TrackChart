//
//  Aggregator+localizedName.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 23.11.25.
//

import Presentation

extension ViewAggregator {
    var localizedName: String {
        switch self {
        case .sum: return String(localized: .sumAggregator)
        case .average: return String(localized: .averageAggregator)
        }
    }
}
