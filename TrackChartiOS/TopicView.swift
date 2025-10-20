//
//  TopicView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import Presentation

struct TopicView: View {
    @Binding var name: String
    @Binding var unsubmittedValue: Double
    let entries: [Double]
    let submitNewValue: (Double) -> Void
    let deleteLastValue: () -> Void

    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            TextField("Enter topic name", text: $name)
                .font(.largeTitle)
                .fontWeight(.medium)
                .minimumScaleFactor(0.5)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .focused($isTextFieldFocused)

            ChartView(values: entries)

            CounterView(
                count: $unsubmittedValue,
                submitNewValue: submitNewValue,
                deleteLastValue: deleteLastValue
            )
            .padding(.vertical)
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
        .toolbar { ToolbarItem(placement: .topBarLeading, content: chevronOnlyBackButton) }
    }

    private func chevronOnlyBackButton() -> some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    TopicView(
        name: .constant("Topic 1"),
        unsubmittedValue: .constant(0),
        entries: [1, 2, 4, 8, 7, 3, 0, -2, -8, -3, 1],
        submitNewValue: { _ in },
        deleteLastValue: {}
    )
    .padding()
}
