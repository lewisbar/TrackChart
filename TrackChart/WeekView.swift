//
//  WeekView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI

struct WeekView: View {
    let title: String
    let week: Week

    var body: some View {
        VStack {
            Text(title)
            CounterView()
            WeeklyChartView(week: week)
        }
    }
}

#Preview {
    WeekView(
        title: "My Habit",
        week: Week(
            monday: 4,
            tuesday: 8,
            wednesday: 7,
            thursday: 9,
            friday: 5,
            saturday: 6,
            sunday: 10
        )
    )
}
