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

    var body: some View {
        MainView(title: title, values: sampleValues, submitNewValue: submitNewValue, deleteLastValue: deleteLastValue)
            .padding()
    }

    private func submitNewValue(_ value: Int) {
        sampleValues.append(value)
    }

    private func deleteLastValue() {
        guard !sampleValues.isEmpty else { return }
        sampleValues.removeLast()
    }
}

#Preview {
    ContentView()
//        .environment(\.layoutDirection, .rightToLeft)
}
