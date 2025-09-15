//
//  MainView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI

struct MainView: View {
    let title: String
    let values: [Int]
    @Binding var todaysValue: Int
    let submitValue: (Int) -> Void

    var body: some View {
        VStack {
            Text(title)
            CounterView(count: $todaysValue, submit: submitValue)
            ChartView(values: values)
        }
    }
}

#Preview {
    @Previewable @State var count = 5
    
    MainView(
        title: "My Habit",
        values: [0, 1, 4, 2, 5, 3, 6, 5],
        todaysValue: $count,
        submitValue: { _ in count = 0 }
    )
}
