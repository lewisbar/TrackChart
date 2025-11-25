//
//  TimeSpan.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 30.10.25.
//

import Foundation

@frozen
public enum TimeSpan: String, CaseIterable {
    case week
    case month
    case oneYear

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

    public func availableDataProviders(treatsMissingAsZero: Bool, calendar: Calendar = .current) -> [ChartDataProvider] {
        switch self {
        case .week, .month: [.dailySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar), .dailyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)]
        case .oneYear: [.monthlySum(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar), .monthlyAverage(treatsMissingAsZero: treatsMissingAsZero, calendar: calendar)]
        }
    }
}
