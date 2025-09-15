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
    @Binding var todaysValue: Int

    var body: some View {
        VStack {
            Text(title)
            CounterView(count: $todaysValue)
            WeeklyChartView(week: week)
        }
    }
}

#Preview {
    @Previewable @State var count = 5
    
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
        ),
        todaysValue: $count
    )
}
