//
//  ContentView.swift
//  TrackChart
//
//  Created by LennartWisbar on 15.09.25.
//

import SwiftUI

struct ContentView: View {
    private let sampleWeek = Week(
        monday: 2,
        tuesday: 1,
        wednesday: 3,
        thursday: 5,
        friday: 4,
        saturday: 5,
        sunday: 4
    )

    private let title = "My Habit"
    @State private var todaysValue = 5

    var body: some View {
        WeekView(title: title, week: sampleWeek, todaysValue: $todaysValue)
            .padding()
    }
}

#Preview {
    ContentView()
}
