//
//  TimeSpan.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 30.10.25.
//

import Foundation

public enum TimeSpan: CaseIterable {
    case week
    case month
    case oneYear

    public var title: String {
        switch self {
        case .week:       return "Week"
        case .month:      return "Month"
        case .oneYear:    return "Year"
        }
    }

    public var calendarComponent: Calendar.Component {
        switch self {
        case .week:       return .weekOfYear
        case .month:      return .month
        case .oneYear:    return .year
        }
    }

    public var componentCount: Int {
        switch self {
        case .week:       return 1
        case .month:      return 1
        case .oneYear:    return 1
        }
    }

    public var naturalAlignment: Calendar.Component {
        switch self {
        case .week:       return .weekOfYear
        case .month:      return .month
        case .oneYear:    return .year
        }
    }

    public var availableDataProviders: [ChartDataProvider] {
        switch self {
        case .week, .month: [.dailySum, .dailyAverage]
        case .oneYear: [.monthlySum, .monthlyAverage]
        }
    }
}
