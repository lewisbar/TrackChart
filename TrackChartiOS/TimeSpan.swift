//
//  TimeSpan.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 30.10.25.
//

import Foundation

enum TimeSpan: CaseIterable, Sendable {
    case week, month, sixMonths, oneYear, twoYears, threeYears, fourYears, fiveYears

    var calendarComponent: Calendar.Component {
        switch self {
        case .week:        return .weekOfYear
        case .month:       return .month
        case .sixMonths:   return .month   // 6-month chunks
        case .oneYear:     return .year
        case .twoYears:    return .year
        case .threeYears:  return .year
        case .fourYears:   return .year
        case .fiveYears:   return .year
        }
    }

    var componentCount: Int {
        switch self {
        case .week:        return 1
        case .month:       return 1
        case .sixMonths:   return 6
        case .oneYear:     return 1
        case .twoYears:    return 2
        case .threeYears:  return 3
        case .fourYears:   return 4
        case .fiveYears:   return 5
        }
    }

    /// How many *aggregation units* fit into this span?
    var maxPoints: Int {
        switch self {
        case .week:        return 7      // 7 days
        case .month:       return 31     // up to 31 days
        case .sixMonths:   return 26     // ~26 weeks
        case .oneYear:     return 52     // 52 weeks
        case .twoYears:    return 24     // 24 months
        case .threeYears:  return 36
        case .fourYears:   return 48
        case .fiveYears:   return 60
        }
    }
}

extension TimeSpan {
    var title: String {
        switch self {
        case .week:        return "1 Week"
        case .month:       return "1 Month"
        case .sixMonths:   return "6 Months"
        case .oneYear:     return "1 Year"
        case .twoYears:    return "2 Years"
        case .threeYears:  return "3 Years"
        case .fourYears:   return "4 Years"
        case .fiveYears:   return "5 Years"
        }
    }
}
