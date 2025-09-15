//
//  WeekView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI

struct WeekView: View {
    let title: String
    let values: [Int]
    @Binding var todaysValue: Int

    var body: some View {
        VStack {
            Text(title)
            CounterView(count: $todaysValue)
            ChartView(values: values)
        }
    }
}

#Preview {
    @Previewable @State var count = 5
    
    WeekView(
        title: "My Habit",
        values: [0, 1, 4, 2, 5, 3, 6, 5],
        todaysValue: $count
    )
}
