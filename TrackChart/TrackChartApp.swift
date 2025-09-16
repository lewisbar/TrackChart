//
//  TrackChartApp.swift
//  TrackChart
//
//  Created by LennartWisbar on 15.09.25.
//

import SwiftUI

@main
struct TrackChartApp: App {
    @State private var dataPoints: [Int] = []
    private let userDefaultsKey = "DataPoints"

    var body: some Scene {
        WindowGroup {
            ContentView(mainView: makeMainView)
                .onAppear(perform: loadValues)
                .onChange(of: dataPoints, saveValues)
        }
    }

    private func makeMainView() -> some View {
        MainView(title: "TrackChart", counterView: makeCounterView, chartView: makeChartView)
    }

    private func makeCounterView() -> some View {
        CounterView(submitNewValue: submitNewValue, deleteLastValue: deleteLastValue)
    }

    private func makeChartView() -> some View {
        ChartView(values: dataPoints)
    }

    private func loadValues() {
        guard let loadedData = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Int] else {
            print("No stored data found")
            return
        }

        dataPoints = loadedData
    }

    private func saveValues() {
        UserDefaults.standard.set(dataPoints, forKey: userDefaultsKey)
    }

    private func submitNewValue(_ value: Int) {
        dataPoints.append(value)
    }

    private func deleteLastValue() {
        guard !dataPoints.isEmpty else { return }
        dataPoints.removeLast()
    }
}
