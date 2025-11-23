//
//  TimeSpan+localizedTitle.swift
//  TrackChartiOS
//
//  Created by LennartWisbar on 23.11.25.
//

import DataProcessing

public extension TimeSpan {
    var title: String {
        switch self {
        case .week:       return String(localized: .week)
        case .month:      return String(localized: .month)
        case .oneYear:    return String(localized: .year)
        }
    }
}
