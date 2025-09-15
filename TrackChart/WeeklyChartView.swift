//
//  WeeklyChartView.swift
//  TrackChart
//
//  Created by LennartWisbar on 15.09.25.
//

import SwiftUI
import Charts

private struct Day: Identifiable {
    let id = UUID()
    let name: String
    let value: Int
}

private extension Week {
    var days: [Day] {
        [
            Day(name: "Mon", value: monday),
            Day(name: "Tue", value: tuesday),
            Day(name: "Wed", value: wednesday),
            Day(name: "Thu", value: thursday),
            Day(name: "Fri", value: friday),
            Day(name: "Sat", value: saturday),
            Day(name: "Sun", value: sunday)
        ]
    }
}

struct WeeklyChartView: View {
    private let days: [Day]

    init(week: Week) {
        days = week.days
    }

    var body: some View {
        Chart {
            ForEach(days) { day in
                LineMark(x: .value("Day", day.name), y: .value("Count", day.value))
            }
        }
    }
}

#Preview {
    WeeklyChartView(week: Week(
        monday: 4,
        tuesday: 8,
        wednesday: 7,
        thursday: 9,
        friday: 5,
        saturday: 6,
        sunday: 10
    ))
}
