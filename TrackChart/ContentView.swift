//
//  ContentView.swift
//  TrackChart
//
//  Created by LennartWisbar on 15.09.25.
//

import SwiftUI

struct ContentView: View {
    @State private var sampleValues = [1, 4, 3, 5, 2, 7, 8, 4, 6]

    private let title = "TrackChart"
    @State private var todaysValue = 5

    var body: some View {
        WeekView(title: title, values: sampleValues, todaysValue: $todaysValue, submitValue: submitValue)
            .padding()
    }

    private func submitValue(_ value: Int) {
        sampleValues.append(value)
        todaysValue = 0
    }
}

#Preview {
    ContentView()
//        .environment(\.layoutDirection, .rightToLeft)
}
