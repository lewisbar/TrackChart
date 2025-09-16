//
//  ContentView.swift
//  TrackChart
//
//  Created by LennartWisbar on 15.09.25.
//

import SwiftUI

struct ContentView: View {
    @Binding var values: [Int]
    private let title = "TrackChart"

    var body: some View {
        MainView(title: title, values: values, submitNewValue: submitNewValue, deleteLastValue: deleteLastValue)
            .padding()
    }

    private func submitNewValue(_ value: Int) {
        values.append(value)
    }

    private func deleteLastValue() {
        guard !values.isEmpty else { return }
        values.removeLast()
    }
}

#Preview {
    @Previewable @State var values = [1, 3, 2, 5, 4, 6, 9, 4]
    
    ContentView(values: $values)
//        .environment(\.layoutDirection, .rightToLeft)
}
