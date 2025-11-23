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
        case .week:       return String(localized: "Week")
        case .month:      return String(localized: "Month")
        case .oneYear:    return String(localized: "Year")
        }
    }
}
