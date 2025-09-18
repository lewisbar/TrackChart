//
//  ContentView.swift
//  TrackChart
//
//  Created by LennartWisbar on 15.09.25.
//

import SwiftUI

struct ContentView<MainView: View>: View {
    @ViewBuilder let mainView: () -> MainView

    var body: some View {
        mainView()
            .padding()
    }
}

#Preview {
    @Previewable @State var values = [1, 2, 4, 5, 2, 4, 7, 1]

    ContentView(
        mainView: {
            TopicView(
                title: "Title",
                counterView: {
                    CounterView(
                        submitNewValue: { values.append($0) },
                        deleteLastValue: { values.removeLast() }
                    )
                },
                chartView: { ChartView(values: values) }
            )
        }
    )
}
