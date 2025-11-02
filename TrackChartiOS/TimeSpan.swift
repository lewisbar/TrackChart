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
    case sixMonths
    case oneYear

    var title: String {
        switch self {
        case .week:       return "Week"
        case .month:      return "Month"
        case .sixMonths:  return "6 Months"
        case .oneYear:    return "Year"
        }
    }

    var calendarComponent: Calendar.Component {
        switch self {
        case .week:       return .weekOfYear
        case .month:      return .month
        case .sixMonths:  return .month
        case .oneYear:    return .year
        }
    }

    var componentCount: Int {
        switch self {
        case .week:       return 1
        case .month:      return 1
        case .sixMonths:  return 6
        case .oneYear:    return 1
        }
    }

    var availableDataProviders: [ChartDataProvider] {
        switch self {
        case .week, .month: [.dailySum, .dailyAverage]
        case .sixMonths: [.weeklySum, .weeklyAverage]
        case .oneYear: [.monthlySum, .monthlyAverage]
        }
    }
}
