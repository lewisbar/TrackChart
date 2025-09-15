//
//  WeeklyChartView.swift
//  TrackChart
//
//  Created by LennartWisbar on 15.09.25.
//

import SwiftUI
import Charts

struct Day: Identifiable {
    let id = UUID()
    let name: String
    let value: Int
}

struct WeeklyChartView: View {
    let days: [Day]

    var body: some View {
        Chart {
            ForEach(days) { day in
                LineMark(x: .value("Day", day.name), y: .value("Count", day.value))
            }
        }
    }
}

#Preview {
    let days = [
        Day(name: "Monday", value: 4),
        Day(name: "Tuesday", value: 11),
        Day(name: "Wednesday", value: 2),
        Day(name: "Thursday", value: 5),
        Day(name: "Friday", value: 9),
        Day(name: "Saturday", value: 7),
        Day(name: "Sunday", value: 13)
    ]

    WeeklyChartView(days: days)
}
