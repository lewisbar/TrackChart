//
//  TrackChartApp.swift
//  TrackChart
//
//  Created by LennartWisbar on 15.09.25.
//

import SwiftUI
import Persistence

@main
struct TrackChartApp: App {
    @State private var store = ValueStore(persistenceService: UserDefaultsPersistenceService(key: "DataPoints"))

    var body: some Scene {
        WindowGroup {
            ContentView(mainView: makeMainView)
        }
    }

    private func makeMainView() -> some View {
        MainView(title: "TrackChart", counterView: makeCounterView, chartView: makeChartView)
    }

    private func makeCounterView() -> some View {
        CounterView(submitNewValue: store.add, deleteLastValue: store.removeLastValue)
    }

    @ViewBuilder
    private func makeChartView() -> some View {
        if !store.values.isEmpty {
            ChartView(values: store.values)
        } else {
            VStack(alignment: .center) {
                Text("Start adding data points using the buttons above.")
                    .multilineTextAlignment(.center)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .padding(.bottom, 50)
            }
        }
    }
}
