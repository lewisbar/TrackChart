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
    let submitNewValue: (Int) -> Void
    let deleteLastValue: () -> Void

    var body: some View {
        VStack {
            Text(title).font(.title2).padding(.bottom, 4)
            CounterView(submitNewValue: submitNewValue, deleteLastValue: deleteLastValue)
            ChartView(values: values)
        }
    }
}

#Preview {
    @Previewable @State var count = 5
    
    MainView(
        title: "My Habit",
        values: [0, 1, 4, 2, 5, 3, 6, 5],
        submitNewValue: { _ in count = 0 },
        deleteLastValue: {}
    )
}
