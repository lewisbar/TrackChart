//
//  ContentView.swift
//  TrackChart
//
//  Created by LennartWisbar on 15.09.25.
//

import SwiftUI

struct ContentView: View {
    @State private var sampleValues = [1, 4, 3, 5, 2, 7, 8, 4, 6]

    private let title = "My Habit"
    @State private var todaysValue = 5

    var body: some View {
        WeekView(title: title, values: sampleValues, todaysValue: $todaysValue, submitValue: { sampleValues.append($0) })
            .padding()
    }
}

#Preview {
    ContentView()
}
