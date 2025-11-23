//
//  Aggregator+localizedName.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 23.11.25.
//

import DataProcessing

extension Aggregator {
    var localizedName: String {
        switch self {
        case .sum: return String(localized: .sum)
        case .average: return String(localized: .average)
        }
    }
}
