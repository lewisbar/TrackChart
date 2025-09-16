//
//  MainView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI

struct MainView<CounterView: View, ChartView: View>: View {
    let title: String
    @ViewBuilder let counterView: () -> CounterView
    @ViewBuilder let chartView: () -> ChartView

    var body: some View {
        VStack {
            Text(title).font(.title2).padding(.bottom, 4)
            counterView()
            chartView()
        }
    }
}

#Preview {
    @Previewable @State var values = [5, 6, 8, 2, 4, 3, 5, 2]

    MainView(
        title: "My Habit",
        counterView: { CounterView(submitNewValue: { values.append($0) }, deleteLastValue: { values.removeLast() }) },
        chartView: { ChartView(values: values)}
    )
}
