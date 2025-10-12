//
//  TopicView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI

struct TopicView<CounterView: View, ChartView: View>: View {
    @Binding var title: String
    @ViewBuilder let counterView: () -> CounterView
    @ViewBuilder let chartView: () -> ChartView
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            TextField("Enter topic name", text: $title)
                .font(.largeTitle)
                .fontWeight(.medium)
                .minimumScaleFactor(0.5)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .focused($isTextFieldFocused)

            chartView()
            counterView()
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
    @Previewable @State var values = [5, 6, 8, 2, 4, 3, 5, 2]
    @Previewable @State var title = "A Title"

    TopicView(
        title: $title,
        counterView: { CounterView(submitNewValue: { values.append($0) }, deleteLastValue: { values.removeLast() }) },
        chartView: { ChartView(values: values)}
    )
    .padding()
}
