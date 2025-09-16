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
            ContentView(values: $dataPoints)
                .onAppear {
                    guard let loadedData = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Int] else {
                        print("No stored data found")
                        return
                    }

                    dataPoints = loadedData
                }
                .onChange(of: dataPoints) {
                    saveValues()
                }
        }
    }

    private func saveValues() {
        UserDefaults.standard.set(dataPoints, forKey: userDefaultsKey)
    }
}
